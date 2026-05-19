# Known Issues & PowerShell Gotchas

This document tracks known parser pitfalls, version incompatibilities and naming
conventions that apply to all scripts in this repository and downstream projects.

---

## Naming Convention for Scripts

| Suffix | Meaning | Requires |
|---|---|---|
| `*.ps1` | Default — PS 5.1 compatible | `powershell.exe` >= 5.1 (built into Windows 10/11) |
| `*.pwsh7.ps1` | Requires PowerShell Core | `pwsh.exe` >= 7.x (`winget install Microsoft.PowerShell`) |
| `*.pwsh74.ps1` | Requires PowerShell 7.4 LTS | `pwsh.exe` >= 7.4 |

**Rule:** If a script uses any PS7-only feature, rename it with the `.pwsh7.ps1` suffix
and add `#Requires -Version 7` at the top. Never silently depend on PS7 in a `*.ps1` file.

---

## PS 5.1 Baseline

PS 5.1 (`powershell.exe`) ships with **every Windows 10 and Windows 11** installation.
It requires no internet, no winget, no elevation to run basic scripts.
This makes it the correct default baseline for bootstrap and diagnostic scripts.

### What works fine in PS 5.1
- `Get-Disk`, `Get-Partition`, `Get-Volume` (requires elevation)
- `Get-Credential`, `Export-Clixml`, `Import-Clixml` (DPAPI credential caching)
- `New-PSDrive` with `-Credential` for NAS shares
- `Export-Csv -NoTypeInformation` (always add `-NoTypeInformation` in 5.1)
- `#Requires -RunAsAdministrator`
- `Start-Process -Verb RunAs`

### What requires PS 7+ (`pwsh.exe`)
- `ForEach-Object -Parallel` — parallel processing
- `&&` and `||` pipeline chain operators
- `Get-Error` — detailed error introspection
- `Invoke-WebRequest` improvements (HTTP/2, redirect handling)
- Ternary operator `$x ? $a : $b`
- `??=` null coalescing assignment

---

## Gotcha: Drive Letter Variable Interpolation

**Symptom:**
```
Invalid variable reference. ':' is not a valid character for a variable name.
```

**Cause:** PowerShell's string interpolation stops at `:` when expanding `$variable`.

**Wrong:**
```powershell
$drive = "Z"
$path  = "$drive:\SomePath"     # Parser reads $drive: as variable name -> ERROR
```

**Correct:**
```powershell
$drive = "Z"
$path  = "${drive}:\SomePath"   # Explicit boundary -> OK
# or
$path  = $drive + ":\SomePath"  # Concatenation -> always safe
```

**Rule:** Whenever a variable is immediately followed by `:` in a string,
always use `${variableName}` or string concatenation.

---

## Gotcha: Export-Csv in PS 5.1

**Wrong (adds `#TYPE` header line in 5.1):**
```powershell
$data | Export-Csv output.csv
```

**Correct (always):**
```powershell
$data | Export-Csv output.csv -NoTypeInformation -Encoding UTF8
```

---

## Gotcha: Format-Table Truncation

Long strings (file paths, UNC paths, GUIDs) are silently truncated with `...`
when using `Format-Table`.

**Wrong for long values:**
```powershell
$items | Format-Table FullName, Size   # FullName gets cut off
```

**Correct options:**
```powershell
# Option 1: Format-List (never truncates)
$items | Format-List FullName, Size

# Option 2: Export to CSV (always full values)
$items | Export-Csv output.csv -NoTypeInformation -Encoding UTF8

# Option 3: -Wrap flag (wraps instead of truncating)
$items | Format-Table FullName, Size -Wrap
```

**Rule:** Never use `Format-Table` for output that will be read programmatically
or that contains long strings. Use `Export-Csv` or `Format-List` instead.

---

## Bootstrap Decision Tree

```
Fresh Windows 10/11
    |
    +-- powershell.exe 5.1 available? --> YES (always) --> run *.ps1 scripts
    |
    +-- winget available? --------------> Check: winget --version
    |   NO --> https://aka.ms/getwinget  (requires Windows 10 1709+)
    |
    +-- git available? -----------------> winget install Git.Git
    |
    +-- pwsh 7+ needed? ----------------> winget install Microsoft.PowerShell
    |   (only for *.pwsh7.ps1 scripts)
    |
    +-- Windows Terminal? (optional) ---> winget install Microsoft.WindowsTerminal
```

---

## Version Reference

| Component | Version | Ships with | Notes |
|---|---|---|---|
| PowerShell 5.1 | 5.1.x | Windows 10, Windows 11 | Baseline. Always available. |
| PowerShell 7.4 | 7.4.x | — | LTS. Install via winget. |
| PowerShell 7.5 | 7.5.x | — | Current stable (2025/26). |
| winget | 1.x+ | Windows 10 1709+ (via Store update) | Required for tool installs. |
| Windows Terminal | 1.x+ | Windows 11 (built-in) | Optional on Win10. |
| git | 2.x+ | — | Install via winget. |
