#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Hardening extremo de servicios Windows - CIS Benchmarks + NSA Guides + DISA STIG
.DESCRIPTION
    Lee el CSV de configuracion y aplica el estado recomendado a cada servicio.
    Compatible con el perfil detectado: COMODO + VeraCrypt + VMware + Defender.
    Intenta 3 metodos en cascada: Set-Service -> Registro -> sc.exe

    USO:
        .\Hardening-Services.ps1                     # Modo simulacion (recomendado primero)
        .\Hardening-Services.ps1 -Apply              # Aplicar cambios
        .\Hardening-Services.ps1 -BackupOnly         # Solo hacer backup del estado actual
        .\Hardening-Services.ps1 -Rollback -RollbackPath .\backup.csv
        .\Hardening-Services.ps1 -Report             # Solo generar reporte HTML
        powershell -ExecutionPolicy Bypass -File .\Hardening-Services.ps1 -Apply
.NOTES
    Version : 1.3 - External HTML template support
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Apply,
    [switch]$BackupOnly,
    [switch]$Rollback,
    [switch]$Report,
    [string]$CsvPath        = "services_hardening.csv",
    [string]$BackupPath     = "services_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv",
    [string]$RollbackPath   = "",
    [string]$ReportPath     = ".\out\hardening_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').html",
    [string]$TemplatePath   = "report_template.html"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# ---------------------------------------------------------------------------
#  HELPERS
# ---------------------------------------------------------------------------
function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host ("=" * 70) -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host ("=" * 70) -ForegroundColor Cyan
}
function Write-OK   { param($m) Write-Host "  [OK]      $m" -ForegroundColor Green }
function Write-Skip { param($m) Write-Host "  [SKIP]    $m" -ForegroundColor DarkGray }
function Write-Warn { param($m) Write-Host "  [WARN]    $m" -ForegroundColor Yellow }
function Write-Fail { param($m) Write-Host "  [ERROR]   $m" -ForegroundColor Red }
function Write-Info { param($m) Write-Host "  [INFO]    $m" -ForegroundColor White }
function Write-Sim  { param($m) Write-Host "  [SIM]     $m" -ForegroundColor Magenta }

function Get-StartupType {
    param([string]$Value)
    switch ($Value.Trim()) {
        "Automatic" { return "Automatic" }
        "Manual"    { return "Manual" }
        "Disabled"  { return "Disabled" }
        default     { return $null }
    }
}

# ---------------------------------------------------------------------------
#  SET SERVICE - TRIPLE FALLBACK
#  1) Set-Service  2) Registry (con ownership)  3) sc.exe
# ---------------------------------------------------------------------------
function Set-ServiceStartup {
    param(
        [string]$ServiceName,
        [string]$StartupType
    )

    $regValue = switch ($StartupType) {
        "Automatic" { 2 }
        "Manual"    { 3 }
        "Disabled"  { 4 }
    }
    $scArg = switch ($StartupType) {
        "Automatic" { "auto" }
        "Manual"    { "demand" }
        "Disabled"  { "disabled" }
    }

    try {
        Set-Service -Name $ServiceName -StartupType $StartupType -ErrorAction Stop
        return "SetService"
    }
    catch {}

    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"
    try {
        if (Test-Path $regPath) {
            $acl   = Get-Acl -Path $regPath
            $owner = [System.Security.Principal.NTAccount]"$env:USERDOMAIN\$env:USERNAME"
            $acl.SetOwner($owner)
            Set-Acl -Path $regPath -AclObject $acl -ErrorAction Stop
            $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
                $owner,
                [System.Security.AccessControl.RegistryRights]::FullControl,
                [System.Security.AccessControl.InheritanceFlags]::None,
                [System.Security.AccessControl.PropagationFlags]::None,
                [System.Security.AccessControl.AccessControlType]::Allow
            )
            $acl.SetAccessRule($rule)
            Set-Acl -Path $regPath -AclObject $acl -ErrorAction Stop
            Set-ItemProperty -Path $regPath -Name "Start" -Value $regValue -ErrorAction Stop
            return "Registry"
        }
    }
    catch {}

    $scOutput = & sc.exe config $ServiceName start= $scArg 2>&1
    if ($LASTEXITCODE -eq 0) { return "ScExe" }

    throw "All methods failed for '$ServiceName'. Last sc.exe error: $scOutput"
}

