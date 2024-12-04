Here’s a draft README for your PowerShell project, based on the contents of the uploaded script:

---

# LoadIntoProfile - PowerShell IT Automation Scripts

## Overview

The **LoadIntoProfile** project provides a comprehensive suite of PowerShell scripts designed for automating IT Tier 1/2 tasks. These scripts enhance efficiency by handling common administrative tasks such as software installations, system cleanups, Active Directory account management, and hardware diagnostics.

## Features

- **Script Loading Automation**: Dynamically loads all PowerShell scripts in the specified development directory for quick access and execution.
- **Software Management**:
  - Automates downloads and installations for popular tools like VMware Horizon, Adobe Acrobat, GlobalProtect, Zoom, and more.
  - Uses secure TLS 1.2 connections for file downloads.
- **Active Directory Integration**: Includes tools for unlocking user accounts and retrieving user information.
- **System Cleanup**: Aggressively removes temporary files, caches, and logs to free up system space and improve performance.
- **Hardware Diagnostics**: Retrieves detailed hardware and system information, including BIOS, motherboard, processor, disk drives, and network configuration.
- **Flexible Customization**: Modular design allows users to add or modify functionality with minimal effort.
- **Error Handling**: Extensive error handling ensures smooth execution, with detailed logs for troubleshooting.

## Requirements

- PowerShell 5.0 or higher.
- Administrative privileges for certain operations (e.g., cleaning temporary files, installing software).
- Network connectivity for downloading files.
- Active Directory module (for scripts involving AD operations).

## Getting Started

1. **Clone or Download**: 
   - Clone this repository or download the ZIP file to your local machine.
2. **Prepare JSON Configuration**:
   - Add a `install_paths.json` file in the `LoadIntoProfile` directory to define installer paths, documentation links, and server names for software.
3. **Set Development Path**:
   - Update the `$DevPath` variable in the script to point to your local `LoadIntoProfile` folder.
4. **Run the Loader**:
   - Execute the main script to dynamically load all modules:  
     ```powershell
     .\LoadIntoProfile.ps1
     ```
5. **Execute Functions**:
   - Use the provided functions interactively or incorporate them into larger workflows.

## Key Functions

| **Function**          | **Description**                                                                 |
|------------------------|---------------------------------------------------------------------------------|
| `Downloads`           | Displays a list of available software downloads.                                |
| `DownloadVMWare`      | Downloads and installs VMware Horizon Client.                                   |
| `DownloadGlobalProtect` | Downloads and installs Palo Alto GlobalProtect VPN client.                    |
| `DownloadAdobeAcrobat` | Downloads and installs Adobe Acrobat Reader.                                   |
| `CleanDevice`         | Frees up disk space by cleaning temporary files, caches, and logs.             |
| `UnlockAccount`       | Unlocks an Active Directory user account.                                       |
| `ParseJson`           | Parses installation paths and metadata from `install_paths.json`.              |
| `UpgradeZoom`         | Upgrades Zoom client by uninstalling the old version and installing the latest. |
| `Get-Hardware`        | Retrieves detailed hardware information from a specified host.                 |

## Disclaimer

This project is licensed for personal and educational use only. Commercial use is strictly prohibited without prior written consent and agreement on royalties or purchase.

- **Warranty**: This script is provided "as is," without warranty of any kind. Use at your own risk.
- **Liability**: The author is not responsible for any damage, data loss, or other issues arising from use or misuse of the scripts.
- **Assumptions**: It is assumed that users have a mid-to-senior level software engineering skillset.

## License

© 2024 Lee Charles  
All Rights Reserved.  

Redistribution, modification, or inclusion in proprietary works is strictly prohibited without explicit permission.

---

Let me know if there’s anything else you’d like to add or adjust!