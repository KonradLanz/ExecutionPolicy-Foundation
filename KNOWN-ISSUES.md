# Known Issues & PowerShell Gotchas

This document tracks known parser pitfalls, version incompatibilities and naming
conventions that apply to all scripts in this repository and downstream projects.

---

## Naming Convention for Scripts

| Suffix | Meaning | Requires |
|---|---|---|
| `*.ps1` | Default - PS 5.1 compatible | `powershell.exe` >= 5.1 (built into Windows 10/11) |
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
- `ForEach-Object -Parallel` -- parallel processing
- `&&` and `||` pipeline chain operators
- `Get-Error` -- detailed error introspection
- `Invoke-WebRequest` improvements (HTTP/2, redirect handling)
- Ternary operator `$x ? $a : $b`
- `??=` null coalescing assignment
- **Null-conditional member access `?.` and `?[]`** (see Gotcha below)

---

## Gotcha: Null-Conditional Member Access `?.` (NEW - found in production 2026-06)

**Symptom:**
```
Unerwartetes Token "?.Source" in Ausdruck oder Anweisung.
    + CategoryInfo : ParserError: (:) [], ParseException
    + FullyQualifiedErrorId : UnexpectedToken
```

**Cause:** The null-conditional operators `?.` (member access) and `?[]` (index)
were introduced in **PowerShell 7.1**. PS 5.1 does not recognise `?.` at all and
throws a ParseException - the script never runs, not even partially.

**This is a silent PS7 dependency** - the script declares `#Requires -Version 5.1`
but uses `?.`, making it fail immediately on every stock Windows machine.

**Wrong (PS7-only):**
```powershell
$ollamaPath = (Get-Command ollama -ErrorAction SilentlyContinue)?.Source
```

**Correct (PS 5.1+):**
```powershell
$ollamaCmd = Get-Command ollama -ErrorAction SilentlyContinue
if ($ollamaCmd) {
    $ollamaPath = $ollamaCmd.Source
}
```

**Or with a null coalesce pattern:**
```powershell
# PS 5.1 compatible null-coalesce
$ollamaPath = if ($ollamaCmd) { $ollamaCmd.Source } else { "" }
```

**Rule:** Never use `?.` or `?[]` in a plain `*.ps1` file.
Add `?.` to your PS7-only feature list and code review checklist.

---

## Gotcha: Unicode Quotes in Write-Host Strings (NEW - found in production 2026-06)

**Symptom:**
```
Die Zeichenfolge hat kein Abschlusszeichen: ".
    + CategoryInfo : ParserError: (:) [], ParseException
    + FullyQualifiedErrorId : TerminatorExpectedAtEndOfString
```

**Cause:** When a `.ps1` file is written or edited by a tool that substitutes
ASCII double-quotes `"` with Unicode typographic quotes (`\u201C` `"` and `\u201D` `"`),
PS 5.1 cannot parse the file. PS 7.2+ silently accepts both forms in most contexts,
masking the bug.

**Affected tools:** GitHub web editor auto-correct, some AI code generation outputs,
copy-paste from Word / rich-text editors, VS Code with smart-quotes extensions.

**Wrong (breaks PS 5.1):**
```powershell
Write-Host "   (ollama list fehlgeschlagen)"   # contains U+201C / U+201D
```

**Correct (always):**
```powershell
Write-Host "   (ollama list fehlgeschlagen)"   # plain ASCII 0x22
```

**How to detect:** Open the file in VS Code, enable "Show Whitespace / Encoding".
Or in PowerShell itself:
```powershell
# Shows any non-ASCII quote characters in a PS1 file
Select-String -Path .\script.ps1 -Pattern '[\u201C\u201D\u2018\u2019]'
```

**Rule:** Always write `.ps1` files with **plain ASCII quotes only**.
When generating or committing scripts via API / AI tooling, use CRLF line endings
and verify no Unicode quote substitution occurred.
The `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` line at the top
of a script fixes *output* encoding but does **not** fix the source file parser.

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
| PowerShell 7.4 | 7.4.x | -- | LTS. Install via winget. |
| PowerShell 7.5 | 7.5.x | -- | Current stable (2025/26). |
| winget | 1.x+ | Windows 10 1709+ (via Store update) | Required for tool installs. |
| Windows Terminal | 1.x+ | Windows 11 (built-in) | Optional on Win10. |
| git | 2.x+ | -- | Install via winget. |
