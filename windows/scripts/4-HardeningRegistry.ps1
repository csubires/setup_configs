##########################################################################
# HardeningSetup.ps1 - Hardening y Configuracion Windows 10
# by 4t0m5K - extraido de ScriptPostInstall1.ps1
# Lee claves desde CSV, simula cambios y genera informe HTML
#
# Uso:
#   .\HardeningSetup.ps1 -Simulate              -> Solo informe, no toca nada
#   .\HardeningSetup.ps1                        -> Aplica todos los cambios
#   .\HardeningSetup.ps1 -Menu 1                -> Solo aplica submenu 1 (Privacidad)
#   .\HardeningSetup.ps1 -Menu 2                -> Solo aplica submenu 2 (Estetica)
#   .\HardeningSetup.ps1 -Funcion DisableCortana -> Solo una funcion concreta
##########################################################################

param(
    [switch]$Simulate,
    [string]$CsvPath    = "$PSScriptRoot\hardening_registry.csv",
    [string]$ReportPath = ".\out\informe_hardening.html",
    [int]   $Menu       = 0,
    [string]$Funcion    = ""
)

# ─────────────────────────────────────────────────────────────
# COMPROBACION DE ADMINISTRADOR
# ─────────────────────────────────────────────────────────────
function Test-Admin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]"Administrator")
}
if (-not (Test-Admin)) {
    Write-Host "`n[!] Ejecuta el script como Administrador." -ForegroundColor Red; Exit 1
}

# ─────────────────────────────────────────────────────────────
# ESCAPE HTML NATIVO
# ─────────────────────────────────────────────────────────────
function ConvertTo-HtmlSafe {
    param([string]$Text)
    if (-not $Text) { return "" }
    $Text = $Text -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;'
    $Text = $Text -replace '"','&quot;' -replace "'","&#39;"
    return $Text
}

# ─────────────────────────────────────────────────────────────
# CARGA DEL CSV
# ─────────────────────────────────────────────────────────────
if (-not (Test-Path $CsvPath)) {
    Write-Host "`n[!] CSV no encontrado: $CsvPath" -ForegroundColor Red; Exit 1
}
$allEntries = Import-Csv -Path $CsvPath -Encoding UTF8
Write-Host "`n[*] CSV cargado: $($allEntries.Count) entradas." -ForegroundColor Cyan

# Filtrar por menu o funcion si se especifica
$entries = $allEntries
if ($Menu -gt 0)      { $entries = $entries | Where-Object { $_.Menu -eq $Menu } }
if ($Funcion -ne "")  { $entries = $entries | Where-Object { $_.Funcion -eq $Funcion } }
Write-Host "[*] Entradas a procesar: $($entries.Count)" -ForegroundColor Cyan

# ─────────────────────────────────────────────────────────────
# LEER ESTADO ACTUAL DE CADA CLAVE
# ─────────────────────────────────────────────────────────────
Write-Host "[*] Leyendo estado actual del registro..." -ForegroundColor Cyan

$results = @()
foreach ($e in $entries) {

    $currentValue = $null
    $currentExists = $false
    $pathExists = $false

    if ($e.Operacion -eq "DELETE") {
        $pathExists = Test-Path $e.RegistryPath
        $currentExists = $pathExists
        $currentValue = if ($pathExists) { "(existe)" } else { "(no existe)" }
    } else {
        $pathExists = Test-Path $e.RegistryPath
        if ($pathExists) {
            $prop = Get-ItemProperty -Path $e.RegistryPath -Name $e.KeyName -ErrorAction SilentlyContinue
            if ($prop -ne $null -and $prop.PSObject.Properties[$e.KeyName]) {
                $currentValue   = $prop.$($e.KeyName)
                $currentExists  = $true
            } else {
                $currentValue   = "(no existe)"
                $currentExists  = $false
            }
        } else {
            $currentValue  = "(ruta no existe)"
            $currentExists = $false
        }
    }

    # Determinar estado visual
    $estado = "PENDIENTE"
    if ($e.Operacion -eq "DELETE") {
        $estado = if ($currentExists) { "PENDIENTE" } else { "YA APLICADO" }
    } else {
        if ($currentExists -and "$currentValue" -eq "$($e.Valor)") {
            $estado = "YA APLICADO"
        } elseif ($currentExists) {
            $estado = "VALOR DIFERENTE"
        } else {
            $estado = "PENDIENTE"
        }
    }

    $results += [PSCustomObject]@{
        Menu          = $e.Menu
        Submenu       = $e.Submenu
        Funcion       = $e.Funcion
        Categoria     = $e.Categoria
        RegistryPath  = $e.RegistryPath
        KeyName       = $e.KeyName
        Tipo          = $e.Tipo
        ValorObjetivo = $e.Valor
        ValorActual   = "$currentValue"
        Operacion     = $e.Operacion
        Estado        = $estado
        Descripcion   = $e.Descripcion
        PathExists    = $pathExists
    }
}

