#!/usr/bin/env bash

# Prompt for required inputs
while true; do
    read -rp "Enter the URL: " url
    if [[ -n "$url" ]]; then
        break
    else
        echo "No URL found. Please enter a URL."
    fi
done
while true; do
    read -rp "Enter Wordlist Path: " wordlist_path
    if [[ -f "$wordlist_path" ]]; then
        break
    else
        echo "Invalid file path. Please enter a valid wordlist path."
    fi
done

read -rp "Enter Match Text (leave blank to include all results): " match_text
read -rp "Enter Subdirectory Recursion Depth (default: 3): " recursion_depth
recursion_depth=${recursion_depth:-3}  # Default to 3 if not provided

# Create output directory with timestamp
output_dir="recon_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$output_dir"

# Subdomain enumeration and filtering
echo "[+] Starting subdomain enumeration..."
if [[ -n "$match_text" ]]; then
    ( subfinder -d "$url" & assetfinder --subs-only "$url" & curl -s "https://crt.sh/?q=%.$url&output=json" | jq -r '.[].name_value' ) 2>/dev/null | grep "$match_text" | sort -u > "$output_dir/subdomains.txt"
else
    ( subfinder -d "$url" & assetfinder --subs-only "$url" & curl -s "https://crt.sh/?q=%.$url&output=json" | jq -r '.[].name_value' ) 2>/dev/null | sort -u > "$output_dir/subdomains.txt"
fi

# Subdomain validation and extraction
echo "[+] Validating subdomains..."
( httpx -l "$output_dir/subdomains.txt" -title -sc -silent -o "$output_dir/subdomain_act.txt" & 
  cat "$output_dir/subdomains.txt" | xargs -I {} host {} > "$output_dir/resolved_domains.txt" ) 2>/dev/null

wait
sleep 5

# Clean status codes from subdomain_act.txt
sed 's/ \[.*\]//g' $output_dir/subdomain_act.txt > $output_dir/subdomain_act_clean.txt

# Run int.py for directory fuzzing
echo "[+] Starting directory fuzzing with..."
python3 /usr/bin/rec.py -w "$wordlist_path" -r "$output_dir/subdomain_act_clean.txt" -c "$recursion_depth" -o "$output_dir/fuzzing_results" 2>/dev/null

# Extract JS files from subdomains
echo "[+] Extracting JavaScript files..."
katana -list "$output_dir/subdomain_act_clean.txt" | grep -i "\.js$" > "$output_dir/js_files.txt" 2>/dev/null

# Extract JavaScript files from fuzzing results
for ((i=1; i<=$recursion_depth; i++)); do
    result_file="$output_dir/fuzzing_results/depth_${i}_200.txt"
    if [[ -f "$result_file" ]]; then
        echo "[+] Processing JavaScript files from depth $i..."
        # Clean status codes if present in the result files
        sed 's/ \[.*\]//g' "$result_file" | katana -list - | grep -i "\.js$" >> "$output_dir/js_files.txt" 2>/dev/null
    fi
done

# Sort and deduplicate JavaScript files
sort -u "$output_dir/js_files.txt" -o "$output_dir/js_files.txt"

# Extract APIs using Mantra
echo "[+] Extracting APIs from JavaScript files..."
cat "$output_dir/js_files.txt" | mantra > "$output_dir/api.txt" 2>/dev/null

# Cleanup temporary files
rm -rf "$output_dir/subdomain_act_clean.txt"

# Generate summary report
echo "Reconnaissance Summary"
echo "====================="
echo "Target URL: $url"
echo "Timestamp: $(date)"
echo ""
echo "Statistics:"
echo "- Total subdomains found: $(wc -l < "$output_dir/subdomains.txt")"
echo "- Active subdomains: $(wc -l < "$output_dir/subdomain_act.txt")"
echo "- JavaScript files discovered: $(wc -l < "$output_dir/js_files.txt")"
echo "- APIs identified: $(wc -l < "$output_dir/api.txt")"

echo "[+] Reconnaissance completed. Results saved in: $(pwd)/$output_dir"
