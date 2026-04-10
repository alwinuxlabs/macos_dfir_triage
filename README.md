# 🍎 macOS DFIR Triage Script v1.0

Lightweight zsh-based DFIR triage script for rapid incident response collection on macOS systems.

* **Author:** Alwin Espiritu (`alwinux`)
* **Date:** 2026-04-10

![License](https://img.shields.io/badge/license-MIT-green)

---

## ⚠️ Disclaimer

This tool is intended for **authorized digital forensic and incident response activities only**.
Unauthorized use may violate applicable laws and regulations.

---

## 🚀 Quick Start

1. Clone the repository:

```bash
git clone https://github.com/alwinuxlabs/macos-dfir-triage.git
cd macos-dfir-triage
```

2. Make the script executable:

```bash
chmod +x ./macos-dfir-triage.sh
```

3. Run the script with elevated privileges:

```bash
sudo ./macos-dfir-triage.sh
```

> 🔐 Root privileges (`sudo`) are required for more complete artifact collection.
> ⚙️ The script also checks whether it is executable and whether it is running with sufficient privileges.

---

## 📌 Features

* System information collection
* User and administrator enumeration
* Process listing and process tree
* Network artifacts:

  * netstat
  * lsof network connections
  * DNS configuration
  * Hosts file
* Persistence checks:

  * LaunchAgents (user & system)
  * LaunchDaemons
  * Login items
  * Cron jobs / periodic tasks
* Persistence plist content collection
* Installed applications and package inventory
* Event and unified log collection
* Shell history collection (zsh, bash)
* User activity collection:

  * recent items
  * downloads
  * documents
* Browser artifact path discovery (Safari, Chrome, Firefox)
* File system triage for `/Users`
* Environment variables and mounted volumes
* Kernel extensions and system extensions
* SHA256 hashing of collected output
* Automatic ZIP packaging of results

---

## ⚙️ Requirements

* macOS
* zsh shell
* Root privileges (`sudo`)

---

## 📂 Output

The script generates a timestamped directory:

```text
DFIR_Output_YYYY-MM-DD_HH-MM-SS
```

Each file includes:

* Command executed
* Timestamp
* Raw command output

Additionally:

* A compressed archive (`.zip`) of the output is created
* SHA256 hashes are generated for integrity verification

---

## 📄 Collected Artifacts

### 🖥️ System Information

* `hostname.txt`
* `sw_vers.txt`
* `uname_a.txt`
* `system_profiler_hardware.txt`
* `system_profiler_software.txt`
* `uptime.txt`
* `date.txt`
* `env_variables.txt`
* `diskutil_list.txt`
* `mounted_volumes.txt`

---

### 👤 User Enumeration

* `who.txt`
* `w.txt`
* `id.txt`
* `last_logins.txt`
* `local_users.txt`
* `admin_group.txt`

---

### ⚙️ Process Collection

* `process_list.txt`
* `process_tree.txt`
* `launchctl_list.txt`

---

### 🌐 Network Information

* `netstat_anv.txt`
* `lsof_network.txt`
* `ifconfig_all.txt`
* `route_table.txt`
* `arp_table.txt`
* `dns_configuration.txt`
* `hosts_file.txt`

---

### 🔐 Persistence Checks

* `launch_agents_user_listing.txt`
* `launch_agents_system_listing.txt`
* `launch_daemons_listing.txt`
* `system_launch_daemons_listing.txt`
* `system_launch_agents_listing.txt`
* `login_items_global.txt`
* `cron_list.txt`
* `at_jobs.txt`
* `periodic_conf.txt`

---

### 🧠 Persistence Content

* `launch_agents_system_content.txt`
* `launch_daemons_content.txt`

---

### 📦 Installed Software

* `applications_listing.txt`
* `system_profiler_apps.txt`
* `pkgutil_packages.txt`

---

### 🧪 User Activity

* `zsh_history_all_users.txt`
* `bash_history_all_users.txt`
* `recent_items_listing.txt`
* `downloads_listing.txt`
* `documents_listing.txt`

---

### 📜 Logs

* `unified_log_recent.txt`
* `install_log.txt`
* `system_log_tail.txt`

---

### 🌐 Browser Artifacts

* `safari_history_files.txt`
* `browser_support_files.txt`

---

### 📁 File System

* `file_listing_users.csv`
  *(Includes: FullName, Size, ModifiedTime, AccessTime, ChangeTime)*

---

### 🔐 Security & System State

* `loaded_kexts.txt`
* `system_extensions.txt`
* `profiles_status.txt`
* `spctl_assessments.txt`

---

### 🔐 Integrity

* `hashes.txt`
  *(SHA256 hashes of collected files)*

---

### 📦 Archive

* `DFIR_Output_YYYY-MM-DD_HH-MM-SS.zip`

---

## ⚠️ Notes & Limitations

* Some macOS privacy controls may restrict access to certain user data even when running with `sudo`
* Unified logs can be large, so output is intentionally limited for performance
* File system triage for `/Users` may take time depending on system size
* Some commands may return less data depending on macOS version and security settings
* Designed for **triage collection**, not full forensic imaging

---

## 🧠 Use Cases

* Incident Response (IR)
* Threat Hunting
* Live Response Collection
* Malware Investigations on macOS systems

---

## 🔍 Investigation Tips (DFIR Insight)

* Review `lsof_network.txt` for suspicious network connections
* Analyze `process_tree.txt` for unusual parent-child relationships
* Inspect LaunchAgents and LaunchDaemons for persistence mechanisms
* Check `zsh_history_all_users.txt` and `bash_history_all_users.txt` for suspicious commands
* Review `unified_log_recent.txt` for system and process activity
* Investigate `hosts_file.txt` for possible DNS manipulation
* Look at `pkgutil_packages.txt` and `applications_listing.txt` for suspicious installs

---

## 📜 License

MIT License

---

## 🙌 Acknowledgements

Built for DFIR practitioners and security teams to accelerate macOS live response and triage investigations.

---
