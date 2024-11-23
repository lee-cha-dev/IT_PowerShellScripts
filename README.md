---

# IT_PowerShellScripts

## Overview
This repository contains PowerShell scripts designed for IT tasks, including automation of repetitive processes, accessing Active Directory, and remotely managing user computers. These scripts are categorized as **StandAlone** or **Load Into Profile** for different use cases.

---

## StandAlone
- Basic scripts intended for individual, stand-alone execution.
- Primarily shared for educational and collaborative purposes, rather than for personal day-to-day use.

---

## Load Into Profile
- Core scripts used daily to streamline IT operations.
- Automates predictable or time-consuming tasks.
- Integrated into the user profile via a lightweight snippet:
  - Automatically loads child scripts into the PowerShell shell.
  - Logs success or failure for each script.
  - Initialization takes ~20–30 seconds, but once PowerShell is open, commands execute instantly.
  - This method is more workflow-friendly compared to invoking standalone `.ps1` scripts.

---

## Important Disclaimer
**USE AT YOUR OWN RISK**  
These scripts are **not intended for execution without a thorough review** of the code and **explicit permission** from all relevant parties.  

- Some scripts access **Active Directory**.
- The majority involve remote access to other users' computers.  

By using these scripts, you agree to take full responsibility for their implementation and comply with all applicable laws and organizational policies.

---
