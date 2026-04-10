#!/bin/zsh

# =====================
# GSO Forensics macOS DFIR Triage version 1.0
# =====================
# Author: Alwin Espiritu
# Description: Lightweight macOS DFIR triage script for rapid incident response collection

echo "=============================================="
echo "GSO Forensics macOS DFIR Triage version 1.0"
echo "=============================================="

# ----------------------
# 1. Check for sudo/root
# ----------------------
if [[ "$EUID" -ne 0 ]]; then
  echo "[!] Not running as root. Please rerun with sudo."
  exit 1
fi

# ----------------------
# 2. Output Folder
# ----------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FOLDER_TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
OUTPUT_DIR="$SCRIPT_DIR/DFIR_Output_$FOLDER_TIMESTAMP"

mkdir -p "$OUTPUT_DIR"

echo "[*] IR Collection started at: $(date '+%Y-%m-%d %H:%M:%S')"

# ----------------------
# 3. Command Runner
# ----------------------
run_cmd() {
  local name="$1"
  local cmd="$2"
  local outfile="$OUTPUT_DIR/$name.txt"

  echo "[*] Processing: $name"

  {
    echo "========================================="
    echo "Command: $cmd"
    echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================="
    eval "$cmd"
  } > "$outfile" 2>&1

  if [[ $? -eq 0 ]]; then
    echo "[+] Completed: $name"
  else
    echo "[!] Failed: $name"
  fi
}

# ----------------------
# 4. SYSTEM INFORMATION
# ----------------------
run_cmd "hostname" "hostname"
run_cmd "sw_vers" "sw_vers"
run_cmd "uname_a" "uname -a"
run_cmd "system_profiler_hardware" "system_profiler SPHardwareDataType"
run_cmd "system_profiler_software" "system_profiler SPSoftwareDataType"
run_cmd "uptime" "uptime"
run_cmd "date" "date"
run_cmd "env_variables" "printenv"
run_cmd "diskutil_list" "diskutil list"
run_cmd "mounted_volumes" "mount"

# ----------------------
# 5. USER ENUMERATION
# ----------------------
run_cmd "who" "who"
run_cmd "w" "w"
run_cmd "id" "id"
run_cmd "last_logins" "last | head -n 200"
run_cmd "local_users" "dscl . list /Users"
run_cmd "admin_group" "dscl . -read /Groups/admin GroupMembership"

# ----------------------
# 6. PROCESS COLLECTION
# ----------------------
run_cmd "process_list" "ps auxww"
run_cmd "process_tree" "ps -axo pid,ppid,user,command"
run_cmd "launchctl_list" "launchctl list"

# ----------------------
# 7. NETWORK INFORMATION
# ----------------------
run_cmd "netstat_anv" "netstat -anv"
run_cmd "lsof_network" "lsof -nP -i"
run_cmd "ifconfig_all" "ifconfig -a"
run_cmd "route_table" "netstat -rn"
run_cmd "arp_table" "arp -a"
run_cmd "dns_configuration" "scutil --dns"
run_cmd "hosts_file" "cat /etc/hosts"

# ----------------------
# 8. PERSISTENCE CHECKS
# ----------------------
run_cmd "launch_agents_user_listing" "find /Users -path '*/Library/LaunchAgents/*' -maxdepth 4 -type f 2>/dev/null"
run_cmd "launch_agents_system_listing" "find /Library/LaunchAgents -type f 2>/dev/null"
run_cmd "launch_daemons_listing" "find /Library/LaunchDaemons -type f 2>/dev/null"
run_cmd "system_launch_daemons_listing" "find /System/Library/LaunchDaemons -type f 2>/dev/null"
run_cmd "system_launch_agents_listing" "find /System/Library/LaunchAgents -type f 2>/dev/null"
run_cmd "login_items_global" "defaults read /Library/Preferences/com.apple.loginwindow AutoLaunchedApplicationDictionary 2>/dev/null"
run_cmd "cron_list" "for u in \$(dscl . list /Users | grep -v '^_'); do echo '---' \$u '---'; crontab -u \$u -l 2>/dev/null; done"
run_cmd "at_jobs" "atq 2>/dev/null"
run_cmd "periodic_conf" "cat /etc/crontab 2>/dev/null; echo; ls -la /etc/periodic 2>/dev/null"

# ----------------------
# 9. PLIST / PERSISTENCE CONTENT
# ----------------------
run_cmd "launch_agents_system_content" "for f in /Library/LaunchAgents/*.plist(N); do echo '=====' \$f '====='; plutil -p \$f 2>/dev/null; done"
run_cmd "launch_daemons_content" "for f in /Library/LaunchDaemons/*.plist(N); do echo '=====' \$f '====='; plutil -p \$f 2>/dev/null; done"

