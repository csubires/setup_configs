##########
# Win10 
# Author   : 4t0m5K
# Resource : Win10-Initial-Setup-Script v2.10, 2017-11-09
# Resource : AikonCwd Script v5.3
# Version  : 0.5 22/10/2017
# Update   : Jul 11, 2023
##########


# ----------------------------------------------- FUNCIONES AUXILIARES

function isAdmin {
 #Returns true/false
   ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

# Obtener la respuesta y filtrarla
function getKeyPress() {
  $ok = 0
  do { 
    #cls
    $i = Read-Host "`n`tElegir una Opción "
    $charArray = $i.ToCharArray()
    if ( $charArray[0] -eq 's') { $ok = -2 }
    elseif ($i -match "^[\d\.]+$") { $ok = $i -as [Double] }
    else { $ok = -1}
  } until ( $ok -ne -1)
  return $ok
}

# Presiona cualquier tecla para continuar
function WaitForKey {
  Write-Host "`t`nPresiona cualquier tecla para continuar..." -NoNewLine -ForegroundColor Black -BackgroundColor White
  [Console]::ReadKey($true) | Out-Null
}

# ---------------------------------------------- FUNCIONES AUXILIARES



# Borrar una clave del registro
function removeKey {
  Param ( [String] $path )
  Write-Host "Borrando la clave $path"
  Remove-Item -Path $path -Recurse -ErrorAction SilentlyContinue
  if ((Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue) -eq 0) {
    Write-Host "La clave se ELIMINÓ CORRECTAMENTE" -F Green
  } Else {
    Write-Host "La clave NO se puedo ELIMINAR" -F Red
  }
}

# Cambiar el valor de una clave del registro de Windows
function setKeyValue {
  Param ( [String] $path, [string] $key, [string] $typ, $val )
  Write-Host "Creando o cambiando el valor de $path : [$key] con Valor: $val"
  if (Test-Path $path) {
    if ($typ -eq "DWord") {
      Set-ItemProperty -Path $path -Name $key -Type DWord -Value $val | Out-Null
    } elseif ($typ -eq "String") {
      Set-ItemProperty -Path $path -Name $key -Typ String -Value $val | Out-Null
    } elseif ($typ -eq "Binary") {
      Set-ItemProperty -Path $path -Name $key -Typ Binary -Value $val | Out-Null
    } else {
      Write-Host "Tipo de valor $typ DESCONOCIDO." -F Red
    }
    if (Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue) {
      Write-Host "La clave se creó o modificó CORRECTAMENTE" -F Green
    } Else {
      Write-Host "La clave NO se puedo CREAR ni MODIFICAR" -F Red
    }
    return 1
  } else {
    Write-Host "La ruta $path NO EXISTE" -F Red
    return 0
  }
}


# Crea una nueva ruta en el registro de Windoes si está no existe
function createKey {
  Param ( [String] $path )
  Write-Host "Creando la ruta $path ..."
  if (!(Test-Path $path)) {
    New-Item -Path $path -Force | Out-Null
    if (Test-Path $path) { 
        Write-Host "La ruta $path se creó CORRECTAMENTE" -F Green
      } else {
        Write-Host "No se pudo CREAR la ruta $path" -F Red
      }
  } else {
    Write-Host "La ruta $path ya EXISTE" -F Yellow
  }
}


# Desinstala una aplicación de Windows mediante power-shell
function uninstallApp {
  Param ( [String] $path )
  Write-Host "Desintalando $path ..."
  if ( (Get-AppxPackage $path).PackageFullName) {
    Get-AppxPackage $path | Remove-AppxPackage
    if ( (Get-AppxPackage $path).PackageFullName) {
       Write-Host "No se puedo Desinstalar $path ..." -F Red
    } else {
       Write-Host "La APP se desintaló CORRECTAMENTE $path ..." -F Green
    }
  } else {
    Write-Host "No existe el paquete $path." -F Yellow
  }
}

# Detiene y deshabilita un servicio de Windows
function disableService {
  Param ( [String] $path, [String] $typ )
  Write-Host "Deteniendo o deshabilitando el servicio $name [$path] ..." 
  if ( Get-Service $path -ErrorAction SilentlyContinue) {
    if ( (Get-Service $path).Status -eq 'Running' ) {
      $name = (Get-Service $path).DisplayName
      Write-Host "Deteniendo $name [$path] ..." 
      Stop-Service $path -Force -WarningAction SilentlyContinue
      if ( (Get-Service $path).Status -eq 'Stopped' ) {
        Write-Host "Servicio $name [$path] DETENIDO" -F Green
      }
    } else { 
      Write-Host "El servicio $path ya está detenido." -F Yellow
    }
    if ($typ -eq "Disabled") {
      Write-Host "Deshabilitando $name [$path] ..."
      Set-Service $path -StartupType Disabled 
      if ( (Get-Service $path).StartType -eq 'Disabled' ) {
        Write-Host "Servicio $name [$path] DESHABILITADO" -F Green
      }
    } elseif ($typ -eq "Manual") {
      Write-Host "Pasando a modo manual $name [$path] ..."
      Set-Service $path -StartupType Manual  
      if ( (Get-Service $path).StartType -eq 'Manual' ) {
        Write-Host "Servicio $name [$path] EN MANUAL" -F Green
      }
    }
  } else {
    Write-Host "NO EXISTE el servicio $path." -F Red
  }
}

function disableScheduledTask {
  Param ( [String] $path, [String] $name )
  if ( (Get-ScheduledTask -TaskPath $path -TaskName $name).State -eq 'Running' ) {
    Write-Host "Deteniendo la tarea $name [$path] ..." 
    Stop-ScheduledTask -TaskPath $path -TaskName $name -ErrorAction SilentlyContinue | Out-Null
    if ( (Get-ScheduledTask -TaskPath $path -TaskName $name).State -eq 'Ready' ) {
      Write-Host "La tarea $name [$path] fué DETENIDA" -F Green
    } else {
        Write-Host "La tarea $name [$path] no se pudo detener" -F Red
    }
  } else {
    Write-Host "La tarea $name [$path] ya estaba detenida" -F Yellow
  }
  if ( (Get-ScheduledTask -TaskPath $path -TaskName $name).State -ne 'Disabled' ) {
    Write-Host "Deshabilitando la tarea $name [$path] ..." 
    Disable-ScheduledTask -TaskPath $path -TaskName $name -ErrorAction SilentlyContinue | Out-Null
    if ( (Get-ScheduledTask -TaskPath $path -TaskName $name).State -eq 'Ready' ) {
      Write-Host "La tarea $name [$path] fué DESHABILITADA" -F Green
    } else {
      Write-Host "La tarea $name [$path] no se pudo deshabilitar" -F Red
    }
  } else {
    Write-Host "La tarea $name [$path] ya estaba deshabilitada" -F Yellow
  }
}

# #########################################################################################################################################


# ---------------------------------------------- PRIVACIDAD y CONFIGURACIÓN SUBMENU 1

# 1) Deshabilitar telemetría
function DisableTelemetry {
  Write-Host "Deshabilitando telemetría..."
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -key "AllowTelemetry" -typ DWord -val 0
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -key "AllowTelemetry" -typ DWord -val 0
  setKeyValue -path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -key "AllowTelemetry" -typ DWord -val 0
  disableScheduledTask -path "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
  disableScheduledTask -path "Microsoft\Windows\Application Experience\ProgramDataUpdater"
  disableScheduledTask -path "Microsoft\Windows\Autochk\Proxy"
  disableScheduledTask -path "Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
  disableScheduledTask -path "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
  disableScheduledTask -path "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"


}

# 2) Deshabilitar Wi-Fi Sense (Compartir Wifi desde Windows)
function DisableWiFiSense {
  Write-Host "Deshabilitando Wi-Fi Sense (Compartir Wifi desde Windows)..."
  createKey -path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting"
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -key "Value" -typ "DWord" -val 0
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -key "Value" -typ "DWord" -val 0
  createKey -path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -key "AutoConnectAllowedOEM" -typ "DWord" -val 0
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -key "WiFISenseAllowed" -typ "DWord" -val 0
}

# 3) Deshabilitar SmartScreen Filter (Previene la ejecución de programas que no este en la lista blanca de Microsoft)
function DisableSmartScreen {
  Write-Host "Deshabilitando SmartScreen Filter..."
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -key "SmartScreenEnabled" -typ "String" -val "Off"
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -key "EnableWebContentEvaluation" -typ "DWord" -val 0
  $edge = (Get-AppxPackage -AllUsers "Microsoft.MicrosoftEdge").PackageFamilyName
  createKey -path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\PhishingFilter"
  setKeyValue -path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\PhishingFilter" -key "EnabledV9" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\PhishingFilter" -key "PreventOverride" -typ "DWord" -val 0
}

# 4) Deshabilitar Web Search in Start Menu (Buscador en Bing desde Windows)
function DisableWebSearch {
  Write-Host "Disabling Bing Search in Start Menu..."
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -key "BingSearchEnabled" -typ "DWord" -val 0
  createKey -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -key "DisableWebSearch" -typ "DWord" -val 1
}

# 5) Deshabilitar Application suggestions and automatic installation (Windows te sugiere que instales aplicaciones)
function DisableAppSuggestions {
  Write-Host "Deshabilitando Sugerencias de aplicaciones..."
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "ContentDeliveryAllowed" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "OemPreInstalledAppsEnabled" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "PreInstalledAppsEnabled" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "PreInstalledAppsEverEnabled" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "SilentInstalledAppsEnabled" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "SubscribedContent-338389Enabled" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "SystemPaneSuggestionsEnabled" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "SubscribedContent-338388Enabled" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "SubscribedContent-310093Enabled" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "SubscribedContent-338387Enabled" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "SubscribedContent-338393Enabled" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "SubscribedContent-353696Enabled" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "SubscribedContent-353698Enabled" -typ "DWord" -val 0
  createKey -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -key "DisableWindowsConsumerFeatures" -typ "DWord" -val 1
}


# 6) Deshabilitar Background application access (No permitir que aplicaciones se descargen o actualicen en segundo plano)
function DisableBackgroundApps {
  Write-Host "Deshabilitando aplicaciones en segundo plano..."
  Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Exclude "Microsoft.Windows.Cortana*" | ForEach {
    setKeyValue -path $_.PsPath -key "Disabled" -typ "DWord" -val 1
    setKeyValue -path $_.PsPath -key "DisabledByUser" -typ "DWord" -val 1
  }
  # Desabilitar app en segundo plano 
  setKeyValue -path "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -key "GlobalUserDisabled " -typ "Dword" -val 0
}

# 7) Deshabilitar Lock screen Spotlight (Quitar anuncios en la ventana de bloqueo)
function DisableLockScreenSpotlight {
  Write-Host "Deshabilitando anuncios en la ventana de bloqueo..."
  setKeyValue -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "RotatingLockScreenEnabled" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "RotatingLockScreenOverlayEnabled" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -key "SubscribedContent-338387Enabled" -typ "DWord" -val 0
}

# 8) Deshabilitar Location Tracking (Seguimiento de la localización)
function DisableLocationTracking {
  Write-Host "Deshabilitando seguimiento de localización..."
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -key "SensorPermissionState" -typ "DWord" -val 0
  setKeyValue -path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -key "Status" -typ "DWord" -val 0
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -key "Value" -typ "String" -val "Deny"
}

# 9) Deshabilitar automatic Maps updates (Descarga de mapas)
function DisableMapUpdates {
  Write-Host "Deshabilitando descarga de mapas automatico..."
  setKeyValue -path "HKLM:\SYSTEM\Maps" -key "AutoUpdateEnabled" -typ "DWord" -val 0
}

# 10) Deshabilitar Feedback
function DisableFeedback {
  Write-Host "Deshabilitando Feedback..."
  createKey -path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -key "NumberOfSIUFInPeriod" -typ "DWord" -val 0
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -key "DoNotShowFeedbackNotifications" -typ "DWord" -val 1
  disableScheduledTask -path "Microsoft\Windows\Feedback\Siuf\DmClient"
  disableScheduledTask -path "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
}

# 11) Deshabilitar Advertising ID (ID unico para publicidad a medida)
function DisableAdvertisingID {
  Write-Host "Deshabilitando Advertising ID..."
  createKey -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -key "Enabled" -typ "DWord" -val 0
  createKey -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -key "TailoredExperiencesWithDiagnosticDataEnabled" -typ "DWord" -val 0
}

# 12) Deshabilitar Cortana
function DisableCortana {
  Write-Host "Deshabilitando Cortana..."
  createKey -path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -key "AcceptedPrivacyPolicy" -typ "DWord" -val 0
  createKey -path "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -key "RestrictImplicitTextCollection" -typ "DWord" -val 1
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -key "RestrictImplicitInkCollection" -typ "DWord" -val 1
  createKey -path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -key "HarvestContacts" -typ "DWord" -val 0
  createKey -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -key "AllowCortana" -typ "DWord" -val 0
  createKey -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -key "AllowSearchToUseLocation" -typ "DWord" -val 0
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -key "DisableWebSearch" -typ "DWord" -val 1
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -key "ConnectedSearchUseWeb" -typ "DWord" -val 0
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -key "SearchboxTaskbarMode" -typ "DWord" -val 0


  taskkill.exe /F /IM SearchUI.exe
  ren "C:\Windows\SystemApps\SearchUIC.exe" "SearchUIC.exe"
  rd "C:\Windows\SystemApps\SearchUIC.exe"

}

# 13) Deshabilitar Error reporting (Mandar errores a Microsoft)
function DisableErrorReporting {
  Write-Host "Deshabilitando reporte de errores..."
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -key "Disabled" -typ "DWord" -val 1
  disableScheduledTask -path "Microsoft\Windows\Windows Error Reporting\QueueReporting"

}

# 14) Restringir Windows Update P2P solo a la red local
function SetP2PUpdateLocal {
  Write-Host "Restringiendo update P2P a la red local..."
  createKey -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -key "DODownloadMode" -typ "DWord" -val 1
  createKey -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization"
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" -key "SystemSettingsDownloadMode" -typ "DWord" -val 3
}

# 15) Eliminar archivo AutoLogger y restringir directorio
function DisableAutoLogger {
  Write-Host "Eliminando AutoLogger..."
  $autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
  if (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl") {
    Remove-Item -Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"
  }
  #$baseExp = "icacls " + $autoLoggerDir + " /deny SYSTEM:(OI)(CI)(F) | Out-Null"
  #Invoke-Expression -Command $baseExp
  icacls $autoLoggerDir /deny SYSTEM:`(OI`)`(CI`)F | Out-Null
}