# ---------------------------------------------------------------------------
#  BACKUP
# ---------------------------------------------------------------------------
function Backup-Services {
    param([string]$Path)
    Write-Header "Backup current service state"
    $services = Get-Service | Select-Object Name, DisplayName, Status, StartType
    $services | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
    Write-OK "Backup saved: $Path"
    Write-Info "Total services saved: $($services.Count)"
}

# ---------------------------------------------------------------------------
#  ROLLBACK
# ---------------------------------------------------------------------------
function Invoke-Rollback {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        Write-Fail "Backup file not found: $Path"
        return
    }
    Write-Header "ROLLBACK - Restoring state from backup"
    $backup  = Import-Csv -Path $Path -Encoding UTF8
    $changes = 0
    foreach ($svc in $backup) {
        try {
            $current = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
            if ($null -eq $current) { continue }
            if ($current.StartType.ToString() -ne $svc.StartType) {
                $method = Set-ServiceStartup -ServiceName $svc.Name -StartupType $svc.StartType
                Write-OK "Restored [$method]: $($svc.Name) -> $($svc.StartType)"
                $changes++
            }
        }
        catch {
            Write-Fail "Error restoring $($svc.Name): $($_.Exception.Message)"
        }
    }
    Write-Info "Rollback complete. $changes services restored."
}

# ---------------------------------------------------------------------------
#  REPORTE HTML  (usa template externo)
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
#  REPORTE HTML  (usa template externo) - CORREGIDO
# ---------------------------------------------------------------------------
function ConvertTo-HtmlEncoded {
    param([string]$String)
    if ([string]::IsNullOrEmpty($String)) { return "" }
    # Escape manual de caracteres HTML
    return $String -replace '&', '&amp;' `
                   -replace '<', '&lt;'  `
                   -replace '>', '&gt;'  `
                   -replace '"', '&quot;' `
                   -replace "'", '&#39;'
}