$pendientes  = $results | Where-Object { $_.Estado -in @("PENDIENTE","VALOR DIFERENTE") }
$aplicados   = $results | Where-Object { $_.Estado -eq "YA APLICADO" }

Write-Host "[*] Pendientes / a aplicar: $($pendientes.Count)" -ForegroundColor Yellow
Write-Host "[*] Ya aplicados:           $($aplicados.Count)"  -ForegroundColor Green

# ─────────────────────────────────────────────────────────────
# GENERAR INFORME HTML
# ─────────────────────────────────────────────────────────────
function New-HtmlReport {
    param($AllResults, $OutputPath)

    $timestamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    $hostname  = $env:COMPUTERNAME
    $user      = $env:USERNAME

    $cTotal    = $AllResults.Count
    $cPending  = ($AllResults | Where-Object { $_.Estado -eq "PENDIENTE" }).Count
    $cDiff     = ($AllResults | Where-Object { $_.Estado -eq "VALOR DIFERENTE" }).Count
    $cDone     = ($AllResults | Where-Object { $_.Estado -eq "YA APLICADO" }).Count
    $cMenus    = ($AllResults | Select-Object -ExpandProperty Submenu -Unique).Count

    # Agrupar por Funcion para la tabla de resumen
    $funcSummary = $AllResults | Group-Object Funcion | ForEach-Object {
        $g = $_.Group
        [PSCustomObject]@{
            Funcion   = $_.Name
            Submenu   = ($g | Select-Object -First 1).Submenu
            Total     = $g.Count
            Pendiente = ($g | Where-Object { $_.Estado -in @("PENDIENTE","VALOR DIFERENTE") }).Count
            Aplicado  = ($g | Where-Object { $_.Estado -eq "YA APLICADO" }).Count
        }
    }

    $summaryRows = ""
    foreach ($f in ($funcSummary | Sort-Object Submenu, Funcion)) {
        $pct = [math]::Round(($f.Aplicado / $f.Total) * 100)
        $barColor = if ($pct -eq 100) { "#2dc653" } elseif ($pct -gt 50) { "#f4a261" } else { "#e63946" }
        $summaryRows += @"
        <tr>
            <td><span class="tag-sub tag-$(($f.Submenu -replace '\s','').ToLower())">$($f.Submenu)</span></td>
            <td><strong>$($f.Funcion)</strong></td>
            <td class="center">$($f.Total)</td>
            <td class="center" style="color:#e63946">$($f.Pendiente)</td>
            <td class="center" style="color:#2dc653">$($f.Aplicado)</td>
            <td>
              <div class="progress-wrap">
                <div class="progress-bar" style="width:${pct}%;background:$barColor"></div>
                <span class="progress-label">${pct}%</span>
              </div>
            </td>
        </tr>
"@
    }

    # Filas detalle
    $detailRows = ""
    foreach ($r in ($AllResults | Sort-Object Submenu, Funcion, KeyName)) {

        $rowClass = switch ($r.Estado) {
            "PENDIENTE"       { "row-pending" }
            "VALOR DIFERENTE" { "row-diff" }
            "YA APLICADO"     { "row-done" }
            default           { "" }
        }
        $badge = switch ($r.Estado) {
            "PENDIENTE"       { '<span class="badge badge-pending">Pendiente</span>' }
            "VALOR DIFERENTE" { '<span class="badge badge-diff">Valor diferente</span>' }
            "YA APLICADO"     { '<span class="badge badge-done">Aplicado</span>' }
            default           { $r.Estado }
        }
        $opBadge = if ($r.Operacion -eq "DELETE") {
            '<span class="op op-del">DELETE</span>'
        } else {
            '<span class="op op-set">SET</span>'
        }

        $safePath  = ConvertTo-HtmlSafe $r.RegistryPath
        $safeKey   = ConvertTo-HtmlSafe $r.KeyName
        $safeDesc  = ConvertTo-HtmlSafe $r.Descripcion
        $safeCurr  = ConvertTo-HtmlSafe $r.ValorActual
        $safeObj   = ConvertTo-HtmlSafe $r.ValorObjetivo

        $catClass = "cat-" + ($r.Categoria -replace '\s','').ToLower().Substring(0, [Math]::Min(8, ($r.Categoria -replace '\s','').Length))

        $detailRows += @"
        <tr class="$rowClass">
            <td><span class="cat $catClass">$($r.Categoria)</span></td>
            <td class="mono small path" title="$safePath">$safePath</td>
            <td class="mono small"><strong>$safeKey</strong></td>
            <td class="center mono small">$($r.Tipo)</td>
            <td class="center mono small curr">$safeCurr</td>
            <td class="center mono small obj">$safeObj</td>
            <td class="center">$opBadge</td>
            <td class="desc small">$safeDesc</td>
            <td class="center">$badge</td>
        </tr>
"@
    }

    $html = @"
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Informe Hardening - $hostname</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Barlow+Condensed:wght@300;400;600;700;900&family=Barlow:wght@300;400;600&display=swap');
  :root{
    --bg:#080b0f;--surface:#0d1117;--surface2:#111820;--border:#1e2a38;
    --accent:#e63946;--accent2:#00b4d8;--amber:#f4a261;--green:#2dc653;
    --purple:#a78bfa;--text:#c9d1d9;--dim:#8b949e;
    --mono:'Share Tech Mono',monospace;
    --head:'Barlow Condensed',sans-serif;
    --body:'Barlow',sans-serif;
  }
  *{box-sizing:border-box;margin:0;padding:0;}
  body{background:var(--bg);color:var(--text);font-family:var(--body);font-size:13px;line-height:1.5;}

  /* HEADER */
  header{padding:44px 52px 36px;background:linear-gradient(135deg,#080b0f 0%,#0d1520 50%,#0a0010 100%);border-bottom:2px solid var(--accent);position:relative;overflow:hidden;}
  header::before{content:'';position:absolute;top:-100px;right:-100px;width:400px;height:400px;border-radius:50%;background:radial-gradient(circle,rgba(230,57,70,.1) 0%,transparent 65%);pointer-events:none;}
  header::after{content:'HARDENING';position:absolute;right:48px;bottom:-10px;font-family:var(--head);font-size:120px;font-weight:900;color:rgba(255,255,255,.02);letter-spacing:-4px;pointer-events:none;}
  .h-label{font-family:var(--mono);font-size:10px;letter-spacing:4px;color:var(--accent);text-transform:uppercase;margin-bottom:6px;}
  header h1{font-family:var(--head);font-size:42px;font-weight:900;color:#fff;letter-spacing:-1px;line-height:1;}
  header h1 em{color:var(--accent);font-style:normal;}
  .h-meta{margin-top:14px;font-family:var(--mono);font-size:11px;color:var(--dim);display:flex;gap:28px;flex-wrap:wrap;}
  .h-meta b{color:var(--accent2);}

  /* STATS */
  .stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:14px;padding:28px 52px;background:var(--surface);border-bottom:1px solid var(--border);}
  .sc{background:var(--bg);border:1px solid var(--border);border-radius:6px;padding:16px 20px;position:relative;overflow:hidden;}
  .sc::after{content:'';position:absolute;bottom:0;left:0;right:0;height:2px;}
  .sc.s-total::after{background:var(--accent2);}
  .sc.s-pend::after{background:var(--accent);}
  .sc.s-diff::after{background:var(--amber);}
  .sc.s-done::after{background:var(--green);}
  .sc.s-menu::after{background:var(--purple);}
  .sc-num{font-family:var(--head);font-size:44px;font-weight:900;line-height:1;margin-bottom:2px;}
  .sc.s-total .sc-num{color:var(--accent2);}
  .sc.s-pend  .sc-num{color:var(--accent);}
  .sc.s-diff  .sc-num{color:var(--amber);}
  .sc.s-done  .sc-num{color:var(--green);}
  .sc.s-menu  .sc-num{color:var(--purple);}
  .sc-lbl{font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:1px;color:var(--dim);}

  /* TABS */
  .tabs{display:flex;gap:0;padding:0 52px;background:var(--surface);border-bottom:1px solid var(--border);}
  .tab-btn{padding:12px 22px;border:none;background:transparent;color:var(--dim);font-family:var(--body);font-size:13px;font-weight:600;cursor:pointer;border-bottom:2px solid transparent;margin-bottom:-1px;transition:all .15s;}
  .tab-btn:hover{color:var(--text);}
  .tab-btn.active{color:var(--accent2);border-bottom-color:var(--accent2);}

  /* PANELS */
  .panel{display:none;padding:28px 52px 52px;}
  .panel.active{display:block;}

  /* TOOLBAR */
  .toolbar{display:flex;gap:10px;flex-wrap:wrap;align-items:center;margin-bottom:20px;}
  .toolbar label{font-size:11px;text-transform:uppercase;letter-spacing:1px;color:var(--dim);margin-right:2px;}
  .filter-btn{background:var(--surface);border:1px solid var(--border);color:var(--text);padding:5px 12px;border-radius:4px;cursor:pointer;font-family:var(--body);font-size:12px;font-weight:600;transition:all .15s;}
  .filter-btn:hover,.filter-btn.active{border-color:var(--accent2);color:var(--accent2);background:rgba(0,180,216,.08);}
  input.search{background:var(--surface);border:1px solid var(--border);color:var(--text);padding:5px 12px;border-radius:4px;font-family:var(--mono);font-size:11px;width:280px;outline:none;}
  input.search:focus{border-color:var(--accent2);}

  /* SUMMARY TABLE */
  .progress-wrap{position:relative;height:18px;background:var(--border);border-radius:3px;overflow:hidden;min-width:100px;}
  .progress-bar{height:100%;border-radius:3px;transition:width .3s;}
  .progress-label{position:absolute;right:6px;top:50%;transform:translateY(-50%);font-family:var(--mono);font-size:10px;font-weight:700;color:#fff;mix-blend-mode:difference;}

  /* TABLES */
  table{width:100%;border-collapse:collapse;font-size:12px;}
  thead th{background:#080b0f;border-bottom:2px solid var(--border);padding:10px 12px;text-align:left;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:1.5px;color:var(--dim);white-space:nowrap;}
  tbody tr{border-bottom:1px solid var(--border);transition:background .1s;}
  tbody tr:hover{background:rgba(255,255,255,.025);}
  tbody td{padding:8px 12px;vertical-align:middle;}
  .row-pending{background:rgba(230,57,70,.035);}
  .row-diff{background:rgba(244,162,97,.035);}
  .row-done{background:rgba(45,198,83,.02);}

  /* BADGES */
  .badge{display:inline-block;padding:2px 8px;border-radius:3px;font-size:10px;font-weight:700;letter-spacing:.6px;text-transform:uppercase;font-family:var(--mono);white-space:nowrap;}
  .badge-pending{background:rgba(230,57,70,.2);color:#ff6b78;border:1px solid rgba(230,57,70,.35);}
  .badge-diff{background:rgba(244,162,97,.2);color:#f4a261;border:1px solid rgba(244,162,97,.35);}
  .badge-done{background:rgba(45,198,83,.15);color:#4ade80;border:1px solid rgba(45,198,83,.3);}

  .op{display:inline-block;padding:1px 6px;border-radius:2px;font-size:9px;font-weight:700;font-family:var(--mono);}
  .op-set{background:#1a2a3a;color:#60a5fa;}
  .op-del{background:#2e1a1a;color:#f87171;}

  /* CAT COLORS - generated dynamically via class */
  .cat{display:inline-block;padding:2px 7px;border-radius:2px;font-size:9px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;white-space:nowrap;}
  .cat-telemetr{background:#1a0a2e;color:#c084fc;}
  .cat-wifisen{background:#1a2a1a;color:#34d399;}
  .cat-smartsc{background:#2e2a1a;color:#fbbf24;}
  .cat-busqued{background:#1a2a3a;color:#60a5fa;}
  .cat-sugeren{background:#2e1a28;color:#e879f9;}
  .cat-pantall{background:#1a1a2e;color:#818cf8;}
  .cat-ubicaci{background:#1a2e2a;color:#2dd4bf;}
  .cat-mapas{background:#1a2e2e;color:#06b6d4;}
  .cat-feedbac{background:#2e1a1a;color:#fca5a5;}
  .cat-publici{background:#2a1a1a;color:#fb923c;}
  .cat-cortana{background:#1a0a2e;color:#a78bfa;}
  .cat-errorre{background:#2a1a00;color:#f97316;}
  .cat-windows{background:#1a2038;color:#7dd3fc;}
  .cat-uac{background:#2e2010;color:#fcd34d;}
  .cat-red{background:#102020;color:#5eead4;}
  .cat-firewal{background:#2e0a0a;color:#fca5a5;}
  .cat-defende{background:#0a2e1a;color:#6ee7b7;}
  .cat-experie{background:#2a1a2e;color:#d8b4fe;}
  .cat-accesore{background:#2e1a1a;color:#f87171;}
  .cat-medios{background:#1a2e1a;color:#86efac;}
  .cat-sistema{background:#1e2530;color:#8b949e;}
  .cat-explora{background:#1a2838;color:#7dd3fc;}
  .cat-rendimi{background:#2e2808;color:#fde68a;}
  .cat-adminis{background:#1a1a2e;color:#a5b4fc;}
  .cat-onedri{background:#1c1460;color:#a5b4fc;}
  .cat-hiberna{background:#1a1a2e;color:#818cf8;}
  .cat-superfe{background:#2e2010;color:#fcd34d;}
  .cat-desfrag{background:#1a0a00;color:#fed7aa;}
  .cat-memoria{background:#2a1a2e;color:#d8b4fe;}
  .cat-privaci{background:#0a1a2e;color:#93c5fd;}

  /* TAG sub */
  .tag-sub{display:inline-block;padding:2px 8px;border-radius:2px;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;}
  .tag-privacidad{background:#1a0a2e;color:#c084fc;}
  .tag-estetica{background:#1a2838;color:#7dd3fc;}
  .tag-desinstalacion{background:#2e1a1a;color:#fca5a5;}
  .tag-ssdoptimizacion{background:#1a2e1a;color:#6ee7b7;}

  .mono{font-family:var(--mono);}
  .small{font-size:11px;}
  .center{text-align:center;}
  .dim{color:var(--dim);}
  .path{max-width:260px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--dim);}
  .desc{max-width:240px;color:var(--dim);}
  .curr{color:#f87171;}
  .obj{color:#4ade80;}

  .section-title{font-family:var(--head);font-size:18px;font-weight:700;color:#fff;margin-bottom:16px;padding-bottom:8px;border-bottom:1px solid var(--border);}

  footer{text-align:center;padding:20px;font-family:var(--mono);font-size:10px;color:var(--dim);border-top:1px solid var(--border);}
  footer span{color:var(--accent);}
  ::-webkit-scrollbar{width:5px;height:5px;}
  ::-webkit-scrollbar-track{background:var(--bg);}
  ::-webkit-scrollbar-thumb{background:var(--border);border-radius:3px;}
</style>
</head>
<body>

<header>
  <div class="h-label">// Windows 10 // Registry Hardening & Setup</div>
  <h1>Hardening & <em>Configuracion</em></h1>
  <div class="h-meta">
    <div><b>Host</b> $hostname</div>
    <div><b>Usuario</b> $user</div>
    <div><b>Fecha</b> $timestamp</div>
    <div><b>CSV</b> $CsvPath</div>
  </div>
</header>

<div class="stats">
  <div class="sc s-total"><div class="sc-num">$cTotal</div><div class="sc-lbl">Entradas totales</div></div>
  <div class="sc s-pend"><div class="sc-num">$cPending</div><div class="sc-lbl">Pendientes</div></div>
  <div class="sc s-diff"><div class="sc-num">$cDiff</div><div class="sc-lbl">Valor diferente</div></div>
  <div class="sc s-done"><div class="sc-num">$cDone</div><div class="sc-lbl">Ya aplicadas</div></div>
  <div class="sc s-menu"><div class="sc-num">$cMenus</div><div class="sc-lbl">Categorias</div></div>
</div>

<div class="tabs">
  <button class="tab-btn active" onclick="showTab('summary',this)">Resumen por funcion</button>
  <button class="tab-btn" onclick="showTab('detail',this)">Detalle de claves</button>
</div>

<!-- TAB RESUMEN -->
<div id="tab-summary" class="panel active">
  <div class="section-title">Estado de aplicacion por funcion</div>
  <table>
    <thead>
      <tr>
        <th>Menu</th>
        <th>Funcion</th>
        <th>Total claves</th>
        <th>Pendientes</th>
        <th>Aplicadas</th>
        <th>Progreso</th>
      </tr>
    </thead>
    <tbody>
      $summaryRows
    </tbody>
  </table>
</div>

<!-- TAB DETALLE -->
<div id="tab-detail" class="panel">
  <div class="toolbar">
    <label>Estado:</label>
    <button class="filter-btn active" onclick="filterDetail('all',this)">Todas</button>
    <button class="filter-btn" onclick="filterDetail('row-pending',this)">Pendientes</button>
    <button class="filter-btn" onclick="filterDetail('row-diff',this)">Valor diferente</button>
    <button class="filter-btn" onclick="filterDetail('row-done',this)">Aplicadas</button>
    &nbsp;
    <input class="search" id="detailSearch" placeholder="Filtrar por clave, ruta, funcion..." oninput="searchDetail()" />
  </div>
  <div style="overflow-x:auto;">
  <table id="detailTable">
    <thead>
      <tr>
        <th>Categoria</th>
        <th>Ruta del registro</th>
        <th>Clave</th>
        <th>Tipo</th>
        <th>Valor actual</th>
        <th>Valor objetivo</th>
        <th>Op.</th>
        <th>Descripcion</th>
        <th>Estado</th>
      </tr>
    </thead>
    <tbody id="detailBody">
      $detailRows
    </tbody>
  </table>
  </div>
</div>

<footer>
  Generado por <span>HardeningSetup.ps1</span> &mdash; 4t0m5K &mdash; $timestamp
</footer>

<script>
  function showTab(id,btn){
    document.querySelectorAll('.panel').forEach(p=>p.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b=>b.classList.remove('active'));
    document.getElementById('tab-'+id).classList.add('active');
    btn.classList.add('active');
  }
  var detailRows=null;
  function getDetailRows(){if(!detailRows)detailRows=Array.from(document.querySelectorAll('#detailBody tr'));return detailRows;}
  function filterDetail(cls,btn){
    document.querySelectorAll('.toolbar .filter-btn').forEach(b=>b.classList.remove('active'));
    btn.classList.add('active');
    var q=document.getElementById('detailSearch').value.toLowerCase();
    getDetailRows().forEach(function(r){
      var mf=cls==='all'||r.classList.contains(cls);
      var ms=!q||r.innerText.toLowerCase().includes(q);
      r.style.display=(mf&&ms)?'':'none';
    });
  }
  function searchDetail(){
    var q=document.getElementById('detailSearch').value.toLowerCase();
    var active=document.querySelector('.toolbar .filter-btn.active');
    var cls=active?active.onclick.toString().match(/'([^']+)'/)?.[1]:'all';
    if(!cls)cls='all';
    getDetailRows().forEach(function(r){
      var mf=cls==='all'||r.classList.contains(cls);
      var ms=!q||r.innerText.toLowerCase().includes(q);
      r.style.display=(mf&&ms)?'':'none';
    });
  }
</script>
</body>
</html>
"@
    $html | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "[+] Informe HTML en: $OutputPath" -ForegroundColor Green
}

# ─────────────────────────────────────────────────────────────
# APLICAR CAMBIOS EN EL REGISTRO
# ─────────────────────────────────────────────────────────────
function Invoke-ApplyRegistry {
    param($Entries)

    $ok = 0; $fail = 0; $skip = 0

    foreach ($e in $Entries) {
        Write-Host "[*] [$($e.Funcion)] $($e.RegistryPath) -> $($e.KeyName)" -ForegroundColor Yellow

        # ── DELETE ──────────────────────────────────────────
        if ($e.Operacion -eq "DELETE") {
            if (Test-Path $e.RegistryPath) {
                try {
                    if ($e.KeyName -eq "-") {
                        Remove-Item -Path $e.RegistryPath -Recurse -Force -ErrorAction Stop
                    } else {
                        Remove-ItemProperty -Path $e.RegistryPath -Name $e.KeyName -Force -ErrorAction Stop
                    }
                    Write-Host "  [+] Eliminado." -ForegroundColor Green; $ok++
                } catch {
                    Write-Host "  [!] Error eliminando: $_" -ForegroundColor Red; $fail++
                }
            } else {
                Write-Host "  [-] Ruta no existe, nada que eliminar." -ForegroundColor DarkGray; $skip++
            }
            continue
        }

        # ── SET ─────────────────────────────────────────────
        # Crear ruta si no existe
        if (-not (Test-Path $e.RegistryPath)) {
            try {
                New-Item -Path $e.RegistryPath -Force | Out-Null
                Write-Host "  [~] Ruta creada." -ForegroundColor Cyan
            } catch {
                Write-Host "  [!] No se pudo crear la ruta: $_" -ForegroundColor Red; $fail++; continue
            }
        }

        # Establecer valor
        try {
            $val = switch ($e.Tipo) {
                "DWord"  { [int]$e.Valor }
                "QWord"  { [long]$e.Valor }
                default  { $e.Valor }
            }
            Set-ItemProperty -Path $e.RegistryPath -Name $e.KeyName -Type $e.Tipo -Value $val -Force -ErrorAction Stop
            Write-Host "  [+] OK: $($e.KeyName) = $($e.Valor)" -ForegroundColor Green; $ok++
        } catch {
            Write-Host "  [!] Error: $_" -ForegroundColor Red; $fail++
        }
    }

    Write-Host "`n[+] Resumen: $ok correctos / $fail errores / $skip omitidos`n" -ForegroundColor Cyan
}

# ─────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────
Write-Host "`n[*] Generando informe HTML..." -ForegroundColor Cyan
New-HtmlReport -AllResults $results -OutputPath $ReportPath
Start-Process $ReportPath

if ($Simulate) {
    Write-Host "`n[i] Modo SIMULACION activo. No se ha modificado el registro." -ForegroundColor Cyan
    Write-Host "    Revisa el informe y ejecuta sin -Simulate para aplicar.`n" -ForegroundColor Yellow
} else {
    $toDo = $results | Where-Object { $_.Estado -in @("PENDIENTE", "VALOR DIFERENTE") }
    if ($toDo.Count -eq 0) {
        Write-Host "`n[i] Nada que aplicar, todo ya esta en el estado correcto." -ForegroundColor Green
    } else {
        Write-Host "`n[!] Se van a modificar $($toDo.Count) entradas del registro." -ForegroundColor Red
        $confirm = Read-Host "    Escribe 'SI' para confirmar"
        if ($confirm -eq "SI") {
            Invoke-ApplyRegistry -Entries $toDo
            Write-Host "[*] Regenerando informe con estado actualizado..." -ForegroundColor Cyan
            # Re-leer estado tras aplicar
            $results | ForEach-Object {
                if ($_.Operacion -ne "DELETE") {
                    $prop = Get-ItemProperty -Path $_.RegistryPath -Name $_.KeyName -ErrorAction SilentlyContinue
                    if ($prop -and $prop.PSObject.Properties[$_.KeyName]) {
                        $_.ValorActual = "$($prop.$($_.KeyName))"
                        $_.Estado = if ("$($prop.$($_.KeyName))" -eq $_.ValorObjetivo) { "YA APLICADO" } else { "VALOR DIFERENTE" }
                    }
                }
            }
            New-HtmlReport -AllResults $results -OutputPath $ReportPath
            Start-Process $ReportPath
        } else {
            Write-Host "`n[i] Cancelado por el usuario." -ForegroundColor DarkGray
        }
    }
}