# 16) Elevar nivel UAC
function SetUACHigh {
  Write-Host "Elevar el nivel de seguridad UAC..."
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -key "ConsentPromptBehaviorAdmin" -typ "DWord" -val 2
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -key "ConsentPromptBehaviorUser" -typ "DWord" -val 3
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -key "PromptOnSecureDesktop" -typ "DWord" -val 1
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -key "EnableInstallerDetection" -typ "DWord" -val 1
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -key "EnableLUA" -typ "DWord" -val 1
}

# 17) Deshabilitar mapeo de dispositivos compartidos entre usuarios
function DisableSharingMappedDrives {
  Write-Host "Deshabilitando mapeo de dispositivos compartidos entre usuarios..."
  Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections" -ErrorAction SilentlyContinue
}

# 18) Deshabilitar recursos compartidos implicitos administrativos 
function DisableAdminShares {
  Write-Host "Deshabilitando recursos implicitos compartidos..."
  setKeyValue -path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -key "AutoShareWks" -typ "DWord" -val 0
}

# 19) Deshabilitar SMB protocolo 1.0
function DisableSMB1 {
  Write-Host "Deshabilitando protocolo SMB 1.0 & 2..."
  $adapters=(gwmi win32_networkadapterconfiguration )
  Foreach ($adapter in $adapters){
    Write-Host $adapter
    $adapter.settcpipnetbios(2)
  }
  Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
  Set-SmbServerConfiguration -EnableSMB2Protocol $false -Force
}

# 20) Habilitar acceso controlado a carpetas (Defender Exploit Guard feature)
function EnableCtrldFolderAccess {
  Write-Host "Habilitando acceso controlado a carpetas..."
  Set-MpPreference -EnableControlledFolderAccess Enabled
}

# 21) Deshabilitando Firewall
function DisableFirewall {
  Write-Host "Deshabilitando Firewall de Windows (!Instalar otro en su lugar¡)..."
  createKey -path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile"
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -key "EnableFirewall" -typ "DWord" -val 0
}

# 22) Deshabilitar Windows Defender Cloud
function DisableDefenderCloud {
  Write-Host "Deshabilitando Windows Defender Cloud..."
  createKey -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet"
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -key "SpynetReporting" -typ "DWord" -val 0
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -key "SubmitSamplesConsent" -typ "DWord" -val 2
}

# 23) Deshabilitar experiencias compartidas - Not applicable to Server
function DisableSharedExperiences {
  Write-Host "Deshabilitando Experiencias Compartidas..."
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP" -key "RomeSdkChannelUserAuthzPolicy" -typ "DWord" -val 0
}

# 24) Deshabilitar Asistencia remota
function DisableRemoteAssistance {
  Write-Host "Deshabilitando Asistencia Remota..."
  setKeyValue -path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -key "fAllowToGetHelp" -typ "DWord" -val 0
  setKeyValue -path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -key "fAllowFullControl" -typ "DWord" -val 0
  setKeyValue -path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -key "fEnableChatControl" -typ "DWord" -val 0
}

