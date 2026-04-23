# Función para detener procesos por nombre
function Stop-ProcessByName {
    param (
        [string]$processName
    )
    $processes = Get-Process | Where-Object { $_.Name -eq $processName }
    foreach ($process in $processes) {
        Write-Host "Deteniendo proceso: $($process.Name)"
        Stop-Process -Id $process.Id -Force
    }
}

# Detener procesos de SearchHost.exe
$searchHostProcess = "SearchHost"
Stop-ProcessByName -processName $searchHostProcess

# Detener procesos de smartscreen.exe
$smartScreenProcess = "smartscreen"
Stop-ProcessByName -processName $smartScreenProcess

# Detener procesos de msedgewebview2.exe
$msEdgeWebView2Process = "msedgewebview2"
Stop-ProcessByName -processName $msEdgeWebView2Process

# Detener procesos de TabTip.exe (asociado con el teclado en pantalla de Windows)
$tabTipProcess = "TabTip"
Stop-ProcessByName -processName $tabTipProcess

# Detener procesos de Microsoft Edge Update
$edgeUpdateProcess = "MicrosoftEdgeUpdate"
Stop-ProcessByName -processName $edgeUpdateProcess

# Detener procesos de ctfmon.exe (relacionado con los servicios de entrada de texto)
$ctfmonProcess = "ctfmon"
Stop-ProcessByName -processName $ctfmonProcess

# Deshabilitar los procesos de inicio mediante el registro (si es necesario)
# Eliminar entradas de registro que podrían estar ejecutando estos procesos

# Desactivar SearchHost.exe (Cortana)
$searchHostRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$searchHostRegName = "SearchHost"
if (Test-Path "$searchHostRegPath\$searchHostRegName") {
    Write-Host "Eliminando entrada de registro para $searchHostRegName"
    Remove-ItemProperty -Path $searchHostRegPath -Name $searchHostRegName
}

# Desactivar SmartScreen
$smartScreenRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
$smartScreenRegName = "SmartScreenEnabled"
if (Test-Path "$smartScreenRegPath\$smartScreenRegName") {
    Write-Host "Desactivando SmartScreen"
    Set-ItemProperty -Path $smartScreenRegPath -Name $smartScreenRegName -Value "Off"
}

# Desactivar msedgewebview2 (WebView2)
$webview2RegPath = "HKCU:\Software\Microsoft\EdgeWebView"
$webview2RegName = "WebView2"
if (Test-Path "$webview2RegPath\$webview2RegName") {
    Write-Host "Eliminando WebView2 de la clave de registro"
    Remove-ItemProperty -Path $webview2RegPath -Name $webview2RegName
}

# Desactivar TabTip.exe (Teclado en pantalla)
$tabTipRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$tabTipRegName = "TabTip"
if (Test-Path "$tabTipRegPath\$tabTipRegName") {
    Write-Host "Eliminando entrada de registro para $tabTipRegName"
    Remove-ItemProperty -Path $tabTipRegPath -Name $tabTipRegName
}

# Desactivar MicrosoftEdgeUpdate
$edgeUpdateRegPath = "HKCU:\Software\Microsoft\EdgeUpdate"
$edgeUpdateRegName = "Update"
if (Test-Path "$edgeUpdateRegPath\$edgeUpdateRegName") {
    Write-Host "Eliminando entrada de registro para $edgeUpdateRegName"
    Remove-ItemProperty -Path $edgeUpdateRegPath -Name $edgeUpdateRegName
}

# Desactivar ctfmon.exe
$ctfmonRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$ctfmonRegName = "ctfmon"
if (Test-Path "$ctfmonRegPath\$ctfmonRegName") {
    Write-Host "Eliminando entrada de registro para $ctfmonRegName"
    Remove-ItemProperty -Path $ctfmonRegPath -Name $ctfmonRegName
}

# También puedes desactivar las tareas programadas que podrían estar ejecutando estos procesos.
# Puedes revisar las tareas programadas asociadas con estos procesos, pero en general, desactivar el registro y los procesos ya debería ser suficiente.