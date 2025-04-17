#!/bin/bash

# Define color codes
RED="\e[91m"
GREEN="\e[92m"
YELLOW="\e[93m"
BLUE="\e[94m"
RESET="\e[0m"

LOG_FILE="monitor_report.txt"

echo -e "${BLUE}Gathering resource data... Please wait.${RESET}"
echo "===== Troubleshoot Report - $(date) =====" > "$LOG_FILE"

# 1. List unresponsive processes
echo -e "\n${GREEN}[+] Checking for unresponsive processes...${RESET}"
echo "----- Unresponsive Processes -----" >> "$LOG_FILE"
ps -eo pid,stat,cmd | awk '$2 ~ /D|Z/ {print}' | tee -a "$LOG_FILE"

# 2. Outbound network connections
echo -e "\n${GREEN}[+] Checking outbound network connections...${RESET}"
echo "----- Active Network Connections -----" >> "$LOG_FILE"
echo -e "${YELLOW}Local IP   | Remote IP   | Port | Process${RESET}"
netstat -tunp | awk '$6 == "ESTABLISHED" {print $4, $5, $7}' | tee -a "$LOG_FILE"

# 3. High CPU and Memory usage processes
echo -e "\n${GREEN}[+] Checking for high resource usage processes...${RESET}"
echo "----- High CPU Usage -----" >> "$LOG_FILE"
echo -e "${YELLOW}PID | %CPU | Process${RESET}"
ps -eo pid,%cpu,cmd --sort=-%cpu | head -n 6 | tee -a "$LOG_FILE"

echo "----- High Memory Usage -----" >> "$LOG_FILE"
echo -e "${YELLOW}PID | %MEM | Process${RESET}"
ps -eo pid,%mem,cmd --sort=-%mem | head -n 6 | tee -a "$LOG_FILE"

# 4. Battery status (if applicable)
if [ -d "/sys/class/power_supply" ]; then
    echo -e "\n${GREEN}[+] Checking battery status...${RESET}"
    echo "----- Battery Status -----" >> "$LOG_FILE"
    cat /sys/class/power_supply/BAT0/capacity 2>/dev/null | awk '{print "Battery: " $1 "%"}' | tee -a "$LOG_FILE"
fi

# 5. Network issues
echo -e "\n${GREEN}[+] Checking network connectivity...${RESET}"
echo "----- Network Check -----" >> "$LOG_FILE"
ping -c 4 8.8.8.8 | tee -a "$LOG_FILE"

# 6. Antivirus scan (ClamAV)
if command -v clamscan &>/dev/null; then
    echo -e "\n${GREEN}[+] Checking for flagged files using ClamAV...${RESET}"
    echo "----- Antivirus Scan -----" >> "$LOG_FILE"
    clamscan -r /home --bell --quiet | tee -a "$LOG_FILE"
else
    echo -e "${YELLOW}[!] ClamAV not found. Skipping antivirus check.${RESET}"
fi

# 7. System information
echo -e "\n${GREEN}[+] Gathering system information...${RESET}"
echo "----- System Info -----" >> "$LOG_FILE"
uname -a | tee -a "$LOG_FILE"
df -h | tee -a "$LOG_FILE"

echo -e "\n${BLUE}Report saved to ${LOG_FILE}${RESET}"
