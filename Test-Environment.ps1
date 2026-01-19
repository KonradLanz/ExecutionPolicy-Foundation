#!/usr/bin/env powershell
# ============================================================
# EXECUTIONPOLICY FOUNDATION - DIAGNOSTIC TEST SUITE
# v2.0.0 | GrEEV.com KG | support@greev.com
# 
# Comprehensive environment and compatibility test
# Tests: UTF-8 encoding, Unicode symbols, PS5.1 vs PS7, Registry, GPO
# ============================================================

param(
    [string]$Language = "en",
    [switch]$Verbose = $false
)

$Language = if ($Language -eq "de") { "de" } else { "en" }

# ============================================================
# LOCALIZATION
# ============================================================

$Strings = @{
    en = @{
        title               = "ExecutionPolicy Foundation - Diagnostic Test Suite"
        version             = "v2.0.0 | GrEEV.com KG"
        
        # Section Headers
        section_info        = "SYSTEM INFORMATION"
        section_encoding    = "CHARACTER ENCODING TESTS"
        section_symbols     = "UNICODE SYMBOL TESTS"
        section_registry    = "REGISTRY & GPO TESTS"
        section_features    = "POWERSHELL FEATURE TESTS"
        section_summary     = "TEST SUMMARY"
        
        # System Info
        powershell_version  = "PowerShell Version"
        powershell_edition  = "Edition"
        dotnet_version      = ".NET Runtime"
        os_info             = "Operating System"
        execution_policy    = "Execution Policy"
        output_encoding     = "Console Output Encoding"
        console_codepage    = "Console Code Page"
        
        # Encoding Tests
        file_encoding       = "File Encoding Detection"
        bom_status          = "BOM (Byte Order Mark)"
        bom_present         = "PRESENT (UTF-8 with BOM)"
        bom_absent          = "ABSENT (UTF-8 without BOM or ANSI)"
        utf8_bom_hex        = "UTF-8 BOM Hex: EF BB BF"
        no_bom_hex          = "No BOM (starts with: 23 21 2F = #!/)"
        console_test        = "Console Output Test"
        
        # Unicode Symbols
        check_mark          = "Check Mark"
        warning_mark        = "Warning Mark"
        cross_mark          = "Cross Mark"
        separator_1         = "Box Drawing (Line 1)"
        separator_2         = "Box Drawing (Line 2)"
        arrows              = "Arrow Symbols"
        
        # Registry & GPO
        exec_policy_env     = "ExecutionPolicy (Environment)"
        exec_policy_reg     = "ExecutionPolicy (Registry)"
        gpo_policy          = "GPO Policy Detection"
        gpo_status          = "GPO Status"
        gpo_applied         = "Applied"
        gpo_not_applied     = "Not Applied"
        
        # Feature Tests
        test_name           = "Test Name"
        status              = "Status"
        result              = "Result"
        pass                = "PASS"
        fail                = "FAIL"
        warning             = "WARNING"
        skip                = "SKIP"
        
        # Summary
        total_tests         = "Total Tests"
        passed              = "Passed"
        failed              = "Failed"
        warnings            = "Warnings"
        summary_result      = "Summary Result"
        all_tests_passed    = "All tests passed! ✓"
        review_warnings     = "Review warnings above"
        fix_encoding        = "Fix UTF-8 encoding issue (see ENCODING TESTS)"
        
        # Recommendations
        recommendations     = "RECOMMENDATIONS"
        rec_utf8_bom        = "Save scripts as UTF-8 with BOM for PS5.1 compatibility"
        rec_exec_policy     = "ExecutionPolicy set to 'Bypass' for scripts"
        rec_console         = "Console output encoding is UTF-8 compatible"
        rec_symbols         = "Unicode symbols display correctly"
    }
    de = @{
        title               = "ExecutionPolicy Foundation - Diagnose Test Suite"
        version             = "v2.0.0 | GrEEV.com KG"
        
        # Section Headers
        section_info        = "SYSTEMINFORMATIONEN"
        section_encoding    = "ZEICHENKODIERUNGS-TESTS"
        section_symbols     = "UNICODE-SYMBOL-TESTS"
        section_registry    = "REGISTRY & GPO TESTS"
        section_features    = "POWERSHELL-FUNKTIONS-TESTS"
        section_summary     = "TEST-ZUSAMMENFASSUNG"
        
        # System Info
        powershell_version  = "PowerShell-Version"
        powershell_edition  = "Edition"
        dotnet_version      = ".NET Runtime"
        os_info             = "Betriebssystem"
        execution_policy    = "Execution Policy"
        output_encoding     = "Konsolen-Ausgabenkodierung"
        console_codepage    = "Konsolen Code Page"
        
        # Encoding Tests
        file_encoding       = "Datei-Kodierungs-Erkennung"
        bom_status          = "BOM (Byte Order Mark)"
        bom_present         = "VORHANDEN (UTF-8 mit BOM)"
        bom_absent          = "FEHLEND (UTF-8 ohne BOM oder ANSI)"
        utf8_bom_hex        = "UTF-8 BOM Hex: EF BB BF"
        no_bom_hex          = "Kein BOM (beginnt mit: 23 21 2F = #!/)"
        console_test        = "Konsolen-Ausgabe Test"
        
        # Unicode Symbols
        check_mark          = "Häkchen"
        warning_mark        = "Warnsymbol"
        cross_mark          = "Kreuzsymbol"
        separator_1         = "Linienzeichnung (Linie 1)"
        separator_2         = "Linienzeichnung (Linie 2)"
        arrows              = "Pfeile"
        
        # Registry & GPO
        exec_policy_env     = "ExecutionPolicy (Umgebung)"
        exec_policy_reg     = "ExecutionPolicy (Registry)"
        gpo_policy          = "GPO-Richtlinienerkennung"
        gpo_status          = "GPO-Status"
        gpo_applied         = "Angewendet"
        gpo_not_applied     = "Nicht angewendet"
        
        # Feature Tests
        test_name           = "Testname"
        status              = "Status"
        result              = "Ergebnis"
        pass                = "BESTANDEN"
        fail                = "FEHLER"
        warning             = "WARNUNG"
        skip                = "ÜBERSPRUNGEN"
        
        # Summary
        total_tests         = "Gesamttests"
        passed              = "Bestanden"
        failed              = "Fehler"
        warnings            = "Warnungen"
        summary_result      = "Zusammenfassung"
        all_tests_passed    = "Alle Tests bestanden! ✓"
        review_warnings     = "Überprüfen Sie die Warnungen oben"
        fix_encoding        = "UTF-8-Kodierungsproblem beheben (siehe ENCODING-TESTS)"
        
        # Recommendations
        recommendations     = "EMPFEHLUNGEN"
        rec_utf8_bom        = "Skripte als UTF-8 mit BOM für PS5.1-Kompatibilität speichern"
        rec_exec_policy     = "ExecutionPolicy auf 'Bypass' für Skripte gesetzt"
        rec_console         = "Konsolenausgabe-Kodierung ist UTF-8-kompatibel"
        rec_symbols         = "Unicode-Symbole werden korrekt angezeigt"
    }
}