function New-HtmlReport {
    param(
        [array]$Results,
        [string]$Path,
        [string]$Template
    )

    if (-not (Test-Path $Template)) {
        Write-Fail "HTML template not found: $Template"
        Write-Info "Place report_template.html in the same directory as this script."
        return
    }

    $html = Get-Content -Path $Template -Raw -Encoding UTF8

    # --- Build table rows ---
    $sb = [System.Text.StringBuilder]::new()
    foreach ($r in $Results) {
        $badgeClass = if ($r.Category -match '^(SYSTEM_CRITICAL|SECURITY_KEEP|WARNING|UPDATES|VMWARE|KEEP_AUDIO|DISABLE_TELEMETRY|DISABLE_GAMING|DISABLE_NETWORK|DISABLE_CRITICAL|DISABLE_BT|DISABLE_IF_UNUSED|DISABLE_MISC|CONFIRM_DISABLED|REVIEW)$') {
            "badge-$($r.Category)"
        } else { "badge-DEFAULT" }

        $statusHtml = switch ($r.Result) {
            "Applied"   { "<span class='status-applied'>[OK] Applied ($($r.Method))</span>" }
            "Skipped"   { "<span class='status-skipped'>[--] No change</span>" }
            "Error"     { "<span class='status-error'>[!!] Error</span>" }
            "Simulated" { "<span class='status-simulated'>[SIM] Simulated</span>" }
            "NotFound"  { "<span class='status-notfound'>[?] Not found</span>" }
            default     { $r.Result }
        }

        $resultKey = $r.Result.ToLower()
        
        # Usar función manual de escape HTML
        $escapedKey  = ConvertTo-HtmlEncoded -String $r.ServiceKey
        $escapedName = ConvertTo-HtmlEncoded -String $r.ServiceName
        $escapedNotes = ConvertTo-HtmlEncoded -String $r.Notes

        [void]$sb.AppendLine(
            "<tr data-key='$escapedKey' " +
                "data-name='$escapedName' " +
                "data-cat='$($r.Category)' " +
                "data-result='$resultKey'>" +
            "<td class='svckey'>$escapedKey</td>" +
            "<td>$escapedName</td>" +
            "<td class='center'><span class='badge $badgeClass'>$($r.Category)</span></td>" +
            "<td class='center'>$($r.Current)</td>" +
            "<td class='center'>$($r.Recommended)</td>" +
            "<td class='center'>$statusHtml</td>" +
            "<td class='notes'>$escapedNotes</td>" +
            "<tr>"
        )
    }

    # --- Counters ---
    $countTotal     = $Results.Count
    $countApplied   = @($Results | Where-Object { $_.Result -eq "Applied"   }).Count
    $countSkipped   = @($Results | Where-Object { $_.Result -eq "Skipped"   }).Count
    $countSimulated = @($Results | Where-Object { $_.Result -eq "Simulated" }).Count
    $countErrors    = @($Results | Where-Object { $_.Result -eq "Error"     }).Count
    $countNotFound  = @($Results | Where-Object { $_.Result -eq "NotFound"  }).Count

    # --- Replace placeholders ---
    $html = $html -replace '{{TABLE_ROWS}}',      $sb.ToString()
    $html = $html -replace '{{GEN_DATE}}',         (Get-Date -Format "dd/MM/yyyy HH:mm:ss")
    $html = $html -replace '{{COMP_NAME}}',        $env:COMPUTERNAME
    $html = $html -replace '{{COUNT_TOTAL}}',      $countTotal
    $html = $html -replace '{{COUNT_APPLIED}}',    $countApplied
    $html = $html -replace '{{COUNT_SKIPPED}}',    $countSkipped
    $html = $html -replace '{{COUNT_SIMULATED}}',  $countSimulated
    $html = $html -replace '{{COUNT_ERRORS}}',     $countErrors
    $html = $html -replace '{{COUNT_NOTFOUND}}',   $countNotFound

    $html | Out-File -FilePath $Path -Encoding UTF8
    Write-OK "HTML report generated: $Path"
}