# ----------------------
# 10. INSTALLED SOFTWARE
# ----------------------
run_cmd "applications_listing" "find /Applications -maxdepth 2 -name '*.app' 2>/dev/null"
run_cmd "system_profiler_apps" "system_profiler SPApplicationsDataType"
run_cmd "pkgutil_packages" "pkgutil --pkgs"

# ----------------------
# 11. USER ACTIVITY
# ----------------------
run_cmd "zsh_history_all_users" "for h in /Users/*/.zsh_history(N); do echo '=====' \$h '====='; cat \$h; echo; done"
run_cmd "bash_history_all_users" "for h in /Users/*/.bash_history(N); do echo '=====' \$h '====='; cat \$h; echo; done"
run_cmd "recent_items_listing" "find /Users -path '*/Library/Application Support/com.apple.sharedfilelist/*' 2>/dev/null"
run_cmd "downloads_listing" "find /Users -path '*/Downloads/*' -maxdepth 3 2>/dev/null"
run_cmd "documents_listing" "find /Users -path '*/Documents/*' -maxdepth 3 2>/dev/null"

# ----------------------
# 12. LOG COLLECTION
# ----------------------
run_cmd "unified_log_recent" "log show --style syslog --last 2h 2>/dev/null | head -n 5000"
run_cmd "install_log" "cat /var/log/install.log 2>/dev/null | tail -n 500"
run_cmd "system_log_tail" "log show --style syslog --last 1h --predicate 'eventMessage contains[c] \"error\" OR eventMessage contains[c] \"failed\"' 2>/dev/null | head -n 3000"

# ----------------------
# 13. SAFARI / BROWSER BASIC ARTIFACTS
# ----------------------
run_cmd "safari_history_files" "find /Users -path '*/Library/Safari/*' 2>/dev/null"
run_cmd "browser_support_files" "find /Users -path '*/Library/Application Support/Google/Chrome/*' -o -path '*/Library/Application Support/Firefox/*' 2>/dev/null"

# ----------------------
# 14. FILE SYSTEM COLLECTION
# ----------------------
echo "[*] Processing: file_listing_users (this may take a while...)"
FILE_LIST_CSV="$OUTPUT_DIR/file_listing_users.csv"
{
  echo "FullName,Size,ModifiedTime,AccessTime,ChangeTime"
  find /Users -type f 2>/dev/null | while IFS= read -r f; do
    stat -f "\"%N\",%z,\"%Sm\",\"%Sa\",\"%Sc\"" -t "%Y-%m-%d %H:%M:%S" "$f" 2>/dev/null
  done
} > "$FILE_LIST_CSV"

if [[ $? -eq 0 ]]; then
  echo "[+] Completed: file_listing_users"
else
  echo "[!] Failed: file_listing_users"
fi

# ----------------------
# 15. SECURITY / EXTENSIONS
# ----------------------
run_cmd "loaded_kexts" "kextstat 2>/dev/null"
run_cmd "system_extensions" "systemextensionsctl list 2>/dev/null"
run_cmd "profiles_status" "profiles status -type enrollment 2>/dev/null; echo; profiles list 2>/dev/null"
run_cmd "spctl_assessments" "spctl --status 2>/dev/null"

# ----------------------
# 16. HASH OUTPUT FILES
# ----------------------
echo "[*] Processing: hashes"
HASH_FILE="$OUTPUT_DIR/hashes.txt"
{
  echo "========================================="
  echo "SHA256 Hashes"
  echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "========================================="
  find "$OUTPUT_DIR" -type f ! -name "hashes.txt" -exec shasum -a 256 {} \;
} > "$HASH_FILE" 2>&1

if [[ $? -eq 0 ]]; then
  echo "[+] Completed: hashes"
else
  echo "[!] Failed: hashes"
fi

# ----------------------
# 17. ZIP OUTPUT
# ----------------------
echo "[*] Processing: zip_archive"
ZIP_FILE="${OUTPUT_DIR}.zip"
ditto -c -k --sequesterRsrc --keepParent "$OUTPUT_DIR" "$ZIP_FILE" 2>/dev/null

if [[ $? -eq 0 ]]; then
  echo "[+] Completed: zip_archive"
else
  echo "[!] Failed: zip_archive"
fi

# ----------------------
# 18. COMPLETE
# ----------------------
echo ""
echo "[+] IR Collection Complete at: $(date '+%Y-%m-%d %H:%M:%S')"
echo "[+] Results saved to:"
echo "$OUTPUT_DIR"
echo "[+] Archive saved to:"
echo "$ZIP_FILE"
