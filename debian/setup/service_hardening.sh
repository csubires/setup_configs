#!/usr/bin/env bash
# ============================================================
#  service_hardening.sh — Auditoría de servicios para hardening
#  Genera un informe HTML con los candidatos a deshabilitar.
#  NO modifica nada en el sistema — solo lectura.
#
#  Uso: ./service_hardening.sh [--csv services.csv] [--html out.html]
#  Formato CSV: service,description,category,reason
# ============================================================

set -uo pipefail

RED='\033[0;31m'; YEL='\033[0;33m'; GRN='\033[0;32m'
CYA='\033[0;36m'; BLU='\033[0;34m'; MAG='\033[0;35m'
WHT='\033[1;37m'; DIM='\033[2m';    RST='\033[0m'; BOLD='\033[1m'

CSV_FILE="services_hardening.csv"
HTML_OUT="service_report_$(date +%Y%m%d_%H%M%S).html"
LOG_FILE="hardening_$(date +%Y%m%d_%H%M%S).log"

TOTAL=0; CNT_CANDIDATE=0; CNT_ALREADY_OFF=0; CNT_NOT_FOUND=0; CNT_UNKNOWN=0

ts()      { date '+%Y-%m-%d %H:%M:%S'; }
log()     { echo -e "$1" | tee -a "$LOG_FILE"; }
trim()    { echo "$1" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'; }
section() { log "\n${MAG}▐ ${WHT}${BOLD}$1${RST}"; log "${MAG}$(printf '─%.0s' {1..60})${RST}"; }

header() {
  echo ""
  log "${BLU}╔══════════════════════════════════════════════════════════╗${RST}"
  log "${BLU}║${WHT}   SERVICE HARDENING AUDITOR  //  $(ts)   ${BLU}║${RST}"
  local _hn _un; _hn=$(hostname); _un=$(id -un)
  log "${BLU}║${DIM}   ${_hn} — ${_un}${RST}${BLU}                                          ║${RST}"
  log "${BLU}╚══════════════════════════════════════════════════════════╝${RST}"
  echo ""
}

usage() {
  echo -e "${WHT}Uso:${RST} $0 [opciones]"
  echo -e "  ${CYA}--csv${RST}   <archivo>   CSV de servicios (default: services_hardening.csv)"
  echo -e "  ${CYA}--html${RST}  <archivo>   Salida HTML     (default: service_report_<ts>.html)"
  echo -e "  ${CYA}--help${RST}              Esta ayuda"
  echo -e "\n  ${DIM}Solo lectura — no modifica el sistema.${RST}"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --csv)  CSV_FILE="$2"; shift 2 ;;
    --html) HTML_OUT="$2"; shift 2 ;;
    --help) usage ;;
    *)      echo -e "${RED}[!] Opción desconocida: $1${RST}"; usage ;;
  esac
done

[[ ! -f "$CSV_FILE" ]] && { echo -e "${RED}[✗] CSV no encontrado: $CSV_FILE${RST}"; exit 1; }
command -v systemctl &>/dev/null || { echo -e "${RED}[✗] systemctl no disponible${RST}"; exit 1; }

get_service_status() {
  local svc="$1"
  if ! systemctl list-unit-files --type=service 2>/dev/null | grep -q "^${svc}\.service"; then
    if ! systemctl cat "${svc}.service" &>/dev/null; then
      echo "NOT_FOUND"; return
    fi
  fi
  local enabled active
  enabled=$(systemctl is-enabled "${svc}.service" 2>/dev/null || echo "not-found")
  active=$(systemctl  is-active  "${svc}.service" 2>/dev/null || echo "inactive")
  case "$enabled" in
    masked)                                    echo "MASKED"           ;;
    disabled)
      [[ "$active" == "active" ]] && echo "DISABLED_RUNNING" || echo "DISABLED" ;;
    enabled|enabled-runtime|static|indirect)
      [[ "$active" == "active" ]] && echo "ACTIVE" || echo "ENABLED_STOPPED" ;;
    not-found)                                 echo "NOT_FOUND"        ;;
    *)                                         echo "UNKNOWN"          ;;
  esac
}

