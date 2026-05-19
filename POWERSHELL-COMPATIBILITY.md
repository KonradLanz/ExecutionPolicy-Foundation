# PowerShell Compatibility Guide

Quick reference for writing scripts that work on PS 5.1 and PS 7.x.

## The Rule

- **Default:** Write for PS 5.1. Every script ending in `.ps1` must run on `powershell.exe`.
- **Exception:** If PS7 features are genuinely needed, name the file `*.pwsh7.ps1`
  and add `#Requires -Version 7` at the top.
- **Never** silently use PS7 features in a plain `.ps1` file.

## Quick Compatibility Cheat Sheet

### String interpolation with drive letters
```powershell
# ALWAYS use ${} when variable is followed by :
$d = "Z"
"${d}:\path"   # correct
"$d:\path"     # ERROR in all PS versions
```

### Parallel processing
```powershell
# PS 7+ only -> use *.pwsh7.ps1
1..10 | ForEach-Object -Parallel { $_ * 2 }

# PS 5.1 fallback
1..10 | ForEach-Object { $_ * 2 }
```

### Null coalescing
```powershell
# PS 7+ only
$x = $null ?? "default"

# PS 5.1
$x = if ($null -ne $someVar) { $someVar } else { "default" }
```

### Ternary operator
```powershell
# PS 7+ only
$result = $condition ? "yes" : "no"

# PS 5.1
$result = if ($condition) { "yes" } else { "no" }
```

### Pipeline chain operators
```powershell
# PS 7+ only
git pull && git push

# PS 5.1
git pull
if ($LASTEXITCODE -eq 0) { git push }
```

### CSV export
```powershell
# Always add -NoTypeInformation in PS 5.1
$data | Export-Csv out.csv -NoTypeInformation -Encoding UTF8
```

### Checking PS version in script
```powershell
$isPS7 = $PSVersionTable.PSVersion.Major -ge 7
if (-not $isPS7) {
    # PS 5.1 fallback code
}
```

## Adding Test-PSEnvironment to your script

```powershell
# At the top of any script in this repo or downstream projects:
. (Join-Path $PSScriptRoot 'lib/Test-PSEnvironment.ps1')
$env = Test-PSEnvironment    # checks PS version, winget, git, Windows Terminal

# Or for a script that strictly needs PS7:
. (Join-Path $PSScriptRoot 'lib/Test-PSEnvironment.ps1')
$env = Test-PSEnvironment -RequirePS7
```
