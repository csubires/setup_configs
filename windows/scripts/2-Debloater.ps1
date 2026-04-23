##########################################################################
# Debloater Windows 10 - by 4t0m5K (extraido de ScriptPostInstall1.ps1)
# Genera informe HTML de simulacion antes de desinstalar
# Uso: .\Debloater.ps1 [-Simulate] [-CsvPath "ruta\bloatware_list.csv"]
##########################################################################

param(
    [switch]$Simulate,
    [string]$CsvPath = "$PSScriptRoot\bloatware_list.csv",
    [string]$ReportPath = ".\out\informe_debloat.html"
)

# ─────────────────────────────────────────────────────────────
# COMPROBACION DE ADMINISTRADOR
# ─────────────────────────────────────────────────────────────
function Test-Admin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]"Administrator")
}

if (-not (Test-Admin)) {
    Write-Host "`n[!] Ejecuta el script como Administrador." -ForegroundColor Red
    Exit 1
}

# ─────────────────────────────────────────────────────────────
# CARGA DEL CSV
# ─────────────────────────────────────────────────────────────
if (-not (Test-Path $CsvPath)) {
    Write-Host "`n[!] No se encontro el CSV en: $CsvPath" -ForegroundColor Red
    Write-Host "    Coloca 'bloatware_list.csv' en la misma carpeta que este script." -ForegroundColor Yellow
    Exit 1
}

$bloatList = Import-Csv -Path $CsvPath -Encoding UTF8
Write-Host "`n[*] CSV cargado: $($bloatList.Count) entradas encontradas." -ForegroundColor Cyan

# ─────────────────────────────────────────────────────────────
# OBTENER TODAS LAS APPS INSTALADAS (AppxPackage)
# ─────────────────────────────────────────────────────────────
Write-Host "[*] Obteniendo lista de aplicaciones instaladas..." -ForegroundColor Cyan
$installedApps = Get-AppxPackage -AllUsers | Select-Object Name, PackageFullName, Publisher, Version, InstallLocation

# ─────────────────────────────────────────────────────────────
# CRUZAR: que apps del CSV estan realmente instaladas
# ─────────────────────────────────────────────────────────────
$results = @()

foreach ($app in $installedApps) {
    $matchedBloat = $bloatList | Where-Object {
        $app.Name -like "*$($_.AppID)*" -or $app.Name -eq $_.AppID
    }

    $results += [PSCustomObject]@{
        Nombre         = $app.Name
        FullName       = $app.PackageFullName
        Version        = $app.Version
        Publisher      = $app.Publisher
        InstallPath    = $app.InstallLocation
        EnListaNegra   = if ($matchedBloat) { $true } else { $false }
        Categoria      = if ($matchedBloat) { $matchedBloat.Categoria } else { "Sistema / Usuario" }
        Descripcion    = if ($matchedBloat) { $matchedBloat.Nombre_Descripcion } else { $app.Name }
        Accion         = if ($matchedBloat) { "DESINSTALAR" } else { "Mantener" }
    }
}

# Apps del CSV que NO estan instaladas (ya eliminadas o no presentes)
foreach ($bloat in $bloatList) {
    $alreadyIn = $results | Where-Object { $_.Nombre -like "*$($bloat.AppID)*" }
    if (-not $alreadyIn) {
        $results += [PSCustomObject]@{
            Nombre       = $bloat.AppID
            FullName     = "-"
            Version      = "-"
            Publisher    = "-"
            InstallPath  = "-"
            EnListaNegra = $true
            Categoria    = $bloat.Categoria
            Descripcion  = $bloat.Nombre_Descripcion
            Accion       = "No instalada"
        }
    }
}

$toUninstall   = $results | Where-Object { $_.Accion -eq "DESINSTALAR" }
$toKeep        = $results | Where-Object { $_.Accion -eq "Mantener" }
$notInstalled  = $results | Where-Object { $_.Accion -eq "No instalada" }

Write-Host "[*] Apps a desinstalar: $($toUninstall.Count)" -ForegroundColor Red
Write-Host "[*] Apps a mantener:    $($toKeep.Count)"     -ForegroundColor Green
Write-Host "[*] No instaladas (ya limpias): $($notInstalled.Count)" -ForegroundColor DarkGray

