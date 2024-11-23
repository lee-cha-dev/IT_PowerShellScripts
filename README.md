# IT_PowerShellScripts

## StandAlone

- Basic scripts to run as stand alone
- This is more for sharing than personal use.

## Load Into Profile

- These are the primary scripts that I use in day to day IT tasks.
- In the process of automating most tasks that are predictable or take up unnecessary time.
- I upload these using a small snippet placed into the user profile.
  - It more or less just grabs the child elements and loads them into the shell.
  - Logging success/failure per file.
  - Takes ~20-30 seconds, but if the PowerShell is left open the commands kick off without delay
  - I find this is much more efficient than calling a PS1 script - that tends to break my workflow

**USE AT YOUR OWN RISK -- THESE SCRIPTS ARE ABSOLUTELY NOT MEANT TO BE EXECUTED WITHOUT A GOOD REVIEW OF THE CODE & EXPLICIT PERMISSION FROM ALL PARTIES**
- Some of the scripts access the Active Directory and the majority of them will access another user's computer remotely.