cat_css() {
  case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
    conectividad|red)              echo "cat-net"   ;;
    impresión|impresion)           echo "cat-feed"  ;;
    vpn)                           echo "cat-cloud" ;;
    firewall)                      echo "cat-def"   ;;
    logs)                          echo "cat-sys"   ;;
    autenticación|autenticacion)   echo "cat-rem"   ;;
    privacidad)                    echo "cat-loc"   ;;
    accesibilidad)                 echo "cat-text"  ;;
    administración|administracion) echo "cat-wu"    ;;
    contenedores)                  echo "cat-xbox"  ;;
    almacenamiento)                echo "cat-disk"  ;;
    hardware)                      echo "cat-disk"  ;;
    virtualización|virtualizacion) echo "cat-cloud" ;;
    audio)                         echo "cat-media" ;;
    directorio)                    echo "cat-rem"   ;;
    selinux)                       echo "cat-def"   ;;
    dns)                           echo "cat-net"   ;;
    paquetes)                      echo "cat-wu"    ;;
    correo)                        echo "cat-feed"  ;;
    *)                             echo "cat-sys"   ;;
  esac
}

html_row() {
  local svc="$1" desc="$2" cat="$3" reason="$4" status="$5"
  local row_class badge_class badge_txt state_class state_txt
  local cat_class; cat_class=$(cat_css "$cat")
  case "$status" in
    ACTIVE)
      row_class="row-danger"; badge_class="badge-danger"; badge_txt="Candidato"
      state_class="state-run"; state_txt="running" ;;
    ENABLED_STOPPED)
      row_class="row-danger"; badge_class="badge-danger"; badge_txt="Candidato"
      state_class="state-ready"; state_txt="stopped" ;;
    DISABLED_RUNNING)
      row_class="row-danger"; badge_class="badge-danger"; badge_txt="Candidato"
      state_class="state-run"; state_txt="dis+running" ;;
    DISABLED|MASKED)
      row_class="row-off"; badge_class="badge-off"; badge_txt="Ya OFF"
      state_class="state-dis"; state_txt="disabled" ;;
    NOT_FOUND)
      row_class="row-ghost"; badge_class="badge-ghost"; badge_txt="No existe"
      state_class="state-dis"; state_txt="-" ;;
    *)
      row_class="row-safe"; badge_class="badge-ghost"; badge_txt="Desconocido"
      state_class="state-dis"; state_txt="?" ;;
  esac
  printf '        <tr class="%s">\n' "$row_class"
  printf '            <td><span class="cat %s">%s</span></td>\n' "$cat_class" "$cat"
  printf '            <td><strong>%s</strong><br><small class="mono dim">%s.service</small></td>\n' "$svc" "$svc"
  printf '            <td class="desc">%s</td>\n' "$desc"
  printf '            <td class="desc dim">%s</td>\n' "$reason"
  printf '            <td class="center"><span class="state %s">%s</span></td>\n' "$state_class" "$state_txt"
  printf '            <td class="center"><span class="badge %s">%s</span></td>\n' "$badge_class" "$badge_txt"
  printf '        </tr>\n'
}