# 25) Deshabilitar Escritorio Remoto
function DisableRemoteDesktop {
  Write-Host "Deshabilitando Escritorio Remoto..."
  setKeyValue -path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -key "fDenyTSConnections" -typ "DWord" -val 1
  setKeyValue -path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -key "UserAuthentication" -typ "DWord" -val 1
}

# 26) Deshabilitar Autoplay
function DisableAutoplay {
  Write-Host "Deshabilitando Autoplay..."
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -key "DisableAutoplay" -typ "DWord" -val 1
}

# 27) Deshabilitar Autorun para todos los dispositivos
function DisableAutorun {
  Write-Host "Deshabilitando Autorun para todos los dispositivos..."
  createKey -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -key "NoDriveTypeAutoRun" -typ "DWord" -val 255
}

# 28) Deshabilitar Storage Sense (Listado de imagenes, videos, etc)
function DisableStorageSense {
  Write-Host "Deshabilitando Storage Sense..."
  Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Recurse -ErrorAction SilentlyContinue
}

# 29) Deshabilitar Fast Startup (Produce más problemas que beneficios)
function DisableFastStartup {
  Write-Host "Deshabilitando Fast Startup..."
  setKeyValue -path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -key "HiberbootEnabled" -typ "DWord" -val 0
}

# 30) Deshabilitar LogTrack de eventos del Sistema
function DisableLogger {
  disableService -path "EventLog" -typ "Disabled"
}

# 31) Deshabilitar laslive.dat
function DisableLastlivedat {
  Write-Host "Deshabilitando Fast Startup..."
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability" -key "TimeStampInterval" -typ "DWord" -val 0
}

# 32) Habilitar todas las Opciones de Privacidad de Windows
function EnableAllPrivacy {
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -key "RestrictImplicitInkCollection" -typ "DWord" -val 1
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -key "RestrictImplicitTextCollection" -typ "DWord" -val 1
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -key "HarvestContacts" -typ "DWord" -val 0
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC" -key "PreventHandwritingDataSharing" -typ "DWord" -val 1
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" -key "PreventHandwritingErrorReports" -typ "DWord" -val 1
  setKeyValue -path "HKLM\SOFTWARE\Microsoft\Input\TIPC" -key "Enabled" -typ "Dword" -val 0
  setKeyValue -path "HKCU\SOFTWARE\Microsoft\Input\TIPC" -key "Enabled" -typ "Dword" -val 0
  setKeyValue -path "HKCU\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" -key "NoTileApplicationNotification" -typ "Dword" -val 1
  setKeyValue -path "HKCU\SOFTWARE\Microsoft\MediaPlayer\Preferences" -key "UsageTracking" -typ "Dword" -val 0
}



# ---------------------------------------------- MODIFICACIONES ESTÉTICAS & MENORES SUBMENU 2

# 1) Confirmación al borrar archivo
function EnableFileDeleteConfirm {
  Write-Host "Habilitando ventana de confirmación al borrar archivo..."
  createKey -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
  setKeyValue -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -key "ConfirmFileDelete" -typ "DWord" -val 1
}

# 2) Esconder la barra de busqueda de Cortana
function HideTaskbarSearchBox {
  Write-Host "Ocultando barra de busqueda de Cortana..."
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -key "SearchboxTaskbarMode" -typ "DWord" -val 0
}

# 3) Mostrar extensiones de archivo
function ShowKnownExtensions {
  Write-Host "Mostrando extensiones de archivo..."
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -key "HideFileExt" -typ "DWord" -val 0
}

# 4) Mostrar archivos ocultos
function ShowHiddenFiles {
  Write-Host "Mostrando archivos ocultos..."
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -key "Hidden" -typ "DWord" -val 1
}

# 5) Esconder recientes y frecuentes archivos usados en el explorador
function HideRecentShortcuts {
  Write-Host "Hiding recent shortcuts..."
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -key "ShowRecent" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -key "ShowFrequent" -typ "DWord" -val 0
}

# 6) Cambiar la vista por defecto del explorador a Mi PC
function SetExplorerThisPC {
  Write-Host "Cambiando la vista por defecto del explorador a Mi PC..."
  setKeyValue -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -key "LaunchTo" -typ "DWord" -val 1
}

# 7) Ajustes visuales para el rendimiento
function SetVisualFXPerformance {
  Write-Host "Adjusting visual effects for performance..."
  setKeyValue -path "HKCU:\Control Panel\Desktop" -key "DragFullWindows" -typ "String" -val 0
  setKeyValue -path "HKCU:\Control Panel\Desktop" -key "MenuShowDelay" -typ "String" -val 0
  setKeyValue -path "HKCU:\Control Panel\Desktop\WindowMetrics" -key "MinAnimate" -typ "String" -val 0
  setKeyValue -path "HKCU:\Control Panel\Keyboard" -key "KeyboardDelay" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -key "ListviewAlphaSelect" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -key "ListviewShadow" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -key "TaskbarAnimations" -typ "DWord" -val 0
  setKeyValue -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -key "VisualFXSetting" -typ "DWord" -val 3
  setKeyValue -path "HKCU:\Software\Microsoft\Windows\DWM" -key "EnableAeroPeek" -typ "DWord" -val 0
}

# 8) Establecer el tiempo de inactividad de pantalla
function EnableSleepTimeout {
  Write-Host "Enabling display and sleep mode timeouts..."
  powercfg /X monitor-timeout-ac 60
  powercfg /X monitor-timeout-dc 60
  powercfg /X disk-timeout-ac 0
  powercfg /X disk-timeout-dc 0
  powercfg /X standby-timeout-ac 0
  powercfg /X standby-timeout-dc 0
  powercfg /X hibernate-timeout-ac 0
  powercfg /X hibernate-timeout-dc 0
  powercfg -h off 
}

# 9) Establecer IP y DNS estáticas
function SetIPStatic {
  # Establecer IP y puerta de enlace
  New-NetIPAddress –InterfaceAlias "Ethernet1" –IPv4Address "192.168.0.10" –PrefixLength 24 -DefaultGateway "192.168.0.1"
  # Establecer DNS
  Set-DnsClientServerAddress -InterfaceAlias "Ethernet1" -ServerAddresses "8.8.8.8, 8.8.8.4"
}


# 10) Habilitar la cuenta de administrador y ocultarla
function EnableAdminAndHidde {
  Invoke-Expression -Command "net user administrador active:yes"
  createKey -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts"
  createKey -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"  -key "Administrador" -typ "DWord" -val 0
}

# ---------------------------------------------- DESINSTALACIÓN DE PROGRAMAS SUBMENU 3

# 1) Deshabilitar OneDrive
function DisableOneDrive {
  Write-Host "Deshabilitando OneDrive..."
  createKey -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -key "DisableFileSyncNGSC" -typ "DWord" -val 1
}

# 2) Desinstalar OneDrive 
function UninstallOneDrive {
  Write-Host "Desinstalar OneDrive..."
  Stop-Process -Name OneDrive -ErrorAction SilentlyContinue
  Start-Sleep -s 3
  $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
  if (!(Test-Path $onedrive)) {
    $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
  }
  Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
  Start-Sleep -s 3
  Stop-Process -Name explorer -ErrorAction SilentlyContinue
  Start-Sleep -s 3
  Remove-Item -Path "$env:USERPROFILE\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
  Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
  Remove-Item -Path "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
  Remove-Item -Path "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse -ErrorAction SilentlyContinue
  if (!(Test-Path "HKCR:")) {
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
  }
  Remove-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
  Remove-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
}

# 3) Desinstalar aplicaciones por defecto de Microsoft
function UninstallMsftBloat {
  Write-Host "Desinstalando aplicaciones por defecto de Microsoft..."
  uninstallApp -path "Microsoft.3DBuilder"
  uninstallApp -path "Microsoft.AppConnector"
  uninstallApp -path "Microsoft.BingFinance"
  uninstallApp -path "Microsoft.BingNews"
  uninstallApp -path "Microsoft.BingSports"
  uninstallApp -path "Microsoft.BingWeather"
  uninstallApp -path "Microsoft.CommsPhone"
  uninstallApp -path "Microsoft.ConnectivityStore"
  uninstallApp -path "Microsoft.Getstarted"
  uninstallApp -path "Microsoft.Messaging"
  uninstallApp -path "Microsoft.Microsoft3DViewer"
  uninstallApp -path "Microsoft.MicrosoftOfficeHub"
  uninstallApp -path "Microsoft.MicrosoftPowerBIForWindows"
  uninstallApp -path "Microsoft.MicrosoftSolitaireCollection"
  uninstallApp -path "Microsoft.MicrosoftStickyNotes"
  uninstallApp -path "Microsoft.MinecraftUWP"
  uninstallApp -path "Microsoft.NetworkSpeedTest"
  uninstallApp -path "Microsoft.Office.OneNote"
  uninstallApp -path "Microsoft.Office.Sway"
  uninstallApp -path "Microsoft.OneConnect"
  uninstallApp -path "Microsoft.People"
  uninstallApp -path "Microsoft.Print3D"
  uninstallApp -path "Microsoft.RemoteDesktop"
  uninstallApp -path "Microsoft.SkypeApp"
  uninstallApp -path "Microsoft.WindowsCamera"
  uninstallApp -path "microsoft.windowscommunicationsapps"
  uninstallApp -path "Microsoft.WindowsFeedback"
  uninstallApp -path "Microsoft.WindowsFeedbackHub"
  uninstallApp -path "Microsoft.WindowsMaps"
  uninstallApp -path "Microsoft.WindowsPhone"
  #uninstallApp -path "Microsoft.WindowsSoundRecorder"
  uninstallApp -path "Microsoft.ZuneMusic"
  uninstallApp -path "Microsoft.ZuneVideo"
  uninstallApp -path "Windows.ContactSupport"
  uninstallApp -path "Windows.PurchaseDialog"
  uninstallApp -path "Microsoft.Windows.CloudExperienceHost" # No se puede
  uninstallApp -path "Microsoft.Windows.Cortana" # No se puede
  uninstallApp -path "Microsoft.Windows.HolographicFirstRun" # No se puede
  uninstallApp -path "Windows.MiracastView" # No se puede
}