# ---------------------------------------------------------------------------
#  PROCESAMIENTO PRINCIPAL
# ---------------------------------------------------------------------------
function Invoke-HardeningFromCsv {
    param([string]$CsvFile, [bool]$DryRun)

    if (-not (Test-Path $CsvFile)) {
        Write-Fail "CSV not found: $CsvFile"
        Write-Info "Make sure 'services_hardening.csv' is in the same directory as the script."
        exit 1
    }

    $config  = Import-Csv -Path $CsvFile -Encoding UTF8
    Write-Info "Services in CSV: $($config.Count)"

    $results = [System.Collections.Generic.List[PSCustomObject]]::new()
    $stats   = @{ Applied = 0; Skipped = 0; Errors = 0; NotFound = 0; Simulated = 0; Warnings = 0 }

    $catLabels = @{
        SYSTEM_CRITICAL   = "SYSTEM - CRITICAL (keep)"
        SECURITY_KEEP     = "SECURITY - Keep"
        WARNING           = "WARNINGS - Review"
        UPDATES           = "UPDATES"
        VMWARE            = "VMWARE (keep if using VMs)"
        KEEP_AUDIO        = "AUDIO (keep)"
        DISABLE_TELEMETRY = "DISABLE - Telemetry"
        DISABLE_GAMING    = "DISABLE - Xbox/Gaming"
        DISABLE_NETWORK   = "DISABLE - Network surface"
        DISABLE_CRITICAL  = "DISABLE - Security critical"
        DISABLE_BT        = "DISABLE - Bluetooth"
        DISABLE_IF_UNUSED = "DISABLE - If unused"
        DISABLE_MISC      = "DISABLE - Misc"
        CONFIRM_DISABLED  = "CONFIRMED disabled"
        REVIEW            = "REVIEW manually"
    }

    $categories = $config | Select-Object -ExpandProperty Category -Unique | Sort-Object

    foreach ($cat in $categories) {
        $catLabel = if ($catLabels.ContainsKey($cat)) { $catLabels[$cat] } else { $cat }
        Write-Header $catLabel

        $group = $config | Where-Object { $_.Category -eq $cat }

        foreach ($entry in $group) {
            $svcKey      = $entry.ServiceKey.Trim()
            $svcName     = $entry.ServiceName.Trim()
            $recommended = Get-StartupType $entry.RecommendedStartup
            $notes       = $entry.Notes.Trim()

            if ($null -eq $recommended) {
                Write-Warn "Unrecognized type for '$svcKey': $($entry.RecommendedStartup)"
                continue
            }

            $svc = Get-Service -Name $svcKey -ErrorAction SilentlyContinue

            if ($null -eq $svc) {
                Write-Skip "Not found: $svcKey"
                $stats.NotFound++
                $results.Add([PSCustomObject]@{
                    ServiceKey = $svcKey; ServiceName = $svcName
                    Category   = $cat;   Current     = "N/A"
                    Recommended = $recommended; Result = "NotFound"
                    Method     = "-";    Notes       = $notes
                })
                continue
            }

            $currentType = $svc.StartType.ToString()

            if ($cat -eq "WARNING" -or $cat -eq "REVIEW") {
                Write-Warn "$svcKey | Current: $currentType | Rec: $recommended | $notes"
                $stats.Warnings++
                $results.Add([PSCustomObject]@{
                    ServiceKey = $svcKey; ServiceName = $svcName
                    Category   = $cat;   Current     = $currentType
                    Recommended = $recommended; Result = "Skipped"
                    Method     = "-";    Notes       = $notes
                })
                continue
            }

            if ($currentType -eq $recommended) {
                Write-Skip "$svcKey | Already $recommended"
                $stats.Skipped++
                $results.Add([PSCustomObject]@{
                    ServiceKey = $svcKey; ServiceName = $svcName
                    Category   = $cat;   Current     = $currentType
                    Recommended = $recommended; Result = "Skipped"
                    Method     = "-";    Notes       = $notes
                })
                continue
            }

            if ($DryRun) {
                Write-Sim "$svcKey | $currentType -> $recommended | $notes"
                $stats.Simulated++
                $results.Add([PSCustomObject]@{
                    ServiceKey = $svcKey; ServiceName = $svcName
                    Category   = $cat;   Current     = $currentType
                    Recommended = $recommended; Result = "Simulated"
                    Method     = "-";    Notes       = $notes
                })
                continue
            }

            try {
                if ($recommended -eq "Disabled" -and $svc.Status -eq "Running") {
                    Stop-Service -Name $svcKey -Force -ErrorAction SilentlyContinue
                }
                $method = Set-ServiceStartup -ServiceName $svcKey -StartupType $recommended
                Write-OK "$svcKey | $currentType -> $recommended [$method]"
                $stats.Applied++
                $results.Add([PSCustomObject]@{
                    ServiceKey = $svcKey; ServiceName = $svcName
                    Category   = $cat;   Current     = $currentType
                    Recommended = $recommended; Result = "Applied"
                    Method     = $method; Notes      = $notes
                })
            }
            catch {
                Write-Fail "$svcKey | $($_.Exception.Message)"
                $stats.Errors++
                $results.Add([PSCustomObject]@{
                    ServiceKey = $svcKey; ServiceName = $svcName
                    Category   = $cat;   Current     = $currentType
                    Recommended = $recommended; Result = "Error"
                    Method     = "Failed"; Notes     = $_.Exception.Message
                })
            }
        }
    }

    return $results, $stats
}

