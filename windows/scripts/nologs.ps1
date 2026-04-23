# Ejecutar como Administrador

# Obtener todos los logs
$logs = wevtutil el

foreach ($log in $logs) {
    try {
        Write-Host "Desactivando log: $log"

        # Intentar deshabilitar el log
        wevtutil sl "$log" /e:false

    } catch {
        Write-Host "No se pudo desactivar: $log"
    }
}

Write-Host "Proceso completado."

# Ejecutar como Administrador

# Obtener todos los logs del sistema
$logs = wevtutil el

# Desactivar logs de eventos
foreach ($log in $logs) {
    try {
        Write-Host "Desactivando log: $log"

        # Intentar deshabilitar el log
        wevtutil sl "$log" /e:false
    } catch {
        Write-Host "No se pudo desactivar: $log"
    }
}

# Desactivar logs específicos de WMI (incluyendo Wifi.etl)
$wmiLogs = @(
    "Microsoft-Windows-WMI-Activity/Operational",
    "Microsoft-Windows-WLAN-AutoConfig/Operational",
    "Microsoft-Windows-Diagnostics-Performance/Operational",
    "Microsoft-Windows-WMI-Client/Operational"
)

foreach ($log in $wmiLogs) {
    try {
        Write-Host "Desactivando log WMI: $log"
        wevtutil sl "$log" /e:false
    } catch {
        Write-Host "No se pudo desactivar el log WMI: $log"
    }
}

Write-Host "Proceso completado."