write_html() {
  local hn user dt csv_abs
  hn=$(hostname); user=$(id -un)
  dt=$(date '+%d/%m/%Y %H:%M:%S')
  csv_abs=$(realpath "$CSV_FILE" 2>/dev/null || echo "$CSV_FILE")
  cat <<HTML
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Hardening — Servicios — ${hn}</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Barlow:wght@300;400;600;700;900&display=swap');
  :root{--bg:#0a0c10;--surface:#0f1318;--border:#1e2530;--accent:#f4a261;--accent2:#00b4d8;
    --green:#2dc653;--off:#4a5568;--ghost:#3a3f4b;--text:#c9d1d9;--text-dim:#8b949e;
    --mono:'Share Tech Mono',monospace;--sans:'Barlow',sans-serif;}
  *{box-sizing:border-box;margin:0;padding:0;}
  body{background:var(--bg);color:var(--text);font-family:var(--sans);font-size:14px;line-height:1.6;}
  header{background:linear-gradient(135deg,#0d1117 0%,#161b22 55%,#0a1200 100%);
    border-bottom:2px solid var(--accent);padding:40px 48px 32px;position:relative;overflow:hidden;}
  header::before{content:'';position:absolute;top:-60px;right:-60px;width:300px;height:300px;
    border-radius:50%;background:radial-gradient(circle,rgba(244,162,97,.13) 0%,transparent 70%);pointer-events:none;}
  header .label{font-family:var(--mono);font-size:11px;letter-spacing:3px;color:var(--accent);text-transform:uppercase;margin-bottom:8px;}
  header h1{font-size:34px;font-weight:900;letter-spacing:-1px;color:#fff;}
  header h1 span{color:var(--accent);}
  header .meta{margin-top:12px;font-family:var(--mono);font-size:12px;color:var(--text-dim);display:flex;gap:32px;flex-wrap:wrap;}
  header .meta b{color:var(--accent2);}
  .stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(155px,1fr));gap:16px;
    padding:28px 48px;background:var(--surface);border-bottom:1px solid var(--border);}
  .stat-card{background:var(--bg);border:1px solid var(--border);border-radius:8px;
    padding:18px 22px;position:relative;overflow:hidden;}
  .stat-card::after{content:'';position:absolute;bottom:0;left:0;right:0;height:3px;}
  .stat-card.danger::after{background:var(--accent);}
  .stat-card.off::after{background:var(--off);}
  .stat-card.ghost::after{background:var(--ghost);}
  .stat-card.total::after{background:var(--accent2);}
  .stat-num{font-size:38px;font-weight:900;line-height:1;margin-bottom:4px;}
  .stat-card.danger .stat-num{color:var(--accent);}
  .stat-card.off .stat-num{color:var(--off);}
  .stat-card.ghost .stat-num{color:var(--ghost);}
  .stat-card.total .stat-num{color:var(--accent2);}
  .stat-label{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:var(--text-dim);}
  .toolbar{padding:18px 48px;display:flex;gap:10px;flex-wrap:wrap;align-items:center;
    border-bottom:1px solid var(--border);background:var(--surface);}
  .toolbar label{font-size:12px;text-transform:uppercase;letter-spacing:1px;color:var(--text-dim);margin-right:4px;}
  .filter-btn{background:var(--bg);border:1px solid var(--border);color:var(--text);padding:5px 13px;
    border-radius:4px;cursor:pointer;font-family:var(--sans);font-size:12px;font-weight:600;
    letter-spacing:.5px;transition:all .15s;}
  .filter-btn:hover,.filter-btn.active{border-color:var(--accent2);color:var(--accent2);}
  .filter-btn.active{background:rgba(0,180,216,.1);}
  input#searchBox{background:var(--bg);border:1px solid var(--border);color:var(--text);padding:5px 13px;
    border-radius:4px;font-family:var(--mono);font-size:12px;width:260px;outline:none;}
  input#searchBox:focus{border-color:var(--accent2);}
  .table-wrap{padding:24px 48px 48px;overflow-x:auto;}
  table{width:100%;border-collapse:collapse;font-size:13px;}
  thead th{background:#0d1117;border-bottom:2px solid var(--border);padding:11px 13px;text-align:left;
    font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:1.5px;color:var(--text-dim);white-space:nowrap;}
  tbody tr{border-bottom:1px solid var(--border);transition:background .1s;}
  tbody tr:hover{background:rgba(255,255,255,.03);}
  tbody td{padding:9px 13px;vertical-align:middle;}
  .row-danger{background:rgba(244,162,97,.04);}
  .row-off{background:rgba(74,85,104,.06);}
  .row-ghost{opacity:.4;}
  .badge{display:inline-block;padding:3px 9px;border-radius:3px;font-size:11px;font-weight:700;
    letter-spacing:.7px;text-transform:uppercase;font-family:var(--mono);}
  .badge-danger{background:rgba(244,162,97,.2);color:#f4a261;border:1px solid rgba(244,162,97,.4);}
  .badge-off{background:rgba(74,85,104,.3);color:#718096;border:1px solid #4a5568;}
  .badge-ghost{background:rgba(100,110,130,.2);color:#8b949e;border:1px solid #3a3f4b;}
  .state{display:inline-block;padding:2px 8px;border-radius:2px;font-size:10px;font-weight:700;font-family:var(--mono);}
  .state-run{background:#2e0d0d;color:#e05555;}
  .state-ready{background:#1a2a3a;color:#58a6ff;}
  .state-dis{background:#1e2530;color:#8b949e;}
  .cat{display:inline-block;padding:2px 7px;border-radius:2px;font-size:10px;font-weight:700;
    letter-spacing:.4px;text-transform:uppercase;white-space:nowrap;}
  .cat-net{background:#1a2828;color:#2dd4bf;}.cat-feed{background:#2e1a1a;color:#fca5a5;}
  .cat-xbox{background:#0d2e12;color:#3fb950;}.cat-wu{background:#1a2a3a;color:#60a5fa;}
  .cat-def{background:#1a2e1a;color:#4ade80;}.cat-disk{background:#2e2a1a;color:#fbbf24;}
  .cat-loc{background:#1a2e2a;color:#34d399;}.cat-rem{background:#2e1a2a;color:#f472b6;}
  .cat-cloud{background:#1a2030;color:#7dd3fc;}.cat-media{background:#2e1a28;color:#e879f9;}
  .cat-text{background:#282020;color:#d8b4fe;}.cat-sys{background:#1e2530;color:#8b949e;}
  .mono{font-family:var(--mono);}.dim{color:var(--text-dim);}.center{text-align:center;}
  .desc{font-size:12px;color:var(--text-dim);max-width:260px;}
  .audit-banner{background:rgba(0,180,216,.06);border:1px solid rgba(0,180,216,.25);border-radius:6px;
    padding:11px 24px;margin:20px 48px;font-family:var(--mono);font-size:12px;color:var(--accent2);}
  footer{text-align:center;padding:22px;font-family:var(--mono);font-size:11px;
    color:var(--text-dim);border-top:1px solid var(--border);}
  footer span{color:var(--accent);}
  ::-webkit-scrollbar{width:6px;height:6px;}
  ::-webkit-scrollbar-track{background:var(--bg);}
  ::-webkit-scrollbar-thumb{background:var(--border);border-radius:3px;}
</style>
</head>
<body>
<header>
  <div class="label">// Linux Hardening // Auditoría de Servicios</div>
  <h1>Informe de <span>Hardening</span> — Servicios</h1>
  <div class="meta">
    <div><b>Host</b> ${hn}</div>
    <div><b>Usuario</b> ${user}</div>
    <div><b>Fecha</b> ${dt}</div>
    <div><b>CSV</b> ${csv_abs}</div>
  </div>
</header>
<div class="stats">
  <div class="stat-card total"><div class="stat-num">${TOTAL}</div><div class="stat-label">Evaluados</div></div>
  <div class="stat-card danger"><div class="stat-num">${CNT_CANDIDATE}</div><div class="stat-label">Candidatos</div></div>
  <div class="stat-card off"><div class="stat-num">${CNT_ALREADY_OFF}</div><div class="stat-label">Ya deshabilitados</div></div>
  <div class="stat-card ghost"><div class="stat-num">${CNT_NOT_FOUND}</div><div class="stat-label">No instalados</div></div>
</div>
<div class="audit-banner">ℹ️ &nbsp;MODO AUDITORÍA — Solo lectura. Ningún servicio ha sido modificado.</div>
<div class="toolbar">
  <label>Filtro:</label>
  <button class="filter-btn active" onclick="filterTable('all',this)">Todos</button>
  <button class="filter-btn" onclick="filterTable('danger',this)">Candidatos</button>
  <button class="filter-btn" onclick="filterTable('off',this)">Ya OFF</button>
  <button class="filter-btn" onclick="filterTable('ghost',this)">No instalados</button>
  <input type="text" id="searchBox" placeholder="Buscar servicio..." oninput="searchTable()">
</div>
<div class="table-wrap">
  <table>
    <thead><tr>
      <th>Categoría</th><th>Servicio</th><th>Descripción</th>
      <th>Razón de deshabilitar</th><th class="center">Estado actual</th><th class="center">Resultado</th>
    </tr></thead>
    <tbody id="tableBody">
HTML
  for row in "${HTML_ROWS[@]}"; do printf '%s\n' "$row"; done
  cat <<'FOOT'
    </tbody>
  </table>
</div>
<footer>Generado por <span>service_hardening.sh</span> &mdash; 4t0m5K</footer>
<script>
  var allRows=null;
  function getRows(){if(!allRows)allRows=Array.from(document.querySelectorAll('#tableBody tr'));return allRows;}
  function filterTable(type,btn){
    document.querySelectorAll('.filter-btn').forEach(b=>b.classList.remove('active'));
    btn.classList.add('active');
    var q=document.getElementById('searchBox').value.toLowerCase();
    getRows().forEach(function(r){
      var m=type==='all'||r.classList.contains('row-'+type);
      var s=!q||r.innerText.toLowerCase().includes(q);
      r.style.display=(m&&s)?'':'none';
    });
  }
  function searchTable(){
    var q=document.getElementById('searchBox').value.toLowerCase();
    var act=document.querySelector('.filter-btn.active'),type='all';
    if(act){var t=act.textContent.trim();
      if(t==='Candidatos')type='danger';
      else if(t==='Ya OFF')type='off';
      else if(t==='No instalados')type='ghost';}
    getRows().forEach(function(r){
      var m=type==='all'||r.classList.contains('row-'+type);
      var s=!q||r.innerText.toLowerCase().includes(q);
      r.style.display=(m&&s)?'':'none';
    });
  }
</script>
</body></html>
FOOT
}

# ═══════════════════════ MAIN ═══════════════════════════════
header
log "${CYA}[*]${RST} CSV fuente  : ${WHT}${CSV_FILE}${RST}"
log "${CYA}[*]${RST} Informe HTML: ${WHT}${HTML_OUT}${RST}"
log "${CYA}[*]${RST} Log         : ${WHT}${LOG_FILE}${RST}"
log "${DIM}    Solo lectura — el sistema no será modificado${RST}"

section "Auditando servicios del sistema"

declare -a HTML_ROWS=()

while IFS=',' read -r svc desc cat reason; do
  [[ "$svc" == "service" ]] && continue
  [[ -z "$svc" || "$svc" == \#* ]] && continue
  svc=$(trim "$svc"); desc=$(trim "$desc"); cat=$(trim "$cat"); reason=$(trim "$reason")
  [[ -z "$svc" ]] && continue

  TOTAL=$((TOTAL + 1))
  STATUS=$(get_service_status "$svc")

  case "$STATUS" in
    ACTIVE|ENABLED_STOPPED|DISABLED_RUNNING)
      log "${YEL}  [▲]${RST} ${WHT}${svc}${RST}  →  ${RED}${STATUS}${RST}  ${DIM}(${cat})${RST}"
      CNT_CANDIDATE=$((CNT_CANDIDATE + 1)) ;;
    DISABLED|MASKED)
      log "${GRN}  [✔]${RST} ${WHT}${svc}${RST}  →  ${DIM}ya deshabilitado${RST}"
      CNT_ALREADY_OFF=$((CNT_ALREADY_OFF + 1)) ;;
    NOT_FOUND)
      log "${DIM}  [–]  ${svc}  →  no instalado${RST}"
      CNT_NOT_FOUND=$((CNT_NOT_FOUND + 1)) ;;
    *)
      log "${BLU}  [?]${RST} ${WHT}${svc}${RST}  →  ${DIM}estado desconocido${RST}"
      CNT_UNKNOWN=$((CNT_UNKNOWN + 1)) ;;
  esac

  HTML_ROWS+=("$(html_row "$svc" "$desc" "$cat" "$reason" "$STATUS")")
done < "$CSV_FILE"

section "Resumen"
log "  ${WHT}Total evaluados    :${RST} ${CYA}${TOTAL}${RST}"
log "  ${WHT}Candidatos a desh. :${RST} ${YEL}${CNT_CANDIDATE}${RST}"
log "  ${WHT}Ya deshabilitados  :${RST} ${GRN}${CNT_ALREADY_OFF}${RST}"
log "  ${WHT}No instalados      :${RST} ${DIM}${CNT_NOT_FOUND}${RST}"
[[ $CNT_UNKNOWN -gt 0 ]] && log "  ${WHT}Estado desconocido :${RST} ${DIM}${CNT_UNKNOWN}${RST}"

section "Generando informe HTML"
write_html > "$HTML_OUT"

log "${GRN}[✔]${RST} Informe → ${WHT}${HTML_OUT}${RST}"
log "${GRN}[✔]${RST} Log     → ${WHT}${LOG_FILE}${RST}"
echo ""
log "${BLU}╔══════════════════════════════════════════════════════════╗${RST}"
log "${BLU}║  ${GRN}AUDITORÍA COMPLETADA${RST}${BLU}                                     ║${RST}"
log "${BLU}╚══════════════════════════════════════════════════════════╝${RST}"