# ---------------------------------------------------------------------------
#  MAIN
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "  ================================================" -ForegroundColor Cyan
Write-Host "   WINDOWS SERVICES HARDENING" -ForegroundColor Cyan
Write-Host "   CIS Benchmarks + NSA + DISA STIG" -ForegroundColor Cyan
Write-Host "   Methods: Set-Service / Registry / sc.exe" -ForegroundColor Cyan
Write-Host "  ================================================" -ForegroundColor Cyan
Write-Host ""

if ($Rollback) {
    if ($RollbackPath -eq "" -or -not (Test-Path $RollbackPath)) {
        Write-Fail "Specify -RollbackPath with the path to a backup CSV."
        Write-Info "Example: .\Hardening-Services.ps1 -Rollback -RollbackPath .\services_backup_20241201_120000.csv"
        exit 1
    }
    Invoke-Rollback -Path $RollbackPath
    exit 0
}

if ($BackupOnly) {
    Backup-Services -Path $BackupPath
    exit 0
}

if ($Report) {
    Write-Header "Report-only mode (simulation)"
    $rd, $sd = Invoke-HardeningFromCsv -CsvFile $CsvPath -DryRun $true
    New-HtmlReport -Results $rd -Path $ReportPath -Template $TemplatePath
    Start-Process $ReportPath
    exit 0
}

Backup-Services -Path $BackupPath

$dryRun = -not $Apply.IsPresent

if ($dryRun) {
    Write-Host ""
    Write-Host "  [!] SIMULATION MODE - No changes will be applied" -ForegroundColor Yellow
    Write-Host "      Run with -Apply to execute hardening" -ForegroundColor Yellow
    Write-Host ""
}
else {
    Write-Host ""
    Write-Host "  [APPLYING] Changes will be written to the system" -ForegroundColor Red
    Write-Host "  Backup saved to: $BackupPath" -ForegroundColor Yellow
    Write-Host ""
}

$resultsData, $statsData = Invoke-HardeningFromCsv -CsvFile $CsvPath -DryRun $dryRun

Write-Header "FINAL SUMMARY"
Write-Host ""
if ($dryRun) { Write-Host "  Mode           : SIMULATION (use -Apply to apply)" -ForegroundColor Yellow }
else         { Write-Host "  Mode           : APPLIED"                           -ForegroundColor Green }
Write-Host "  Applied        : $($statsData.Applied)"   -ForegroundColor Green
Write-Host "  No change      : $($statsData.Skipped)"   -ForegroundColor DarkGray
Write-Host "  Simulated      : $($statsData.Simulated)" -ForegroundColor Magenta
Write-Host "  Warnings       : $($statsData.Warnings)"  -ForegroundColor Yellow
Write-Host "  Not found      : $($statsData.NotFound)"  -ForegroundColor DarkYellow
Write-Host "  Errors         : $($statsData.Errors)"    -ForegroundColor Red
Write-Host ""

New-HtmlReport -Results $resultsData -Path $ReportPath -Template $TemplatePath

Write-Host ""
Write-Host "  Backup       : $BackupPath"  -ForegroundColor Cyan
Write-Host "  HTML Report  : $ReportPath"  -ForegroundColor Cyan
Write-Host ""

if ($dryRun) {
    Write-Host "  To apply hardening:" -ForegroundColor White
    Write-Host "    .\Hardening-Services.ps1 -Apply" -ForegroundColor Green
    Write-Host ""
    Write-Host "  To rollback after applying:" -ForegroundColor White
    $escapedPath = $BackupPath -replace '"', '`"'
    Write-Host "    .\Hardening-Services.ps1 -Rollback -RollbackPath `"$escapedPath`"" -ForegroundColor Green
    Write-Host ""
}
