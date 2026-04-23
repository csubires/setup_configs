##########################################################################
# TaskDebloater.ps1 - Gestor de Tareas Programadas Windows 10
# by 4t0m5K - extraido de ScriptPostInstall1.ps1
# Uso: .\TaskDebloater.ps1 [-Simulate] [-CsvPath "ruta\scheduled_tasks_list.csv"]
##########################################################################

param(
    [switch]$Simulate,
    [string]$CsvPath    = "$PSScriptRoot\scheduled_tasks_list.csv",
    [string]$ReportPath = ".\out\informe_tasks.html"
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
# CARGA DEL CSV
# ─────────────────────────────────────────────────────────────
if (-not (Test-Path $CsvPath)) {
    Write-Host "`n[!] No se encontro el CSV en: $CsvPath" -ForegroundColor Red
    Write-Host "    Coloca 'scheduled_tasks_list.csv' en la misma carpeta que este script." -ForegroundColor Yellow
    Exit 1
}

$taskList = Import-Csv -Path $CsvPath -Encoding UTF8
Write-Host "`n[*] CSV cargado: $($taskList.Count) tareas en lista negra." -ForegroundColor Cyan

# ─────────────────────────────────────────────────────────────
# OBTENER TODAS LAS TAREAS PROGRAMADAS DEL SISTEMA
# ─────────────────────────────────────────────────────────────
Write-Host "[*] Obteniendo tareas programadas del sistema..." -ForegroundColor Cyan
$allTasks = Get-ScheduledTask | Select-Object TaskPath, TaskName, State, Description, @{
    Name = "LastRunTime"
    Expression = {
        try { (Get-ScheduledTaskInfo -TaskPath $_.TaskPath -TaskName $_.TaskName -ErrorAction SilentlyContinue).LastRunTime }
        catch { $null }
    }
}

# ─────────────────────────────────────────────────────────────
# CRUZAR: tareas del sistema vs lista negra del CSV
# ─────────────────────────────────────────────────────────────
$results = @()

foreach ($task in $allTasks) {
    $matchedCsv = $taskList | Where-Object {
        ($task.TaskName -eq $_.TaskName) -and
        ($task.TaskPath -like "*$($_.TaskPath.TrimEnd('\'))*")
    }

    $results += [PSCustomObject]@{
        TaskPath    = $task.TaskPath
        TaskName    = $task.TaskName
        Estado      = $task.State
        Descripcion = if ($matchedCsv) { $matchedCsv.Descripcion } else { $task.Description }
        Categoria   = if ($matchedCsv) { $matchedCsv.Categoria } else { "Sistema" }
        EnListaNegra = if ($matchedCsv) { $true } else { $false }
        Accion      = if ($matchedCsv) {
                          if ($task.State -eq "Disabled") { "Ya deshabilitada" } else { "DESHABILITAR" }
                      } else { "Mantener" }
        LastRun     = if ($task.LastRunTime -and $task.LastRunTime -ne [DateTime]::MinValue) {
                          $task.LastRunTime.ToString("dd/MM/yyyy HH:mm")
                      } else { "Nunca" }
    }
}

# Tareas del CSV que no existen en el sistema
foreach ($csvTask in $taskList) {
    $alreadyIn = $results | Where-Object {
        ($_.TaskName -eq $csvTask.TaskName) -and
        ($_.TaskPath -like "*$($csvTask.TaskPath.TrimEnd('\'))*")
    }
    if (-not $alreadyIn) {
        $results += [PSCustomObject]@{
            TaskPath     = $csvTask.TaskPath
            TaskName     = $csvTask.TaskName
            Estado       = "NoExiste"
            Descripcion  = $csvTask.Descripcion
            Categoria    = $csvTask.Categoria
            EnListaNegra = $true
            Accion       = "No existe"
            LastRun      = "-"
        }
    }
}

$toDisable    = $results | Where-Object { $_.Accion -eq "DESHABILITAR" }
$alreadyOff   = $results | Where-Object { $_.Accion -eq "Ya deshabilitada" }
$toKeep       = $results | Where-Object { $_.Accion -eq "Mantener" }
$notFound     = $results | Where-Object { $_.Accion -eq "No existe" }

Write-Host "[*] Tareas a deshabilitar:       $($toDisable.Count)"    -ForegroundColor Red
Write-Host "[*] Ya deshabilitadas (CSV):     $($alreadyOff.Count)"   -ForegroundColor DarkGray
Write-Host "[*] No existen en este sistema:  $($notFound.Count)"     -ForegroundColor DarkGray
Write-Host "[*] Tareas a mantener:           $($toKeep.Count)"       -ForegroundColor Green

# ─────────────────────────────────────────────────────────────
# GENERAR INFORME HTML
# ─────────────────────────────────────────────────────────────
function New-HtmlReport {
    param($AllResults, $OutputPath)

    $timestamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    $hostname  = $env:COMPUTERNAME
    $user      = $env:USERNAME

    $countTotal    = $AllResults.Count
    $countDanger   = ($AllResults | Where-Object { $_.Accion -eq "DESHABILITAR" }).Count
    $countOff      = ($AllResults | Where-Object { $_.Accion -eq "Ya deshabilitada" }).Count
    $countSafe     = ($AllResults | Where-Object { $_.Accion -eq "Mantener" }).Count
    $countGhost    = ($AllResults | Where-Object { $_.Accion -eq "No existe" }).Count

    $rows = ""
    foreach ($r in ($AllResults | Sort-Object Accion, Categoria, TaskName)) {

        $rowClass = switch ($r.Accion) {
            "DESHABILITAR"       { "row-danger" }
            "Ya deshabilitada"   { "row-off" }
            "Mantener"           { "row-safe" }
            "No existe"          { "row-ghost" }
            default              { "" }
        }

        $badge = switch ($r.Accion) {
            "DESHABILITAR"     { '<span class="badge badge-danger">DESHABILITAR</span>' }
            "Ya deshabilitada" { '<span class="badge badge-off">Ya OFF</span>' }
            "Mantener"         { '<span class="badge badge-safe">Mantener</span>' }
            "No existe"        { '<span class="badge badge-ghost">No existe</span>' }
            default            { $r.Accion }
        }

        $stateBadge = switch ($r.Estado) {
            "Running"  { '<span class="state state-run">Running</span>' }
            "Ready"    { '<span class="state state-ready">Ready</span>' }
            "Disabled" { '<span class="state state-dis">Disabled</span>' }
            "NoExiste" { '<span class="state state-dis">-</span>' }
            default    { "<span class='state'>$($r.Estado)</span>" }
        }

        $catColors = @{
            "Telemetria"          = "cat-tel"
            "Feedback"            = "cat-feed"
            "Xbox y Gaming"       = "cat-xbox"
            "Windows Update"      = "cat-wu"
            "Defender"            = "cat-def"
            "Desfragmentacion"    = "cat-disk"
            "Disco"               = "cat-disk"
            "Ubicacion y Mapas"   = "cat-loc"
            "Sincronizacion Hora" = "cat-time"
            "Asistencia Remota"   = "cat-rem"
            "Seguridad SmartScreen" = "cat-ss"
            "Nube"                = "cat-cloud"
            "Multimedia"          = "cat-media"
            "Red Movil"           = "cat-net"
            "Texto e Input"       = "cat-text"
            "Terceros"            = "cat-third"
            "Sistema"             = "cat-sys"
        }
        $catClass = if ($catColors.ContainsKey($r.Categoria)) { $catColors[$r.Categoria] } else { "cat-sys" }
        $catBadge = "<span class='cat $catClass'>$($r.Categoria)</span>"

        $safeDesc = ConvertTo-HtmlSafe $r.Descripcion
        $safePath = ConvertTo-HtmlSafe $r.TaskPath
        $safeName = ConvertTo-HtmlSafe $r.TaskName

        $rows += @"
        <tr class="$rowClass">
            <td>$catBadge</td>
            <td><strong>$safeName</strong><br><small class="mono dim">$safePath</small></td>
            <td class="desc">$safeDesc</td>
            <td class="center">$stateBadge</td>
            <td class="center mono small">$($r.LastRun)</td>
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
<title>Informe Tareas Programadas - $hostname</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Barlow:wght@300;400;600;700;900&display=swap');
  :root {
    --bg:#0a0c10;--surface:#0f1318;--border:#1e2530;
    --accent:#f4a261;--accent2:#00b4d8;--green:#2dc653;
    --off:#4a5568;--ghost:#3a3f4b;--text:#c9d1d9;--text-dim:#8b949e;
    --mono:'Share Tech Mono',monospace;--sans:'Barlow',sans-serif;
  }
  *{box-sizing:border-box;margin:0;padding:0;}
  body{background:var(--bg);color:var(--text);font-family:var(--sans);font-size:14px;line-height:1.6;}

  header{background:linear-gradient(135deg,#0d1117 0%,#161b22 55%,#1a1200 100%);border-bottom:2px solid var(--accent);padding:40px 48px 32px;position:relative;overflow:hidden;}
  header::before{content:'';position:absolute;top:-60px;right:-60px;width:300px;height:300px;border-radius:50%;background:radial-gradient(circle,rgba(244,162,97,.13) 0%,transparent 70%);pointer-events:none;}
  header .label{font-family:var(--mono);font-size:11px;letter-spacing:3px;color:var(--accent);text-transform:uppercase;margin-bottom:8px;}
  header h1{font-size:34px;font-weight:900;letter-spacing:-1px;color:#fff;}
  header h1 span{color:var(--accent);}
  header .meta{margin-top:12px;font-family:var(--mono);font-size:12px;color:var(--text-dim);display:flex;gap:32px;flex-wrap:wrap;}
  header .meta b{color:var(--accent2);}

  .stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:16px;padding:28px 48px;background:var(--surface);border-bottom:1px solid var(--border);}
  .stat-card{background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:18px 22px;position:relative;overflow:hidden;}
  .stat-card::after{content:'';position:absolute;bottom:0;left:0;right:0;height:3px;}
  .stat-card.danger::after{background:var(--accent);}
  .stat-card.safe::after{background:var(--green);}
  .stat-card.off::after{background:var(--off);}
  .stat-card.ghost::after{background:var(--ghost);}
  .stat-card.total::after{background:var(--accent2);}
  .stat-num{font-size:38px;font-weight:900;line-height:1;margin-bottom:4px;}
  .stat-card.danger .stat-num{color:var(--accent);}
  .stat-card.safe .stat-num{color:var(--green);}
  .stat-card.off .stat-num{color:var(--off);}
  .stat-card.ghost .stat-num{color:var(--ghost);}
  .stat-card.total .stat-num{color:var(--accent2);}
  .stat-label{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:var(--text-dim);}

  .toolbar{padding:18px 48px;display:flex;gap:10px;flex-wrap:wrap;align-items:center;border-bottom:1px solid var(--border);background:var(--surface);}
  .toolbar label{font-size:12px;text-transform:uppercase;letter-spacing:1px;color:var(--text-dim);margin-right:4px;}
  .filter-btn{background:var(--bg);border:1px solid var(--border);color:var(--text);padding:5px 13px;border-radius:4px;cursor:pointer;font-family:var(--sans);font-size:12px;font-weight:600;letter-spacing:.5px;transition:all .15s;}
  .filter-btn:hover,.filter-btn.active{border-color:var(--accent2);color:var(--accent2);}
  .filter-btn.active{background:rgba(0,180,216,.1);}
  input#searchBox{background:var(--bg);border:1px solid var(--border);color:var(--text);padding:5px 13px;border-radius:4px;font-family:var(--mono);font-size:12px;width:260px;outline:none;}
  input#searchBox:focus{border-color:var(--accent2);}

  .table-wrap{padding:24px 48px 48px;overflow-x:auto;}
  table{width:100%;border-collapse:collapse;font-size:13px;}
  thead th{background:#0d1117;border-bottom:2px solid var(--border);padding:11px 13px;text-align:left;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:1.5px;color:var(--text-dim);white-space:nowrap;}
  tbody tr{border-bottom:1px solid var(--border);transition:background .1s;}
  tbody tr:hover{background:rgba(255,255,255,.03);}
  tbody td{padding:9px 13px;vertical-align:middle;}
  .row-danger{background:rgba(244,162,97,.04);}
  .row-safe{background:rgba(45,198,83,.03);}
  .row-off{background:rgba(74,85,104,.06);}
  .row-ghost{opacity:.4;}

  .badge{display:inline-block;padding:3px 9px;border-radius:3px;font-size:11px;font-weight:700;letter-spacing:.7px;text-transform:uppercase;font-family:var(--mono);}
  .badge-danger{background:rgba(244,162,97,.2);color:#f4a261;border:1px solid rgba(244,162,97,.4);}
  .badge-safe{background:rgba(45,198,83,.15);color:#5dde7c;border:1px solid rgba(45,198,83,.3);}
  .badge-off{background:rgba(74,85,104,.3);color:#718096;border:1px solid #4a5568;}
  .badge-ghost{background:rgba(100,110,130,.2);color:#8b949e;border:1px solid #3a3f4b;}

  .state{display:inline-block;padding:2px 7px;border-radius:2px;font-size:10px;font-weight:700;font-family:var(--mono);}
  .state-run{background:#0d2e12;color:#3fb950;}
  .state-ready{background:#1a2a3a;color:#58a6ff;}
  .state-dis{background:#1e2530;color:#8b949e;}

  .cat{display:inline-block;padding:2px 7px;border-radius:2px;font-size:10px;font-weight:700;letter-spacing:.4px;text-transform:uppercase;white-space:nowrap;}
  .cat-tel{background:#1a0a2e;color:#c084fc;}
  .cat-feed{background:#2e1a1a;color:#fca5a5;}
  .cat-xbox{background:#0d2e12;color:#3fb950;}
  .cat-wu{background:#1a2a3a;color:#60a5fa;}
  .cat-def{background:#1a2e1a;color:#4ade80;}
  .cat-disk{background:#2e2a1a;color:#fbbf24;}
  .cat-loc{background:#1a2e2a;color:#34d399;}
  .cat-time{background:#2a1a2e;color:#a78bfa;}
  .cat-rem{background:#2e1a2a;color:#f472b6;}
  .cat-ss{background:#2e2a1a;color:#fb923c;}
  .cat-cloud{background:#1a2030;color:#7dd3fc;}
  .cat-media{background:#2e1a28;color:#e879f9;}
  .cat-net{background:#1a2828;color:#2dd4bf;}
  .cat-text{background:#282020;color:#d8b4fe;}
  .cat-third{background:#2e1a00;color:#f0883e;}
  .cat-sys{background:#1e2530;color:#8b949e;}

  .mono{font-family:var(--mono);}
  .small{font-size:11px;}
  .dim{color:var(--text-dim);}
  .center{text-align:center;}
  .desc{font-size:12px;color:var(--text-dim);max-width:280px;}

  footer{text-align:center;padding:22px;font-family:var(--mono);font-size:11px;color:var(--text-dim);border-top:1px solid var(--border);}
  footer span{color:var(--accent);}
  ::-webkit-scrollbar{width:6px;height:6px;}
  ::-webkit-scrollbar-track{background:var(--bg);}
  ::-webkit-scrollbar-thumb{background:var(--border);border-radius:3px;}
</style>
</head>
<body>

<header>
  <div class="label">// Windows 10 Hardening // Tareas Programadas</div>
  <h1>Informe de <span>Tareas Programadas</span></h1>
  <div class="meta">
    <div><b>Host</b> $hostname</div>
    <div><b>Usuario</b> $user</div>
    <div><b>Fecha</b> $timestamp</div>
    <div><b>CSV</b> $CsvPath</div>
  </div>
</header>

<div class="stats">
  <div class="stat-card total"><div class="stat-num">$countTotal</div><div class="stat-label">Tareas totales</div></div>
  <div class="stat-card danger"><div class="stat-num">$countDanger</div><div class="stat-label">A deshabilitar</div></div>
  <div class="stat-card off"><div class="stat-num">$countOff</div><div class="stat-label">Ya deshabilitadas</div></div>
  <div class="stat-card safe"><div class="stat-num">$countSafe</div><div class="stat-label">Se mantienen</div></div>
  <div class="stat-card ghost"><div class="stat-num">$countGhost</div><div class="stat-label">No existen</div></div>
</div>

<div class="toolbar">
  <label>Filtro:</label>
  <button class="filter-btn active" onclick="filterTable('all',this)">Todas</button>
  <button class="filter-btn" onclick="filterTable('danger',this)">A deshabilitar</button>
  <button class="filter-btn" onclick="filterTable('off',this)">Ya OFF</button>
  <button class="filter-btn" onclick="filterTable('safe',this)">Mantener</button>
  <button class="filter-btn" onclick="filterTable('ghost',this)">No existen</button>
  &nbsp;
  <input type="text" id="searchBox" placeholder="Buscar tarea..." oninput="searchTable()" />
</div>

<div class="table-wrap">
  <table id="mainTable">
    <thead>
      <tr>
        <th>Categoria</th>
        <th>Tarea / Ruta</th>
        <th>Descripcion</th>
        <th>Estado actual</th>
        <th>Ultima ejecucion</th>
        <th>Accion</th>
      </tr>
    </thead>
    <tbody id="tableBody">
      $rows
    </tbody>
  </table>
</div>

<footer>
  Generado por <span>TaskDebloater.ps1</span> &mdash; 4t0m5K &mdash; $timestamp
</footer>

<script>
  var allRows=null;
  function getRows(){if(!allRows)allRows=Array.from(document.querySelectorAll('#tableBody tr'));return allRows;}
  function filterTable(type,btn){
    document.querySelectorAll('.filter-btn').forEach(b=>b.classList.remove('active'));
    btn.classList.add('active');
    var q=document.getElementById('searchBox').value.toLowerCase();
    getRows().forEach(function(row){
      var m=type==='all'||row.classList.contains('row-'+type);
      var s=!q||row.innerText.toLowerCase().includes(q);
      row.style.display=(m&&s)?'':'none';
    });
  }
  function searchTable(){
    var q=document.getElementById('searchBox').value.toLowerCase();
    var active=document.querySelector('.filter-btn.active');
    var type='all';
    if(active){
      var t=active.textContent.trim();
      if(t==='A deshabilitar')type='danger';
      else if(t==='Ya OFF')type='off';
      else if(t==='Mantener')type='safe';
      else if(t==='No existen')type='ghost';
    }
    getRows().forEach(function(row){
      var m=type==='all'||row.classList.contains('row-'+type);
      var s=!q||row.innerText.toLowerCase().includes(q);
      row.style.display=(m&&s)?'':'none';
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
# FUNCION DE DESHABILITADO REAL
# ─────────────────────────────────────────────────────────────
function Invoke-DisableTasks {
    param($TaskList)

    foreach ($task in $TaskList) {
        $fullPath = $task.TaskPath
        $name     = $task.TaskName

        $existing = Get-ScheduledTask -TaskPath $fullPath -TaskName $name -ErrorAction SilentlyContinue
        if (-not $existing) {
            Write-Host "  [-] No existe: $name" -ForegroundColor DarkGray
            continue
        }

        Write-Host "[*] Procesando: $name [$fullPath]" -ForegroundColor Yellow

        # Detener si esta en ejecucion
        if ($existing.State -eq "Running") {
            Stop-ScheduledTask -TaskPath $fullPath -TaskName $name -ErrorAction SilentlyContinue
            Write-Host "  [~] Detenida." -ForegroundColor Cyan
        }

        # Deshabilitar
        if ($existing.State -ne "Disabled") {
            try {
                Disable-ScheduledTask -TaskPath $fullPath -TaskName $name -ErrorAction Stop | Out-Null
                Write-Host "  [+] Deshabilitada correctamente." -ForegroundColor Green
            } catch {
                Write-Host "  [!] Error al deshabilitar: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "  [i] Ya estaba deshabilitada." -ForegroundColor DarkGray
        }
    }
}

# ─────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────
Write-Host "`n[*] Generando informe HTML..." -ForegroundColor Cyan
New-HtmlReport -AllResults $results -OutputPath $ReportPath
Start-Process $ReportPath

if ($Simulate) {
    Write-Host "`n[i] Modo SIMULACION activo. No se ha modificado ninguna tarea." -ForegroundColor Cyan
    Write-Host "    Revisa el informe y ejecuta sin -Simulate para aplicar cambios.`n" -ForegroundColor Yellow
} else {
    Write-Host "`n[!] Se van a deshabilitar $($toDisable.Count) tareas programadas." -ForegroundColor Red
    $confirm = Read-Host "    Escribe 'SI' para confirmar"
    if ($confirm -eq "SI") {
        Write-Host "`n[*] Iniciando deshabilitacion..." -ForegroundColor Yellow
        Invoke-DisableTasks -TaskList $toDisable
        Write-Host "`n[+] Proceso completado.`n" -ForegroundColor Green
    } else {
        Write-Host "`n[i] Cancelado por el usuario." -ForegroundColor DarkGray
    }
}
