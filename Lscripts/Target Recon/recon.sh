#!/bin/bash

# ─── CONFIG ──────────────────────────────────────────────────────
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
NC="\033[0m"
DOMAIN="$1"
OUT_DIR="output/$DOMAIN"

# ─── CHECK ARGS ──────────────────────────────────────────────────
if [ -z "$DOMAIN" ]; then
    echo -e "${RED}Usage: $0 <domain>${NC}"
    exit 1
fi

# ─── SETUP ───────────────────────────────────────────────────────
setup_dirs() {
    mkdir -p "$OUT_DIR"/{subdomains,dns,httpx,web,params,vulns,secrets,wordlists,nmap}
}

GF_PATTERNS=(xss sqli ssrf lfi rce idor)


# ─── SUBDOMAIN ENUMERATION ──────────────────────────────────────
subdomain_enum() {
    echo -e "${YELLOW}[+] Enumerating Subdomains...${NC}"
    subfinder -d "$DOMAIN" -all -silent | sort -u > "$OUT_DIR/subdomains/subfinder.txt"
    assetfinder --subs-only "$DOMAIN" | sort -u > "$OUT_DIR/subdomains/assetfinder.txt"
    amass enum -passive -d "$DOMAIN" -o "$OUT_DIR/subdomains/amass.txt"

    sort -u "$OUT_DIR/subdomains/assetfinder.txt" "$OUT_DIR/subdomains/subfinder.txt" > "$OUT_DIR/subdomains/final.txt" && rm -rf "$OUT_DIR/subdomains/assetfinder.txt" "$OUT_DIR/subdomains/subfinder.txt"
     
}

# ─── DNS + HTTP PROBE ───────────────────────────────────────────
dns_and_http_probe() {
    echo -e "${YELLOW}[+] Resolving DNS & Probing HTTP...${NC}"
    dnsx -l "$OUT_DIR/subdomains/final.txt" -silent | sort -u > "$OUT_DIR/dns/resolved.txt"
    httpx -l "$OUT_DIR/dns/resolved.txt" -silent | sort -u > "$OUT_DIR/dns/alive.txt"
}

# ─── WEB RECON ──────────────────────────────────────────────────
web_recon() {
    echo -e "${YELLOW}[+] Crawling + JS Enumeration...${NC}"
    katana -list "$OUT_DIR/dns/alive.txt" -silent -d 15 -jc -jsl -o "$OUT_DIR/web/katana.txt"
    gau "$DOMAIN" > "$OUT_DIR/web/gau.txt"
    waymore -i "$DOMAIN" -mode U -oU "$OUT_DIR/web/waymore.txt"
    jsfinder -l "$OUT_DIR/dns/alive.txt" -s -o "$OUT_DIR/web/jsfinder.txt"
    cat "$OUT_DIR/web/"*.txt | sort -u | sed -E 's|(.*\.js)\?.*|\1|' > "$OUT_DIR/web/all_urls.txt"
    cat "$OUT_DIR/web/all_urls.txt" | grep -E '\.js$' | sort -u > "$OUT_DIR/web/jsfiles.txt"
    sort -u "$OUT_DIR/web/all_urls.txt" "$OUT_DIR/dns/alive.txt" > "$OUT_DIR/params/gf_ready.txt"
}

# ─── PARAMETER DISCOVERY ────────────────────────────────────────
param_discovery() {
    echo -e "${YELLOW}[+] Running GF Pattern Matching...${NC}"
    for pattern in "${GF_PATTERNS[@]}"; do
        cat "$OUT_DIR/params/gf_ready.txt" | gf "$pattern" | sort -u > "$OUT_DIR/params/${pattern}.txt"
    done
}

# ─── VULNERABILITY DISCOVERY ────────────────────────────────────
vuln_discovery() {
    echo -e "${YELLOW}[+] Scanning for Vulnerabilities...${NC}"
    nuclei -list "$OUT_DIR/dns/alive.txt" -silent -o "$OUT_DIR/vulns/nuclei.txt" -as
    dalfox file "$OUT_DIR/params/xss.txt" -o "$OUT_DIR/vulns/dalfox_raw.txt"
    sort -u "$OUT_DIR/vulns/dalfox_raw.txt" > "$OUT_DIR/vulns/dalfox.txt"
    sqlmap -m "$OUT_DIR/params/sqli.txt" --batch --level=5 --random-agent --output-dir="$OUT_DIR/vulns/sqlmap"
}

# ─── SECRET HUNTING ─────────────────────────────────────────────
secret_hunting() {
    echo -e "${YELLOW}[+] Searching for Secrets...${NC}"
    python3 /usr/bin/SecretFinder.py -i "$OUT_DIR/web/jsfiles.txt" -o cli | sort -u > "$OUT_DIR/secrets/secretfinder.txt"
    trufflehog filesystem "$OUT_DIR/web" --json | jq -c . | sort -u > "$OUT_DIR/secrets/trufflehog.json"
    cat "$OUT_DIR/web/jsfiles.txt" | mantra -s > "$OUT_DIR/secrets/mantra.txt"
}


# ─── MASTER FUNCTION ────────────────────────────────────────────
main() {
    setup_dirs
    subdomain_enum
    dns_and_http_probe
    web_recon
    param_discovery
    vuln_discovery
    secret_hunting

    echo -e "${GREEN}[*] Recon Complete. Output saved in $OUT_DIR${NC}"
}

main