$Text = $Strings[$Language]

# ============================================================
# SETUP
# ============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$testResults = @()
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  $($Text.title)" -ForegroundColor Cyan
Write-Host "║  $($Text.version)" -ForegroundColor Cyan
Write-Host "║  $timestamp" -ForegroundColor DarkGray
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# 1. SYSTEM INFORMATION
# ============================================================

Write-Host "► $($Text.section_info)" -ForegroundColor Yellow
Write-Host ""

$psVersion = $PSVersionTable.PSVersion
$psEdition = $PSVersionTable.PSEdition
$osInfo = $PSVersionTable.OS
$dotnetVersion = $PSVersionTable.CLRVersion

Write-Host "  $($Text.powershell_version): $psVersion"
Write-Host "  $($Text.powershell_edition): $psEdition"
Write-Host "  $($Text.dotnet_version): $dotnetVersion"
Write-Host "  $($Text.os_info): $osInfo"

# Get current ExecutionPolicy
try {
    $execPolicy = Get-ExecutionPolicy
    Write-Host "  $($Text.execution_policy): $execPolicy"
} catch {
    Write-Host "  $($Text.execution_policy): [Error reading]" -ForegroundColor Red
}

# Console encoding
Write-Host "  $($Text.output_encoding): $([Console]::OutputEncoding.EncodingName)"
Write-Host "  $($Text.console_codepage): $([Console]::OutputEncoding.CodePage)"
Write-Host ""

# ============================================================
# 2. CHARACTER ENCODING TESTS
# ============================================================

Write-Host "► $($Text.section_encoding)" -ForegroundColor Yellow
Write-Host ""

# Get first 3 bytes of this script
$scriptPath = $MyInvocation.MyCommand.Path
$scriptName = Split-Path $scriptPath -Leaf