# 4) Desinstalar aplicaciones de terceras partes por defecto
function UninstallThirdPartyBloat {
  Write-Host "Desinstalar aplicaciones de terceras partes por defecto..."
  uninstallApp -path "9E2F88E3.Twitter"
  uninstallApp -path "king.com.CandyCrushSodaSaga"
  uninstallApp -path "4DF9E0F8.Netflix"
  uninstallApp -path "Drawboard.DrawboardPDF"
  uninstallApp -path "D52A8D61.FarmVille2CountryEscape"
  uninstallApp -path "GAMELOFTSA.Asphalt8Airborne"
  uninstallApp -path "flaregamesGmbH.RoyalRevolt2"
  uninstallApp -path "AdobeSystemsIncorporated.AdobePhotoshopExpress"
  uninstallApp -path "ActiproSoftwareLLC.562882FEEB491"
  uninstallApp -path "D5EA27B7.Duolingo-LearnLanguagesforFree"
  uninstallApp -path "Facebook.Facebook"
  uninstallApp -path "46928bounde.EclipseManager"
  uninstallApp -path "A278AB0D.MarchofEmpires"
  uninstallApp -path "KeeperSecurityInc.Keeper"
  uninstallApp -path "king.com.BubbleWitch3Saga"
  uninstallApp -path "89006A2E.AutodeskSketchBook"
  uninstallApp -path "CAF9E577.Plex"
  uninstallApp -path "A278AB0D.DisneyMagicKingdoms"
  uninstallApp -path "828B5831.HiddenCityMysteryofShadows"
  uninstallApp -path "WinZipComputing.WinZipUniversal"
  uninstallApp -path "SpotifyAB.SpotifyMusic"
  uninstallApp -path "PandoraMediaInc.29680B314EFC2"
  uninstallApp -path "2414FC7A.Viber"
  uninstallApp -path "64885BlueEdge.OneCalendar"
  uninstallApp -path "41038Axilesoft.ACGMediaPlayer"
  uninstallApp -path "Microsoft.XboxApp"
  uninstallApp -path "Microsoft.XboxIdentityProvider"
  uninstallApp -path "Microsoft.XboxSpeechToTextOverlay"
  uninstallApp -path "Microsoft.XboxGameOverlay"
  uninstallApp -path "Microsoft.Xbox.TCUI"
  uninstallApp -path "Microsoft.XboxGameCallableUI" # No se puede
  uninstallApp -path "Microsoft.DesktopAppInstaller"
  uninstallApp -path "Microsoft.WindowsStore"
  uninstallApp -path "Microsoft.Windows.ParentalControls" # No se puede
  uninstallApp -path "Microsoft.Windows.PeopleExperienceHost" # No se puede
  uninstallApp -path "Microsoft.XboxGamingOverlay"
  uninstallApp -path "Windows.CBSPreview" # No se puede
  uninstallApp -path "Microsoft.BioEnrollment" # No se puede
}

# 5) Desinstalar Windows Store
function UninstallWindowsStore {
  Write-Host "Desinstalando Windows Store..."
  uninstallApp -path "Microsoft.DesktopAppInstaller"
  uninstallApp -path "Microsoft.WindowsStore"
}

# 6) Deshabilitar características Xbox
function DisableXboxFeatures {
  Write-Host "Deshabilitando características Xbox ..."
  uninstallApp -path "Microsoft.XboxApp"
  uninstallApp -path "Microsoft.XboxIdentityProvider"
  uninstallApp -path "Microsoft.XboxSpeechToTextOverlay"
  uninstallApp -path "Microsoft.XboxGameOverlay"
  uninstallApp -path "Microsoft.Xbox.TCUI"
  uninstallApp -path "Microsoft.XboxGameCallableUI"
  setKeyValue -path "HKCU:\System\GameConfigStore" -key "GameDVR_Enabled" -typ "DWord" -val 0
  createKey -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
  setKeyValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -key "AllowGameDVR" -typ "DWord" -val 0
}

# 7) Deshabilitar instalación Adobe Flash en IE y Edge
function DisableAdobeFlash {
  Write-Host "Deshabilitando instalación Adobe Flash en IE y Edge..."
  createKey -path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Addons"
  setKeyValue -path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Addons" -key "FlashPlayerEnabled" -typ "DWord" -val 0
  createKey -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\{D27CDB6E-AE6D-11CF-96B8-444553540000}"
  setKeyValue -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\{D27CDB6E-AE6D-11CF-96B8-444553540000}" -key "Flags" -typ "DWord" -val 1
}