# ─────────────────────────────────────────────────────────────
# ESCAPE HTML NATIVO (sin System.Web)
# ─────────────────────────────────────────────────────────────
function ConvertTo-HtmlSafe {
    param([string]$Text)
    if (-not $Text) { return "" }
    $Text = $Text -replace '&', '&amp;'
    $Text = $Text -replace '<', '&lt;'
    $Text = $Text -replace '>', '&gt;'
    $Text = $Text -replace '"', '&quot;'
    $Text = $Text -replace "'", '&#39;'
    return $Text
}

# ─────────────────────────────────────────────────────────────
# GENERAR INFORME HTML
# ─────────────────────────────────────────────────────────────
function New-HtmlReport {
    param($AllResults, $OutputPath)

    $timestamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    $hostname  = $env:COMPUTERNAME
    $user      = $env:USERNAME

    # Generar filas de la tabla
    $rows = ""
    foreach ($r in ($AllResults | Sort-Object Accion, Categoria, Nombre)) {
        $rowClass = switch ($r.Accion) {
            "DESINSTALAR"  { "row-danger" }
            "Mantener"     { "row-safe" }
            "No instalada" { "row-ghost" }
            default        { "" }
        }

        $badge = switch ($r.Accion) {
            "DESINSTALAR"  { '<span class="badge badge-danger">DESINSTALAR</span>' }
            "Mantener"     { '<span class="badge badge-safe">Mantener</span>' }
            "No instalada" { '<span class="badge badge-ghost">No instalada</span>' }
            default        { $r.Accion }
        }

        $catBadge = switch ($r.Categoria) {
            "Microsoft Bloat" { '<span class="cat cat-ms">Microsoft</span>' }
            "Xbox"            { '<span class="cat cat-xbox">Xbox</span>' }
            "Terceros"        { '<span class="cat cat-third">Terceros</span>' }
            "OneDrive"        { '<span class="cat cat-one">OneDrive</span>' }
            "Store"           { '<span class="cat cat-store">Store</span>' }
            default           { "<span class='cat cat-sys'>$($r.Categoria)</span>" }
        }

        $safeInstallPath = ConvertTo-HtmlSafe $r.InstallPath
        $safeFullName    = ConvertTo-HtmlSafe $r.FullName

        $rows += @"
        <tr class="$rowClass">
            <td>$catBadge</td>
            <td><strong>$($r.Descripcion)</strong><br><small class="mono">$($r.Nombre)</small></td>
            <td class="mono small">$safeFullName</td>
            <td class="center">$($r.Version)</td>
            <td class="path" title="$safeInstallPath">$($r.InstallPath -replace '.{50}$','...')</td>
            <td class="center">$badge</td>
        </tr>
"@
    }

    $countTotal      = $AllResults.Count
    $countDanger     = ($AllResults | Where-Object { $_.Accion -eq "DESINSTALAR" }).Count
    $countSafe       = ($AllResults | Where-Object { $_.Accion -eq "Mantener" }).Count
    $countGhost      = ($AllResults | Where-Object { $_.Accion -eq "No instalada" }).Count

    $html = @"
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Informe Debloater - $hostname</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Barlow:wght@300;400;600;700;900&display=swap');

  :root {
    --bg:        #0a0c10;
    --surface:   #0f1318;
    --border:    #1e2530;
    --accent:    #e63946;
    --accent2:   #00b4d8;
    --green:     #2dc653;
    --ghost:     #3a3f4b;
    --text:      #c9d1d9;
    --text-dim:  #8b949e;
    --mono:      'Share Tech Mono', monospace;
    --sans:      'Barlow', sans-serif;
  }

  * { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    background: var(--bg);
    color: var(--text);
    font-family: var(--sans);
    font-size: 14px;
    line-height: 1.6;
  }

  /* ── HEADER ── */
  header {
    background: linear-gradient(135deg, #0d1117 0%, #161b22 60%, #1a0810 100%);
    border-bottom: 2px solid var(--accent);
    padding: 40px 48px 32px;
    position: relative;
    overflow: hidden;
  }
  header::before {
    content: '';
    position: absolute;
    top: -80px; right: -80px;
    width: 320px; height: 320px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(230,57,70,.15) 0%, transparent 70%);
    pointer-events: none;
  }
  header .label {
    font-family: var(--mono);
    font-size: 11px;
    letter-spacing: 3px;
    color: var(--accent);
    text-transform: uppercase;
    margin-bottom: 8px;
  }
  header h1 {
    font-size: 36px;
    font-weight: 900;
    letter-spacing: -1px;
    color: #fff;
  }
  header h1 span { color: var(--accent); }
  header .meta {
    margin-top: 12px;
    font-family: var(--mono);
    font-size: 12px;
    color: var(--text-dim);
    display: flex; gap: 32px; flex-wrap: wrap;
  }
  header .meta b { color: var(--accent2); }

  /* ── STATS ── */
  .stats {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
    gap: 16px;
    padding: 32px 48px;
    background: var(--surface);
    border-bottom: 1px solid var(--border);
  }
  .stat-card {
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 20px 24px;
    position: relative;
    overflow: hidden;
  }
  .stat-card::after {
    content: '';
    position: absolute;
    bottom: 0; left: 0; right: 0;
    height: 3px;
  }
  .stat-card.danger::after  { background: var(--accent); }
  .stat-card.safe::after    { background: var(--green); }
  .stat-card.ghost::after   { background: var(--ghost); }
  .stat-card.total::after   { background: var(--accent2); }
  .stat-num {
    font-size: 42px; font-weight: 900;
    line-height: 1; margin-bottom: 4px;
  }
  .stat-card.danger .stat-num  { color: var(--accent); }
  .stat-card.safe .stat-num    { color: var(--green); }
  .stat-card.ghost .stat-num   { color: var(--ghost); }
  .stat-card.total .stat-num   { color: var(--accent2); }
  .stat-label {
    font-size: 12px; font-weight: 600;
    text-transform: uppercase; letter-spacing: 1px;
    color: var(--text-dim);
  }

  /* ── FILTERS ── */
  .toolbar {
    padding: 20px 48px;
    display: flex; gap: 12px; flex-wrap: wrap; align-items: center;
    border-bottom: 1px solid var(--border);
    background: var(--surface);
  }
  .toolbar label {
    font-size: 12px; text-transform: uppercase; letter-spacing: 1px;
    color: var(--text-dim); margin-right: 4px;
  }
  .filter-btn {
    background: var(--bg); border: 1px solid var(--border);
    color: var(--text); padding: 6px 14px; border-radius: 4px;
    cursor: pointer; font-family: var(--sans); font-size: 12px;
    font-weight: 600; letter-spacing: .5px;
    transition: all .15s ease;
  }
  .filter-btn:hover, .filter-btn.active { border-color: var(--accent2); color: var(--accent2); }
  .filter-btn.active { background: rgba(0,180,216,.1); }

  input#searchBox {
    background: var(--bg); border: 1px solid var(--border);
    color: var(--text); padding: 6px 14px; border-radius: 4px;
    font-family: var(--mono); font-size: 12px; width: 260px;
    outline: none;
  }
  input#searchBox:focus { border-color: var(--accent2); }

  /* ── TABLE ── */
  .table-wrap {
    padding: 24px 48px 48px;
    overflow-x: auto;
  }
  table {
    width: 100%; border-collapse: collapse;
    font-size: 13px;
  }
  thead th {
    background: #0d1117;
    border-bottom: 2px solid var(--border);
    padding: 12px 14px;
    text-align: left;
    font-size: 11px; font-weight: 700;
    text-transform: uppercase; letter-spacing: 1.5px;
    color: var(--text-dim);
    white-space: nowrap;
  }
  tbody tr {
    border-bottom: 1px solid var(--border);
    transition: background .1s;
  }
  tbody tr:hover { background: rgba(255,255,255,.03); }
  tbody td { padding: 10px 14px; vertical-align: middle; }

  /* row colors */
  .row-danger { background: rgba(230,57,70,.04); }
  .row-safe   { background: rgba(45,198,83,.03); }
  .row-ghost  { opacity: .45; }

  /* ── BADGES ── */
  .badge {
    display: inline-block; padding: 3px 10px; border-radius: 3px;
    font-size: 11px; font-weight: 700; letter-spacing: .8px;
    text-transform: uppercase; font-family: var(--mono);
  }
  .badge-danger { background: rgba(230,57,70,.2); color: #ff6b78; border: 1px solid rgba(230,57,70,.4); }
  .badge-safe   { background: rgba(45,198,83,.15); color: #5dde7c; border: 1px solid rgba(45,198,83,.3); }
  .badge-ghost  { background: rgba(100,110,130,.2); color: #8b949e; border: 1px solid #3a3f4b; }

  .cat {
    display: inline-block; padding: 2px 8px; border-radius: 2px;
    font-size: 10px; font-weight: 700; letter-spacing: .5px;
    text-transform: uppercase;
  }
  .cat-ms    { background: #1a3a5c; color: #58a6ff; }
  .cat-xbox  { background: #0d2e12; color: #3fb950; }
  .cat-third { background: #2e1a00; color: #f0883e; }
  .cat-one   { background: #1c1460; color: #a5b4fc; }
  .cat-store { background: #2a1240; color: #d2a8ff; }
  .cat-sys   { background: #1e2530; color: #8b949e; }

  .mono  { font-family: var(--mono); }
  .small { font-size: 11px; color: var(--text-dim); }
  .center { text-align: center; }
  .path  { font-family: var(--mono); font-size: 11px; color: var(--text-dim); max-width: 220px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

  /* ── FOOTER ── */
  footer {
    text-align: center; padding: 24px;
    font-family: var(--mono); font-size: 11px;
    color: var(--text-dim); border-top: 1px solid var(--border);
  }
  footer span { color: var(--accent); }

  /* ── SCROLLBAR ── */
  ::-webkit-scrollbar { width: 6px; height: 6px; }
  ::-webkit-scrollbar-track { background: var(--bg); }
  ::-webkit-scrollbar-thumb { background: var(--border); border-radius: 3px; }
</style>
</head>
<body>

<header>
  <div class="label">// Windows 10 Debloater // Simulacion</div>
  <h1>Informe de <span>Desinstalacion</span></h1>
  <div class="meta">
    <div><b>Host</b> $hostname</div>
    <div><b>Usuario</b> $user</div>
    <div><b>Fecha</b> $timestamp</div>
    <div><b>CSV</b> $CsvPath</div>
  </div>
</header>

<div class="stats">
  <div class="stat-card total">
    <div class="stat-num">$countTotal</div>
    <div class="stat-label">Apps totales</div>
  </div>
  <div class="stat-card danger">
    <div class="stat-num">$countDanger</div>
    <div class="stat-label">A desinstalar</div>
  </div>
  <div class="stat-card safe">
    <div class="stat-num">$countSafe</div>
    <div class="stat-label">Se mantienen</div>
  </div>
  <div class="stat-card ghost">
    <div class="stat-num">$countGhost</div>
    <div class="stat-label">No instaladas</div>
  </div>
</div>

<div class="toolbar">
  <label>Filtro:</label>
  <button class="filter-btn active" onclick="filterTable('all')">Todas</button>
  <button class="filter-btn" onclick="filterTable('danger')">Solo desinstalar</button>
  <button class="filter-btn" onclick="filterTable('safe')">Solo mantener</button>
  <button class="filter-btn" onclick="filterTable('ghost')">No instaladas</button>
  &nbsp;&nbsp;
  <input type="text" id="searchBox" placeholder="Buscar app..." oninput="searchTable()" />
</div>

<div class="table-wrap">
  <table id="mainTable">
    <thead>
      <tr>
        <th>Categoria</th>
        <th>Aplicacion / Package Name</th>
        <th>Full Package Name</th>
        <th>Version</th>
        <th>Ruta instalacion</th>
        <th>Accion</th>
      </tr>
    </thead>
    <tbody id="tableBody">
      $rows
    </tbody>
  </table>
</div>

<footer>
  Generado por <span>Debloater.ps1</span> &mdash; 4t0m5K &mdash; $timestamp
</footer>

<script>
  var allRows = null;
  function getRows() {
    if (!allRows) allRows = Array.from(document.querySelectorAll('#tableBody tr'));
    return allRows;
  }
  function filterTable(type) {
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    event.target.classList.add('active');
    var q = document.getElementById('searchBox').value.toLowerCase();
    getRows().forEach(function(row) {
      var matchFilter = type === 'all' || row.classList.contains('row-' + type);
      var matchSearch = !q || row.innerText.toLowerCase().includes(q);
      row.style.display = (matchFilter && matchSearch) ? '' : 'none';
    });
  }
  function searchTable() {
    var q = document.getElementById('searchBox').value.toLowerCase();
    var activeFilter = document.querySelector('.filter-btn.active');
    var type = 'all';
    if (activeFilter) {
      var t = activeFilter.textContent.trim();
      if (t.includes('desinstalar')) type = 'danger';
      else if (t.includes('mantener')) type = 'safe';
      else if (t.includes('instalada')) type = 'ghost';
    }
    getRows().forEach(function(row) {
      var matchFilter = type === 'all' || row.classList.contains('row-' + type);
      var matchSearch = !q || row.innerText.toLowerCase().includes(q);
      row.style.display = (matchFilter && matchSearch) ? '' : 'none';
    });
  }
</script>
</body>
</html>
"@
    $html | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "[+] Informe HTML generado en: $OutputPath" -ForegroundColor Green
}

# ─────────────────────────────────────────────────────────────
# FUNCION DE DESINSTALACION REAL
# ─────────────────────────────────────────────────────────────
function Invoke-Uninstall {
    param($AppList)

    foreach ($app in $AppList) {
        if ($app.Nombre -eq "OneDrive") {
            Write-Host "[*] Desinstalando OneDrive..." -ForegroundColor Yellow
            Stop-Process -Name OneDrive -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
            if (!(Test-Path $onedrive)) { $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe" }
            if (Test-Path $onedrive) {
                Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
                Remove-Item "$env:USERPROFILE\OneDrive"         -Force -Recurse -ErrorAction SilentlyContinue
                Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
                Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive"  -Force -Recurse -ErrorAction SilentlyContinue
                Write-Host "  [+] OneDrive desinstalado." -ForegroundColor Green
            } else {
                Write-Host "  [-] OneDrive no encontrado." -ForegroundColor DarkGray
            }
            continue
        }

        $pkg = Get-AppxPackage -AllUsers -Name "*$($app.Nombre)*" -ErrorAction SilentlyContinue
        if ($pkg) {
            Write-Host "[*] Desinstalando: $($app.Descripcion) ($($app.Nombre))" -ForegroundColor Yellow
            try {
                $pkg | Remove-AppxPackage -ErrorAction Stop
                # Eliminar tambien el paquete provisionado para que no vuelva en cuentas nuevas
                Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*$($app.Nombre)*" } |
                    Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
                Write-Host "  [+] Desinstalada correctamente." -ForegroundColor Green
            } catch {
                Write-Host "  [!] Error: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "  [-] No instalada: $($app.Nombre)" -ForegroundColor DarkGray
        }
    }
}

# ─────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────
Write-Host "`n[*] Generando informe HTML de simulacion..." -ForegroundColor Cyan
New-HtmlReport -AllResults $results -OutputPath $ReportPath

# Abrir el informe automaticamente
Start-Process $ReportPath

if ($Simulate) {
    Write-Host "`n[i] Modo SIMULACION activado. No se ha desinstalado nada." -ForegroundColor Cyan
    Write-Host "    Revisa el informe HTML y ejecuta sin -Simulate para aplicar cambios.`n" -ForegroundColor Yellow
} else {
    Write-Host "`n[!] ADVERTENCIA: Se van a desinstalar $($toUninstall.Count) aplicaciones." -ForegroundColor Red
    $confirm = Read-Host "    Escribe 'SI' para confirmar o cualquier otra tecla para cancelar"
    if ($confirm -eq "SI") {
        Write-Host "`n[*] Iniciando desinstalacion..." -ForegroundColor Yellow
        Invoke-Uninstall -AppList $toUninstall
        Write-Host "`n[+] Proceso completado. Puede que necesites reiniciar." -ForegroundColor Green
    } else {
        Write-Host "`n[i] Cancelado por el usuario." -ForegroundColor DarkGray
    }
}