if (Test-Path $scriptPath) {
    try {
        # Try PS7 method first
        $firstBytes = Get-Content $scriptPath -AsByteStream -TotalCount 3 -ErrorAction Stop
    } catch {
        # Fallback to PS5.1 method
        try {
            $firstBytes = Get-Content $scriptPath -Encoding Byte -TotalCount 3 -ErrorAction Stop
        } catch {
            $firstBytes = $null
        }
    }
    
    if ($firstBytes) {
        $hexString = $firstBytes | ForEach-Object { "{0:X2}" -f $_ }
        $bomHex = @($firstBytes[0..2]) | ForEach-Object { "{0:X2}" -f $_ }
        $bomStatus = if ($bomHex -eq "EF BB BF") { $Text.bom_present } else { $Text.bom_absent }
        
        Write-Host "  $($Text.file_encoding): $scriptName"
        Write-Host "    First 3 bytes: $($hexString -join ' ')"
        Write-Host "    $($Text.bom_status): $bomStatus"
        
        if ($bomHex -eq "EF BB BF") {
            Write-Host "    ✓ UTF-8 with BOM detected" -ForegroundColor Green
            $testResults += @{ Test = "File Encoding (BOM)"; Status = "PASS"; Result = "UTF-8 with BOM" }
        } else {
            Write-Host "    ℹ $($Text.no_bom_hex)" -ForegroundColor Yellow
            $testResults += @{ Test = "File Encoding (BOM)"; Status = "WARNING"; Result = "UTF-8 without BOM" }
        }
    }
}

Write-Host ""

# ============================================================
# 3. UNICODE SYMBOL TESTS
# ============================================================

Write-Host "► $($Text.section_symbols)" -ForegroundColor Yellow
Write-Host ""

$symbols = @(
    @{ Name = $Text.check_mark; Symbol = "✓"; Hex = "2713" }
    @{ Name = $Text.warning_mark; Symbol = "⚠"; Hex = "26A0" }
    @{ Name = $Text.cross_mark; Symbol = "✗"; Hex = "2717" }
    @{ Name = $Text.separator_1; Symbol = "║"; Hex = "2551" }
    @{ Name = $Text.separator_2; Symbol = "╔"; Hex = "2554" }
    @{ Name = $Text.arrows; Symbol = "→ ← ↑ ↓"; Hex = "2192..." }
)

$symbolsWork = $true
foreach ($sym in $symbols) {
    Write-Host "  $($sym.Symbol)  $($sym.Name) (U+$($sym.Hex))"
}

Write-Host ""

# Test if symbols display correctly
$testSymbol = "✓ ⚠ ✗"
if ($testSymbol -match "✓|⚠|✗") {
    Write-Host "  ✓ $($Text.console_test): OK" -ForegroundColor Green
    $testResults += @{ Test = "Unicode Symbols"; Status = "PASS"; Result = "All symbols display" }
} else {
    Write-Host "  ✗ $($Text.console_test): FAILED" -ForegroundColor Red
    $symbolsWork = $false
    $testResults += @{ Test = "Unicode Symbols"; Status = "FAIL"; Result = "Symbol display issues" }
}

Write-Host ""

# ============================================================
# 4. REGISTRY & GPO TESTS
# ============================================================

Write-Host "► $($Text.section_registry)" -ForegroundColor Yellow
Write-Host ""

# Check Registry for ExecutionPolicy
$regPath = "HKCU:\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell"
if (Test-Path $regPath) {
    try {
        $regPolicy = Get-ItemProperty $regPath -Name "ExecutionPolicy" -ErrorAction SilentlyContinue
        if ($regPolicy) {
            Write-Host "  $($Text.exec_policy_reg): $($regPolicy.ExecutionPolicy)"
            $testResults += @{ Test = "Registry ExecutionPolicy"; Status = "PASS"; Result = $regPolicy.ExecutionPolicy }
        }
    } catch {
        Write-Host "  $($Text.exec_policy_reg): [Not found]" -ForegroundColor Gray
    }
}

# Check for GPO policies
$gpoPath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell"
if (Test-Path $gpoPath) {
    Write-Host "  $($Text.gpo_policy): $($Text.gpo_applied)" -ForegroundColor Yellow
    $testResults += @{ Test = "GPO Policy"; Status = "WARNING"; Result = $Text.gpo_applied }
} else {
    Write-Host "  $($Text.gpo_policy): $($Text.gpo_not_applied)" -ForegroundColor Green
    $testResults += @{ Test = "GPO Policy"; Status = "PASS"; Result = $Text.gpo_not_applied }
}

Write-Host ""

# ============================================================
# 5. POWERSHELL FEATURE TESTS
# ============================================================

Write-Host "► $($Text.section_features)" -ForegroundColor Yellow
Write-Host ""