# 8) Desinstalar cliente de carpetas de trabajo
function UninstallWorkFolders {
  Write-Host "Desinstalando cliente de carpetas de trabajo..."
  Disable-WindowsOptionalFeature -Online -FeatureName "WorkFolders-Client" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# 9) Desinstalar subsistema linux
function UninstallLinuxSubsystem {
  Write-Host "Desinstalando subsistema linux..."
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -key "AllowDevelopmentWithoutDevLicense" -typ "DWord" -val 0
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -key "AllowAllTrustedApps" -typ "DWord" -val 0
  Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# 10) Desinstalar Hyper-V
function UninstallHyperV {
  Write-Host "Desinstalando Hyper-V..."
  If ((Get-WmiObject -Class "Win32_OperatingSystem").Caption -like "*Server*") {
    Uninstall-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
  } Else {
    Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart -WarningAction SilentlyContinue | Out-Null
  }
}

# 11) Deshabilitar compresión de ficheros en el HDD del S.O. (Desaconsejado)
function DisableCompactOs {
  Write-Host "Deshabilitando compresión de ficheros en HDD OS... (Desaconsejado)"
  compact /CompactOs:query
}

# ---------------------------------------------- OPTIMIZACIÓN SSD SUBMENU 4

# 1) Deshabilitar Hibernación
function DisableHibernation {
  Write-Host "Deshabilitando Hibernación..."
  setKeyValue -path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -key "HibernteEnabled" -typ "Dword" -val 0
  createKey -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings"
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -key "ShowHibernateOption" -typ "Dword" -val 0
  setKeyValue -path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -key "HiberbootEnabled" -typ "DWord" -val 0
}

# 2) Deshabilitar Superfetch
function DisableSuperfetch {
  Write-Host "Deshabilitando Superfetch..."
  disableService -path "SysMain" -typ "Disabled"
  setKeyValue -path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -key "EnablePrefetcher" -typ "DWord" -val 0
  setKeyValue -path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -key "EnableSuperfetch" -typ "DWord" -val 0
}

# 3) Deshabilitar Windows Search indexing
function DisableIndexing {
  Write-Host "Deshabilitando Windows Search indexing..."
  disableService -path "WSearch" -typ "Disabled"
}

# 4) Deshabilitar Windows Backup
function DisableBackup {
  Write-Host "Deshabilitando Windows Search indexing..."
  disableService -path "VSS" -typ "Disabled"
}

# 5) Deshabilitar ClearPageFileAtShutdown y LargeSystemCache OJO PAGEFILE
function DisablePageFileLargeCache {
  Write-Host "Deshabilitando ClearPageFileAtShutdown y LargeSystemCache..."
  setKeyValue -path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -key "ClearPageFileAtShutdown" -typ "DWord" -val 0
  setKeyValue -path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -key "LargeSystemCache" -typ "DWord" -val 0
}

# 6) Deshabilitar tarea programada de desgragmentación
function DisableDefragmentation {
  Write-Host "Deshabilitando desgragmentación programada..."
  disableScheduledTask -path "Microsoft\Windows\Defrag\ScheduledDefrag"
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction" -key "OptimizeComplete" -typ "String" -val "No"
  setKeyValue -path "HKLM:\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction" -key "Enable" -typ "String" -val "N"
}

# 7) Habilitar TRIM para discos SSD
function EnableTRIM {
  Write-Host "Habilitando TRIM para discos SSD..."
  fsutil behavior set disabledeletenotify 0
}

# 8) Deshabilitar el último acceso en archivos
function DisableNTFSLastAccess {
  fsutil behavior set DisableLastAccess 1 | Out-Null
}

# 9) Deshabilitar Swapfile
function DisableSwapFile {
  setKeyValue -path "HKLM:\\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -key "SwapfileControl" -typ "Dword" -val 0  
}


# ---------------------------------------------- DESHABILITAR SERVICIOS SUBMENU 5

# 1) Parar y deshabilitar Diagnostics Tracking Service
function DisableDiagTrack {
  Write-Host "Parando y deshabilitando Diagnostics Tracking Service..."
  disableService -path "DiagTrack" -typ "Disabled"
}

# 2) Parar y deshabilitar WAP Push Service
function DisableWAPPush {
  Write-Host "Parando y deshabilitando WAP Push Service..."
  disableService -path "dmwappushservice" -typ "Disabled"
}

# 3) Parar y deshabilitar Home Groups services
function DisableHomeGroups {
  Write-Host "Parando y deshabilitando Home Groups services..."
  disableService -path "HomeGroupListener" -typ "Disabled"
  disableService -path "HomeGroupProvider" -typ "Disabled"
}

# 4) Parar y deshabilitar Servicios Genericos
function DisableGenericSc {
  Write-Host "Parando y deshabilitando Servicios Genericos..."


  # Parar y poner en modo Manual
  disableService -path "RasMan" -typ "Manual"
  disableService -path "AJRouter" -typ "Manual"
  disableService -path "ALG" -typ "Manual"
  disableService -path "AppIDSvc" -typ "Manual"
  disableService -path "Appinfo" -typ "Manual"
  disableService -path "AppMgmt" -typ "Manual"
  disableService -path "AppReadiness" -typ "Manual"
  disableService -path "AppXSvc" -typ "Manual"
  disableService -path "AxInstSV" -typ "Manual"
  disableService -path "BDESVC" -typ "Manual"
  disableService -path "BthHFSrv" -typ "Manual"
  disableService -path "bthserv" -typ "Manual"
  disableService -path "CertPropSvc" -typ "Manual"
  disableService -path "ClipSVC" -typ "Manual"
  disableService -path "cmdvirth" -typ "Manual"
  disableService -path "COMSysApp" -typ "Manual"
  disableService -path "CscService" -typ "Manual"
  disableService -path "defragsvc" -typ "Manual"
  disableService -path "DeviceAssociationService" -typ "Manual"
  disableService -path "DeviceInstall" -typ "Manual"
  disableService -path "DevQueryBroker" -typ "Manual"
  disableService -path "diagnosticshub.standardcollector.service" -typ "Manual"
  disableService -path "DmEnrollmentSvc" -typ "Manual"
  disableService -path "dot3svc" -typ "Manual"
  disableService -path "DPS" -typ "Manual"
  disableService -path "DsSvc" -typ "Manual"
  disableService -path "EapHost" -typ "Manual"
  disableService -path "EFS" -typ "Manual"
  disableService -path "embeddedmode" -typ "Manual"
  disableService -path "EntAppSvc" -typ "Manual"
  disableService -path "fdPHost" -typ "Manual"
  disableService -path "FDResPub" -typ "Manual"
  disableService -path "fhsvc" -typ "Manual"
  disableService -path "FrameServer" -typ "Manual"
  disableService -path "hidserv" -typ "Manual"
  disableService -path "HomeGroupProvider" -typ "Manual"
  disableService -path "HvHost" -typ "Manual"
  disableService -path "icssvc" -typ "Manual"
  disableService -path "irmon" -typ "Manual"
  disableService -path "KeyIso" -typ "Manual"
  disableService -path "KtmRm" -typ "Manual"
  disableService -path "lltdsvc" -typ "Manual"
  disableService -path "MessagingService_ab32f" -typ "Manual"
  disableService -path "MSDTC" -typ "Manual"
  disableService -path "MSiSCSI" -typ "Manual"
  disableService -path "msiserver" -typ "Manual"
  disableService -path "NcaSvc" -typ "Manual"
  disableService -path "NcbService" -typ "Manual"
  disableService -path "NcdAutoSetup" -typ "Manual"
  disableService -path "Netlogon" -typ "Manual"
  disableService -path "Netman" -typ "Manual"
  disableService -path "netprofm" -typ "Manual"
  disableService -path "NetSetupSvc" -typ "Manual"
  disableService -path "NgcCtnrSvc" -typ "Manual"
  disableService -path "NgcSvc" -typ "Manual"
  disableService -path "p2pimsvc" -typ "Manual"
  disableService -path "p2psvc" -typ "Manual"
  disableService -path "PeerDistSvc" -typ "Manual"
  disableService -path "PerfHost" -typ "Manual"
  disableService -path "PhoneSvc" -typ "Manual"
  disableService -path "pla" -typ "Manual"
  disableService -path "PNRPAutoReg" -typ "Manual"
  disableService -path "PNRPsvc" -typ "Manual"
  disableService -path "PrintNotify" -typ "Manual"
  disableService -path "QWAVE" -typ "Manual"
  disableService -path "RasAuto" -typ "Manual"
  disableService -path "RasMan" -typ "Manual"
  disableService -path "RetailDemo" -typ "Manual"
  disableService -path "RmSvc" -typ "Manual"
  disableService -path "RpcLocator" -typ "Manual"
  disableService -path "ScDeviceEnum" -typ "Manual"
  disableService -path "SCPolicySvc" -typ "Manual"
  disableService -path "SDRSVC" -typ "Manual"
  disableService -path "seclogon" -typ "Manual"
  disableService -path "Sense" -typ "Manual" #No se puede 
  disableService -path "SensorDataService" -typ "Manual"
  disableService -path "SessionEnv" -typ "Manual"
  disableService -path "SharedAccess" -typ "Manual"
  disableService -path "smphost" -typ "Manual"
  disableService -path "SmsRouter" -typ "Manual"
  disableService -path "SNMPTRAP" -typ "Manual"
  disableService -path "sppsvc" -typ "Manual" #No se puede 
  disableService -path "SSDPSRV" -typ "Manual"
  disableService -path "SstpSvc" -typ "Manual" #No se puede 
  disableService -path "StorSvc" -typ "Manual"
  disableService -path "swprv" -typ "Manual"
  disableService -path "TapiSrv" -typ "Manual"
  disableService -path "TermService" -typ "Manual"
  disableService -path "TieringEngineService" -typ "Manual"
  disableService -path "TrustedInstaller" -typ "Manual"
  disableService -path "UI0Detect" -typ "Manual"
  disableService -path "UmRdpService" -typ "Manual"
  disableService -path "UnistoreSvc_ab32f" -typ "Manual"
  disableService -path "upnphost" -typ "Manual"
  disableService -path "UserDataSvc_ab32f" -typ "Manual"
  disableService -path "UsoSvc" -typ "Manual" #No se puede 
  disableService -path "vds" -typ "Manual"
  disableService -path "vmicguestinterface" -typ "Manual"
  disableService -path "vmicheartbeat" -typ "Manual"
  disableService -path "vmickvpexchange" -typ "Manual"
  disableService -path "vmicrdv" -typ "Manual"
  disableService -path "vmicshutdown" -typ "Manual"
  disableService -path "vmictimesync" -typ "Manual"
  disableService -path "vmicvmsession" -typ "Manual"
  disableService -path "vmicvss" -typ "Manual"
  disableService -path "VSS" -typ "Manual"
  disableService -path "WalletService" -typ "Manual"
  disableService -path "wbengine" -typ "Manual"
  disableService -path "wcncsvc" -typ "Manual"
  disableService -path "WdiServiceHost" -typ "Manual"
  disableService -path "WdiSystemHost" -typ "Manual"
  disableService -path "WebClient" -typ "Manual"
  disableService -path "Wecsvc" -typ "Manual"
  disableService -path "WEPHOSTSVC" -typ "Manual"
  disableService -path "wercplsupport" -typ "Manual"
  disableService -path "WerSvc" -typ "Manual"
  disableService -path "WiaRpc" -typ "Manual"
  disableService -path "WinHttpAutoProxySvc" -typ "Manual" #No se puede 
  disableService -path "WinRM" -typ "Manual"
  disableService -path "wlidsvc" -typ "Manual"
  disableService -path "wmiApSrv" -typ "Manual"
  disableService -path "workfolderssvc" -typ "Manual"
  disableService -path "WPDBusEnum" -typ "Manual"
  disableService -path "WpnUserService_ab32f" -typ "Manual"
  disableService -path "WwanSvc" -typ "Manual"
  disableService -path "DusmSvc" -typ "Manual"



  # Parar y poner en modo Deshabilitado
  disableService -path "AODService" -typ "Disabled" #No existe
  disableService -path "AppVClient" -typ "Disabled"
  disableService -path "ASGT" -typ "Disabled" #No existe
  disableService -path "BrokerInfrastructure" -typ "Disabled" #No se deshabilitar
  disableService -path "CDPUserSvc_ab32f" -typ "Disabled" #No existe
  disableService -path "DcpSvc" -typ "Disabled" #No existe
  disableService -path "Dhcp" -typ "Disabled" #No se puede detener
  disableService -path "diagnosticshub.standardcollector.service"  -typ "Disabled"
  disableService -path "DiagTrack" -typ "Disabled"
  disableService -path "dmwappushservice" -typ "Disabled"
  disableService -path "EventLog" -typ "Disabled"
  disableService -path "FoxitReaderService" -typ "Disabled" #No existe
  disableService -path "HomeGroupListener" -typ "Disabled"  #No existe
  disableService -path "HomeGroupProvider" -typ "Disabled"  #No existe
  disableService -path "IKEEXT" -typ "Disabled"
  disableService -path "LanmanServer" -typ "Disabled"
  disableService -path "LanmanWorkstation" -typ "Disabled"
  disableService -path "lfsvc" -typ "Disabled"
  disableService -path "LicenseManager" -typ "Disabled"
  disableService -path "lmhosts" -typ "Disabled"
  disableService -path "MapsBroker" -typ "Disabled"
  disableService -path "MpsSvc" -typ "Disabled" #No se puede detener
  disableService -path "NetTcpPortSharing" -typ "Disabled"
  disableService -path "PcaSvc" -typ "Disabled"
  disableService -path "PimIndexMaintenanceSvc_ab32f" -typ "Disabled" #No existe
  disableService -path "RemoteAccess" -typ "Disabled"
  disableService -path "RemoteRegistry" -typ "Disabled"
  disableService -path "RetailDemo" -typ "Disabled"
  disableService -path "SCardSvr" -typ "Disabled"
  disableService -path "SEMgrSvc" -typ "Disabled"
  disableService -path "SensorService" -typ "Disabled"
  disableService -path "SensrSvc" -typ "Disabled"
  disableService -path "shpamsvc" -typ "Disabled"
  disableService -path "Spooler" -typ "Disabled"
  disableService -path "svsvc" -typ "Disabled"
  disableService -path "SysMain" -typ "Disabled"
  disableService -path "TabletInputService" -typ "Disabled"
  disableService -path "TimeBrokerSvc" -typ "Disabled" #No se puede deshabilitar
  disableService -path "TokenBroker" -typ "Disabled"
  disableService -path "TrkWks" -typ "Disabled"
  disableService -path "tzautoupdate" -typ "Disabled"
  disableService -path "UevAgentService" -typ "Disabled"
  disableService -path "UsoSvc" -typ "Disabled"
  disableService -path "VSS" -typ "Disabled"
  disableService -path "W32Time" -typ "Disabled"
  disableService -path "WbioSrvc" -typ "Disabled"
  disableService -path "WdNisSvc" -typ "Disabled" #No se puede
  disableService -path "wisvc" -typ "Disabled"
  disableService -path "WlanSvc" -typ "Disabled"
  disableService -path "WMPNetworkSvc" -typ "Disabled"
  disableService -path "WSearch" -typ "Disabled"
  disableService -path "wuauserv" -typ "Disabled"
  disableService -path "XboxNetApiSvc" -typ "Disabled"
  disableService -path "CDPUserSvc" -typ "Disabled"



}

# ---------------------------------------------- DESHABILITAR TAREAS PROGRAMADAS SUBMENU 6

#1) Deshabilitar 
function DisableGenericScheduledTash {
  disableScheduledTask -path "\" -name "CCleanerSkipUAC"
  disableScheduledTask -path "\" -name "OneDrive Standalone Update Task v2"
  disableScheduledTask -path "\Microsoft\Windows\AppID\" -name "SmartScreenSpecific"
  disableScheduledTask -path "\Microsoft\Windows\Application Experience\" -name "Microsoft Compatibility Appraiser"
  disableScheduledTask -path "\Microsoft\Windows\Application Experience\" -name "ProgramDataUpdater"
  disableScheduledTask -path "\Microsoft\Windows\Application Experience\" -name "StartupAppTask"
  disableScheduledTask -path "\Microsoft\Windows\Autochk\" -name "Proxy"
  disableScheduledTask -path "\Microsoft\Windows\Bluetooth\" -name "UninstallDeviceTask"
  disableScheduledTask -path "\Microsoft\Windows\Chkdsk\" -name "ProactiveScan"
  disableScheduledTask -path "\Microsoft\Windows\CloudExperienceHost\" -name "CreateObjectTask"
  disableScheduledTask -path "\Microsoft\Windows\Customer Experience Improvement Program\" -name "Consolidator"
  disableScheduledTask -path "\Microsoft\Windows\Customer Experience Improvement Program\" -name "KernelCeipTask"
  disableScheduledTask -path "\Microsoft\Windows\Customer Experience Improvement Program\" -name "Uploader"
  disableScheduledTask -path "\Microsoft\Windows\Customer Experience Improvement Program\" -name "UsbCeip"
  disableScheduledTask -path "\Microsoft\Windows\Defrag\" -name "ScheduledDefrag"
  disableScheduledTask -path "\Microsoft\Windows\DiskDiagnostic\" -name "Microsoft-Windows-DiskDiagnosticDataCollector"
  disableScheduledTask -path "\Microsoft\Windows\Feedback\Siuf\" -name "DmClient"
  disableScheduledTask -path "\Microsoft\Windows\Feedback\Siuf\" -name "DmClientOnScenarioDownload"
  disableScheduledTask -path "\Microsoft\Windows\Maps\" -name "MapsToastTask"
  disableScheduledTask -path "\Microsoft\Windows\Maps\" -name "MapsUpdateTask"
  disableScheduledTask -path "\Microsoft\Windows\Mobile Broadband Accounts\" -name "MNO Metadata Parser"
  disableScheduledTask -path "\Microsoft\Windows\NetTrace\" -name "GatherNetworkInfo"
  disableScheduledTask -path "\Microsoft\Windows\NlaSvc\" -name "WiFiTask"
  disableScheduledTask -path "\Microsoft\Windows\RemoteAssistance\" -name "RemoteAssistanceTask"
  disableScheduledTask -path "\Microsoft\Windows\Speech\" -name "SpeechModelDownloadTask"
  disableScheduledTask -path "\Microsoft\Windows\TextServicesFramework\" -name "MsCtfMonitor"
  disableScheduledTask -path "\Microsoft\Windows\Time Synchronization\" -name "ForceSynchronizeTime"
  disableScheduledTask -path "\Microsoft\Windows\Time Synchronization\" -name "SynchronizeTime"
  disableScheduledTask -path "\Microsoft\Windows\Time Zone\" -name "SynchronizeTimeZone"
  disableScheduledTask -path "\Microsoft\Windows\Windows Defender\" -name "Windows Defender Scheduled Scan"
  disableScheduledTask -path "\Microsoft\Windows\Windows Error Reporting\" -name "QueueReporting"
  disableScheduledTask -path "\Microsoft\Windows\Windows Media Sharing\" -name "UpdateLibrary"
  disableScheduledTask -path "\Microsoft\Windows\WindowsUpdate\" -name "Automatic App Update"
  disableScheduledTask -path "\Microsoft\Windows\WindowsUpdate\" -name "Scheduled Start"
  disableScheduledTask -path "\Microsoft\Windows\WindowsUpdate\" -name "sih"
  disableScheduledTask -path "\Microsoft\Windows\WindowsUpdate\" -name "sihboot"
  disableScheduledTask -path "\Microsoft\XblGameSave\" -name "XblGameSaveTask"
  disableScheduledTask -path "\Microsoft\XblGameSave\" -name "XblGameSaveTaskLogon"


}

# ---------------------------------------------- ESTABLECER CLAVES DEL REGISTTTRO DE WINDOWS SUBMENU 7

# DisableActivityHistory  
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0
Stop-Service "CDPUserSvc" -WarningAction SilentlyContinue


# DisableTailoredExperiences
If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
    New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1
}

# DisableWebLangList 

  Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1


# HideRecentJumplists 
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Type DWord -Value 0

# DisableNCSIProbe {
  Write-Output "Disabling NCSI active test..."
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator" -Name "NoActiveProbe" -Type DWord -Value 1
}