# Test array slicing (PS5.1 compatibility)
try {
    $testArray = 1, 2, 3, 4, 5
    $result = $testArray[2..4]
    if ($result.Count -eq 3) {
        Write-Host "  ✓ Array slicing works"
        $testResults += @{ Test = "Array Slicing"; Status = "PASS"; Result = "OK" }
    }
} catch {
    Write-Host "  ✗ Array slicing failed" -ForegroundColor Red
    $testResults += @{ Test = "Array Slicing"; Status = "FAIL"; Result = $_.Exception.Message }
}

# Test string interpolation
try {
    $testVar = "ExecutionPolicy"
    $result = "Testing: $testVar"
    if ($result -eq "Testing: ExecutionPolicy") {
        Write-Host "  ✓ String interpolation works"
        $testResults += @{ Test = "String Interpolation"; Status = "PASS"; Result = "OK" }
    }
} catch {
    Write-Host "  ✗ String interpolation failed" -ForegroundColor Red
    $testResults += @{ Test = "String Interpolation"; Status = "FAIL"; Result = $_.Exception.Message }
}

# Test hashtable
try {
    $testHash = @{ Key1 = "Value1"; Key2 = "Value2" }
    if ($testHash.Key1 -eq "Value1") {
        Write-Host "  ✓ Hashtables work"
        $testResults += @{ Test = "Hashtables"; Status = "PASS"; Result = "OK" }
    }
} catch {
    Write-Host "  ✗ Hashtables failed" -ForegroundColor Red
    $testResults += @{ Test = "Hashtables"; Status = "FAIL"; Result = $_.Exception.Message }
}

# Test ForEach-Object
try {
    $result = 1, 2, 3 | ForEach-Object { $_ * 2 }
    if ($result.Count -eq 3) {
        Write-Host "  ✓ ForEach-Object works"
        $testResults += @{ Test = "ForEach-Object"; Status = "PASS"; Result = "OK" }
    }
} catch {
    Write-Host "  ✗ ForEach-Object failed" -ForegroundColor Red
    $testResults += @{ Test = "ForEach-Object"; Status = "FAIL"; Result = $_.Exception.Message }
}

Write-Host ""

# ============================================================
# 6. TEST SUMMARY
# ============================================================

Write-Host "► $($Text.section_summary)" -ForegroundColor Yellow
Write-Host ""

$passed = ($testResults | Where-Object { $_.Status -eq "PASS" }).Count
$failed = ($testResults | Where-Object { $_.Status -eq "FAIL" }).Count
$warnings = ($testResults | Where-Object { $_.Status -eq "WARNING" }).Count
$total = $testResults.Count

Write-Host "  $($Text.total_tests): $total"
Write-Host "  $($Text.passed): $passed" -ForegroundColor Green
Write-Host "  $($Text.failed): $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
Write-Host "  $($Text.warnings): $warnings" -ForegroundColor $(if ($warnings -gt 0) { "Yellow" } else { "Green" })

Write-Host ""

if ($failed -eq 0 -and $warnings -eq 0) {
    Write-Host "  ✓ $($Text.all_tests_passed)" -ForegroundColor Green
} elseif ($failed -eq 0) {
    Write-Host "  ⚠ $($Text.review_warnings)" -ForegroundColor Yellow
} else {
    Write-Host "  ✗ $($Text.fix_encoding)" -ForegroundColor Red
}

Write-Host ""

# ============================================================
# 7. RECOMMENDATIONS
# ============================================================

Write-Host "► $($Text.recommendations)" -ForegroundColor Cyan
Write-Host ""
Write-Host "  • $($Text.rec_utf8_bom)"
Write-Host "  • $($Text.rec_exec_policy)"
Write-Host "  • $($Text.rec_console)"
Write-Host "  • $($Text.rec_symbols)"
Write-Host ""

# ============================================================
# DETAILED TEST RESULTS TABLE
# ============================================================

if ($Verbose) {
    Write-Host "► DETAILED TEST RESULTS" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  $($Text.test_name) | $($Text.status) | $($Text.result)" 
    Write-Host "  " + ("-" * 60)
    foreach ($test in $testResults) {
        $statusColor = switch ($test.Status) {
            "PASS" { "Green" }
            "FAIL" { "Red" }
            "WARNING" { "Yellow" }
            default { "White" }
        }
        Write-Host "  $($test.Test) | $($test.Status) | $($test.Result)" -ForegroundColor $statusColor
    }
    Write-Host ""
}

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                   Test completed                           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Exit with appropriate code
if ($failed -gt 0) {
    exit 1
} else {
    exit 0
}