# EnableCIMemoryIntegrity 
  Write-Output "Enabling Core Isolation Memory Integrity..."
  If (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity")) {
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Type DWord -Value 1


# DisableScriptHost {
  Write-Output "Disabling Windows Script Host..."
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -Type DWord -Value 0
}


Function DisableSharedExperiences {
  Write-Output "Disabling Shared Experiences..."
  If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP")) {
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP" | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP" -Name "RomeSdkChannelUserAuthzPolicy" -Type DWord -Value 0
}


# Function HideNetworkFromLockScreen {
  Write-Output "Hiding network options from Lock Screen..."
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DontDisplayNetworkSelectionUI" -Type DWord -Value 1
}

Function DisableSharingWizard {
  Write-Output "Disabling Sharing Wizard..."
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SharingWizardOn" -Type DWord -Value 0
}


Function Hide3DObjectsFromThisPC {
  Write-Output "Hiding 3D Objects icon from This PC..."
  Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue
}



Function Hide3DObjectsFromExplorer {
  Write-Output "Hiding 3D Objects icon from Explorer namespace..."
  If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
  If (!(Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
    New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
}




# ---------------------------------------------- OBTENER INFORMACIÓN DE MANTENIMIENTO SUBMENU 7

# 1) Obtener servicios
function getServices {
  Get-WmiObject win32_service | Select Name, State, StartMode, DisplayName | Sort State, StartMode, Name | Format-Table -AutoSize
}

# 2) Obtener Tareas Programadas
function getTaskSched {
  Get-ScheduledTask | sort State, taskpath | Format-Table -AutoSize
  schtasks
} 

# 3) Obtener aplicaciones por defecto
function getAppDefault {
  get-appxpackage | Select Name, InstallLocation | Sort Name | Format-Table -AutoSize
}

# 4) Obtener conexiones y puertos en escucha
function getConect {
  netstat -ano
}

# 5) Obtener aplicaciones Startup
function getAppAutoRun {
  Get-CimInstance Win32_StartupCommand | Select-Object Name, command, Location, User | Format-List  
}

# 6) Obtener información de red
function getNetInfo {
  Invoke-Expression "Ipconfig /all"
}

# 7) Obtener recursos compartidos
function getSharedRes {
  Get-SmbShare
}


# ---------------------------------------------- INICIAR BACKUP SUBMENU 8

# 1) Crear la carpeta de backups y devolver la ruta
function backupCheckFolder {
  $dat = Get-Date -UFormat "[%Y-%m-%d]"
  $strPath = $env:USERPROFILE + '\Desktop\' + $dat + '_Backup'
  if ( (Test-Path -Path $strPath) -eq 0 ) { new-item -Path $strPath -ItemType directory -ErrorAction Ignore | Out-Null }
  return $strPath
}

# 2) Crear copia del archivos host
function backupFileHost {
  $basePath = backupCheckFolder
  $basePath += '\FileHost'
  new-item -Path $basePath -ItemType directory -ErrorAction Ignore | Out-Null
  $basePath += '\host'
  Copy-Item "C:\Windows\System32\drivers\etc\hosts" -Destination $basePath
}

# 3) Backup del Boot Configuration Data (BCD)
function backupBCD {
  $basePath = backupCheckFolder
  $basePath += "\BCD"
  new-item -Path $basePath -ItemType directory -ErrorAction Ignore | Out-Null
  $basePath = "bcdedit /export " + $basePath + "\backup.bcd"
  Invoke-Expression $basePath
}

# 4) Backup de Drives
function backupDrivers {
  $basePath = backupCheckFolder
  $basePath += "\Drivers"
  new-item -Path $basePath -ItemType directory -ErrorAction Ignore | Out-Null
  $basePath = 'dism /online /export-driver /destination:' + $basePath
  Invoke-Expression $basePath
}

# 5) Backup de perfiles de Firefox
function backupFirefox {
  $basePath = backupCheckFolder
  $basePath += "\Firefox"
  new-item -Path $basePath -ItemType directory -ErrorAction Ignore | Out-Null
  Copy-Item "$env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\profiles.ini" -Destination $basePath
  $basePath += "\Profiles"
  Copy-Item "$env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles" -Destination $basePath -Recurse
}


# ---------------------------------------------- OTROS SUBMENU 9


# 1) Desinstalar características de Windows
function tool1 {
  optionalfeatures.exe
}
# 2) características avanzadas de Windows
function tool2 {
  SystemPropertiesAdvanced.exe
}
# 3) Liberador de espacio en disco
function tool3 {
  cleanmgr.exe
}
# 4) Comprobar si Windows está activado
function tool4 {
  slmgr.vbs /xpr
}

# 5) Abrir archivo host
function tool5 {
  Start-Process -Verb "runas" notepad.exe "C:\Windows\System32\drivers\etc\hosts"
}

# 6) Configuración de Windows
function tool6 {
  msconfig.exe
}

# 7) Diagnostico DirecX
function tool7 {
  dxdiag 
}

# 8) Editor de directivas de grupo local
function tool8 {
  gpedit.msc
}

# 9) Monitor de rendimiento y recursos
function tool9 {
  perfmon.exe
}

##################################################################################################################
# ------------------------------------------------- MENUS --------------------------------------------------------

$aMenu0 = @(
  "1) Privacidad y Configuración", 
  "2) Modificaciones Estéticas y Menores", 
  "3) Desinstalar Programas",
  "4) Optimización SSD",
  "5) Deshabiliar Servicios",
  "6) Deshabiliar Tareas Programadas",
  "7) Obtener información de mantenimiento",
  "8) Iniciar Backup",
  "9) Herramientas de Windows"
  )

$aMenu1 = @( 
  " 1) Deshabilitar telemetría", 
  " 2) Deshabilitar Wi-Fi Sense (Compartir Wifi desde Windows)", 
  " 3) Deshabilitar SmartScreen Filter (Programas de la lista blanca de Microsoft)", 
  " 4) Deshabilitar Web Search in Start Menu (Buscador en Bing desde Windows)", 
  " 5) Deshabilitar Application suggestions and automatic installation (Sugerencias de aplicaciones)", 
  " 6) Deshabilitar Background application access (Descargas y actualizaciones en segundo plano)", 
  " 7) Deshabilitar Lock screen Spotlight (Quitar anuncios en la ventana de bloqueo)", 
  " 8) Deshabilitar Location Tracking (Seguimiento de la localización)", 
  " 9) Deshabilitar automatic Maps updates (Descarga de mapas)", 
  "10) Deshabilitar Feedback", 
  "11) Deshabilitar Advertising ID (ID unico para publicidad a medida)", 
  "12) Deshabilitar Cortana", 
  "13) Deshabilitar Error reporting (Mandar errores a Microsoft)", 
  "14) Restringir Windows Update P2P solo a la red local", 
  "15) Eliminar archivo AutoLogger y restringir directorio", 
  "16) Elevar nivel UAC", 
  "17) Deshabilitar mapeo de dispositivos compartidos entre usuarios", 
  "18) Deshabilitar recursos compartidos implicitos administrativos ", 
  "19) Deshabilitar SMB protocolo 1.0", 
  "20) Habilitar acceso controlado a carpetas (Defender Exploit Guard feature)", 
  "21) Deshabilitando Firewall", 
  "22) Deshabilitar Windows Defender Cloud", 
  "23) Deshabilitar experiencias compartidas", 
  "24) Deshabilitar Asistencia Remota", 
  "25) Deshabilitar Escritorio Remoto", 
  "26) Deshabilitar Autoplay", 
  "27) Deshabilitar Autorun para todos los dispositivos", 
  "28) Deshabilitar Storage Sense (Listado de imagenes, videos, etc)", 
  "29) Deshabilitar Fast Startup (Produce más problemas que beneficios)",
  "30) Deshabilitar LogTrack de eventos del Sistema",
  "31) Deshabilitar laslive.dat",
  "32) Habilitar todas las Opciones de Privacidad de Windows"
  )


$funcSubMenu1 = @(
  (gi function:DisableTelemetry),
  (gi function:DisableWiFiSense),
  (gi function:DisableSmartScreen ),
  (gi function:DisableWebSearch),
  (gi function:DisableAppSuggestions),
  (gi function:DisableBackgroundApps),
  (gi function:DisableLockScreenSpotlight),
  (gi function:DisableLocationTracking),
  (gi function:DisableMapUpdates ),
  (gi function:DisableFeedback),
  (gi function:DisableAdvertisingID),
  (gi function:DisableCortana),
  (gi function:DisableErrorReporting),
  (gi function:SetP2PUpdateLocal),
  (gi function:DisableAutoLogger),
  (gi function:SetUACHigh),
  (gi function:DisableSharingMappedDrives),
  (gi function:DisableAdminShares),
  (gi function:DisableSMB1),
  (gi function:EnableCtrldFolderAccess),
  (gi function:DisableFirewall),
  (gi function:DisableDefenderCloud),
  (gi function:DisableSharedExperiences),
  (gi function:DisableRemoteAssistance),
  (gi function:DisableRemoteDesktop),
  (gi function:DisableAutoplay),
  (gi function:DisableAutorun),
  (gi function:DisableStorageSense),
  (gi function:DisableFastStartup),
  (gi function:DisableLogger),
  (gi function:DisableLastlivedat),
  (gi function:EnableAllPrivacy)
)

$aMenu2 = @( 
  " 1) Confirmación al borrar archivo",
  " 2) Esconder la barra de busqueda de Cortana",
  " 3) Mostrar extensiones de archivo",
  " 4) Mostrar archivos ocultos",
  " 5) Esconder archivos usados frecuentemente en el explorador",
  " 6) Cambiar la vista por defecto del explorador a Mi PC",
  " 7) Ajustes visuales para el rendimiento",
  " 8) Establecer el tiempo de inactividad de pantalla",
  " 9) Establecer IP y DNS estáticas",
  "10) Habilitar la cuenta de administrador y ocultarla"
  )

$funcSubMenu2 = @(
  (gi function:EnableFileDeleteConfirm),
  (gi function:HideTaskbarSearchBox),
  (gi function:ShowKnownExtensions),
  (gi function:ShowHiddenFiles),
  (gi function:HideRecentShortcuts),
  (gi function:SetExplorerThisPC),
  (gi function:SetVisualFXPerformance),
  (gi function:EnableSleepTimeout),
  (gi function:SetIPStatic),
  (gi function:EnableAdminAndHidde)
)


$aMenu3 = @( 
  " 1) Deshabilitar OneDrive",
  " 2) Desinstalar OneDrive",
  " 3) Desinstalar aplicaciones por defecto de Microsoft",
  " 4) Desinstalar aplicaciones de terceras partes por defecto",
  " 5) Desinstalar Windows Store",
  " 6) Deshabilitar características Xbox",
  " 7) Deshabilitar instalación Adobe Flash en IE y Edge",
  " 8) Desinstalar cliente de carpetas de trabajo",
  " 9) Desinstalar subsistema linux",
  "10) Desinstalar Hyper-V",
  "11) Deshabilitar compresión de ficheros en el HDD del S.O."
  )

$funcSubMenu3 = @(
  (gi function:DisableOneDrive),
  (gi function:UninstallOneDrive),
  (gi function:UninstallMsftBloat),
  (gi function:UninstallThirdPartyBloat),
  (gi function:UninstallWindowsStore),
  (gi function:DisableXboxFeatures),
  (gi function:DisableAdobeFlash),
  (gi function:UninstallWorkFolders),
  (gi function:UninstallLinuxSubsystem),
  (gi function:UninstallHyperV),
  (gi function:DisableCompactOs)
)


$aMenu4 = @( 
  "1) Deshabilitar Hibernación",
  "2) Deshabilitar Superfetch",
  "3) Deshabilitar Windows Search indexing",
  "4) Deshabilitar Windows Backup",
  "5) Deshabilitar ClearPageFileAtShutdown y LargeSystemCache",
  "6) Deshabilitar tarea programada de desgragmentación",
  "7) Habilitar TRIM para discos SSD",
  "8) Deshabilitar el último acceso en archivos",
  "9) Deshabilitar Swapfile"
  )


$funcSubMenu4 = @(
  (gi function:DisableHibernation),
  (gi function:DisableSuperfetch),
  (gi function:DisableIndexing),
  (gi function:DisableBackup),
  (gi function:DisablePageFileLargeCache),
  (gi function:DisableDefragmentation),
  (gi function:EnableTRIM),
  (gi function:DisableLastAccess),
  (gi function:DisableSwapFile)
)

$aMenu5 = @( 
  "1) Parar y deshabilitar Diagnostics Tracking Service",
  "2) Parar y deshabilitar WAP Push Service",
  "3) Parar y deshabilitar Home Groups services",
  "4) Parar y deshabilitar Servicios Genericos innecesarios"
  )

$funcSubMenu5 = @(
  (gi function:DisableDiagTrack),
  (gi function:DisableWAPPush),
  (gi function:DisableHomeGroups),
  (gi function:DisableGenericSc)
)


$aMenu6 = @(
  "1) Deshabilitar Tareas Programadas innecesarias"
  )

$funcSubMenu6 = @(
  (gi function:DisableGenericScheduledTash)
)


$aMenu7 = @( 
  "1) Servicios",
  "2) Tareas Programadas",
  "3) Aplicaciones por defecto",
  "4) Conexiones y puertos en escucha",
  "5) Aplicaciones Startup",
  "6) Información de red",
  "7) Obtener recuersos compartidos"
  )

$funcSubMenu7 = @(
  (gi function:getServices),
  (gi function:getTaskSched),
  (gi function:getAppDefault),
  (gi function:getConect),
  (gi function:getAppAutoRun),
  (gi function:getNetInfo),
  (gi function:getSharedRes)
)


$aMenu8 = @( 
  "1) Crear la carpeta de backups y devolver la ruta",
  "2) Crear copia del archivos host",
  "3) Backup del Boot Configuration Data (BCD)",
  "4) Backup de Drives",
  "5) Backup de perfiles de Firefox"
  )

$funcSubMenu8 = @(
  (gi function:backupCheckFolder),
  (gi function:backupFileHost),
  (gi function:backupBCD),
  (gi function:backupDrivers),
  (gi function:backupFirefox)
)


$aMenu9 = @( 
  "1) Desinstalar características de Windows",
  "2) características avanzadas de Windows",
  "3) Liberador de espacio en disco",
  "4) Comprobar si Windows está activado",
  "5) Abrir archivo host",
  "6) Configuración de Windows",
  "7) Diagnostico DirecX",
  "8) Editor de directivas de grupo local",
  "9) Monitor de rendimiento y recursos"
  )

$funcSubMenu9 = @(
  (gi function:tool1),
  (gi function:tool2),
  (gi function:tool3),
  (gi function:tool4),
  (gi function:tool5),
  (gi function:tool6),
  (gi function:tool7),
  (gi function:tool8),
  (gi function:tool9)
)

$aSubMenus =  @(
  $aMenu0,
  $aMenu1,
  $aMenu2,
  $aMenu3,
  $aMenu4,
  $aMenu5,
  $aMenu6,
  $aMenu7,
  $aMenu8,
  $aMenu9
)


# ----------------------------------------------------- MENÚS

function showMenu { 
  Param ( [int] $id, [string] $ti )
  cls 
  Write-Host "`t`n||=================" -NoNewLine -F White -B White
  Write-Host " $ti " -NoNewLine -F Black -B White
  Write-Host "================" -F White -B White
  Write-Host "||`t`n||" -NoNewLine -B White
  foreach ($elem in $aSubMenus[$id]) {  
    Write-Host  "  $elem"
    Write-Host "||" -NoNewLine -B White 
  }
  Write-Host "  S) Presiona 'S' para salir" -F Red
  Write-Host "||`t`n||====================================================" -F White -B White
}

function goToMenu {
  $i1 = 0
  $i2 = 0
  showMenu -id 0 -ti "Opciones del Menú"
  $i1 = getKeyPress

  do { 
    if ($i1 -ne -2 -and $i1 -ge 1 -and $i1 -le $aMenu0.length) { 
      showMenu -id $i1 -ti $aMenu0[$i1-1]
      $i2 = getKeyPress
      # SUBMENUS
      if ($i2 -ne -2 -and $i2 -ge 1 -and $i2 -le $aSubMenus[$i1].length) { 
        do {
          cls
          Write-Host $aSubMenus[$i1][$i2-1] 
          switch ( $i1 ) {
            '1' { & $funcSubMenu1[$i2-1] }
            '2' { & $funcSubMenu2[$i2-1] }
            '3' { & $funcSubMenu3[$i2-1] }
            '4' { & $funcSubMenu4[$i2-1] }
            '5' { & $funcSubMenu5[$i2-1] }
            '6' { & $funcSubMenu6[$i2-1] }
            '7' { & $funcSubMenu7[$i2-1] }
            '8' { & $funcSubMenu8[$i2-1] }
            '9' { & $funcSubMenu9[$i2-1] }
            default { Write-Host "La opción $i2 no está disponible." }
          } # End Switch
          WaitForKey
          showMenu -id $i1 -ti $aMenu0[$i1-1]
          $i2 = getKeyPress
        } until ($i2 -eq -2)
      } # End IF
    } # End IF

    showMenu -id 0 -ti "Opciones del Menú"
    $i1 = getKeyPress
  } until ($i1 -eq -2)
  cls
  Write-Host "`n`tEl Script terminó. Hasta la próxima ;)`n`t"
  return 
} # End gotoMenu

if (isadmin) { goToMenu } else { 
  Write-Host "No tienes permiso de administrador para ejecutar este script." 
  Get-ExecutionPolicy
  Exit
}

# Get-ExecutionPolicy
# Set-ExecutionPolicy Unrestricted
# Set-ExecutionPolicy Restricted

