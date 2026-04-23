# Deshabilitar Cortana y eliminar componentes relacionados

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

# Detener el proceso Cortana
$processesCortana = @("SearchUI", "Cortana", "SearchHost")
foreach ($process in $processesCortana) {
    Stop-ProcessByName -processName $process
}

# Deshabilitar Cortana en el registro
$registryPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
)

# Deshabilitar Cortana en el registro de Windows
Write-Host "Desactivando Cortana en el registro..."
foreach ($path in $registryPaths) {
    # Buscar la clave en el registro y eliminarla si existe
    if (Test-Path $path) {
        if (Test-Path "$path\AllowCortana") {
            Set-ItemProperty -Path $path -Name "AllowCortana" -Value 0
        }
        if (Test-Path "$path\SearchboxTaskbarMode") {
            Set-ItemProperty -Path $path -Name "SearchboxTaskbarMode" -Value 0
        }
        if (Test-Path "$path\SearchEnabled") {
            Set-ItemProperty -Path $path -Name "SearchEnabled" -Value 0
        }
    }
}

# Desactivar los servicios de Cortana relacionados
Write-Host "Deteniendo y deshabilitando los servicios de Cortana..."

# Desactivar servicio de "Windows Search"
$serviceName = "WSearch"
$searchService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
if ($searchService.Status -eq 'Running') {
    Stop-Service -Name $serviceName -Force
    Set-Service -Name $serviceName -StartupType Disabled
    Write-Host "Servicio de búsqueda detenido y deshabilitado."
} else {
    Write-Host "El servicio de búsqueda ya está detenido."
}

# Desactivar tareas programadas de Cortana
Write-Host "Desactivando tareas programadas de Cortana..."

# Deshabilitar las tareas relacionadas con Cortana en el Programador de tareas
$tasks = @(
    "\Microsoft\Windows\Windows Search\WSearch"
)

foreach ($task in $tasks) {
    try {
        Disable-ScheduledTask -TaskName $task
        Write-Host "Tarea programada deshabilitada: $task"
    } catch {
        Write-Host "No se pudo deshabilitar la tarea: $task"
    }
}

# Eliminar Cortana de los componentes de Windows (solo Windows 10 Pro o Enterprise)
Write-Host "Eliminando Cortana de los componentes de Windows..."

$apps = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*Cortana*" }

foreach ($app in $apps) {
    Write-Host "Desinstalando la aplicación Cortana: $($app.Name)"
    Remove-AppxPackage -Package $app.PackageFullName
}

# Deshabilitar tareas de IA relacionadas con Cortana (también se desactiva Cortana en Windows 11)
Write-Host "Desactivando inteligencia artificial de Cortana..."

# Desactivar inteligencia artificial de Windows
$aiRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell"
if (Test-Path "$aiRegistryPath") {
    Set-ItemProperty -Path "$aiRegistryPath" -Name "UseCortana" -Value 0
    Write-Host "Desactivando IA en el registro."
}

# Deshabilitar entrada de la Cortana que podría seguir en el inicio
$startupPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$startupPrograms = @("Cortana", "SearchUI", "CortanaUI")
foreach ($program in $startupPrograms) {
    if (Test-Path "$startupPath\$program") {
        Remove-ItemProperty -Path $startupPath -Name $program
        Write-Host "Eliminado programa de inicio relacionado con Cortana: $program"
    }
}

# Finalizar cualquier proceso adicional relacionado con IA
Write-Host "Desactivando IA en segundo plano..."
$aiProcesses = @("Cortana", "SearchUI", "SearchHost", "MicrosoftEdge")
foreach ($aiProcess in $aiProcesses) {
    Stop-ProcessByName -processName $aiProcess
}

Write-Host "Proceso de desactivación completado."

# Reiniciar el sistema (opcional)
# Write-Host "Reiniciando el sistema..."
# Restart-Computer -Force

# Detener el servicio WpnUserService_52713 si está en ejecución
$serviceName = "WpnUserService_52713"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service -and $service.Status -eq 'Running') {
    Stop-Service -Name $serviceName -Force
    Set-Service -Name $serviceName -StartupType Disabled
    Write-Host "Servicio $serviceName detenido y deshabilitado."
} else {
    Write-Host "El servicio $serviceName ya está detenido o no existe."
}

# Deshabilitar Cortana en el registro
$registryPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
)

Write-Host "Desactivando Cortana en el registro..."
foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        if (Test-Path "$path\AllowCortana") {
            Set-ItemProperty -Path $path -Name "AllowCortana" -Value 0
        }
        if (Test-Path "$path\SearchboxTaskbarMode") {
            Set-ItemProperty -Path $path -Name "SearchboxTaskbarMode" -Value 0
        }
        if (Test-Path "$path\SearchEnabled") {
            Set-ItemProperty -Path $path -Name "SearchEnabled" -Value 0
        }
    }
}

# Eliminar clave de Cortana para "UseCortana" (IA)
$aiRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell"
if (Test-Path "$aiRegistryPath") {
    Set-ItemProperty -Path "$aiRegistryPath" -Name "UseCortana" -Value 0
    Write-Host "Desactivando IA de Cortana en el registro."
}

# Eliminar registros asociados a la búsqueda en el sistema
$searchRegPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\SearchHandlers",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchScopes"
)

foreach ($path in $searchRegPaths) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
        Write-Host "Eliminando clave de registro: $path"
    }
}

# Eliminar Cortana del inicio automático
$startupPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$startupPrograms = @("Cortana", "SearchUI", "SearchHost", "CortanaUI")
foreach ($program in $startupPrograms) {
    if (Test-Path "$startupPath\$program") {
        Remove-ItemProperty -Path $startupPath -Name $program
        Write-Host "Eliminado programa de inicio relacionado con Cortana: $program"
    }
}

Write-Host "Desactivando tareas programadas relacionadas con Cortana..."

# Tareas que podrían estar relacionadas con Cortana
$tasks = @(
    "\Microsoft\Windows\Windows Search\WSearch",
    "\Microsoft\Windows\Search\SearchIndexer",
    "\Microsoft\Windows\Search\Indexer"
)

foreach ($task in $tasks) {
    try {
        Disable-ScheduledTask -TaskName $task
        Write-Host "Tarea programada deshabilitada: $task"
    } catch {
        Write-Host "No se pudo deshabilitar la tarea: $task"
    }
}

Write-Host "Eliminando Cortana como aplicación..."

# Desinstalar la aplicación Cortana (si existe)
$apps = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*Cortana*" }

foreach ($app in $apps) {
    Write-Host "Desinstalando la aplicación Cortana: $($app.Name)"
    Remove-AppxPackage -Package $app.PackageFullName
}

# Eliminar archivos residuales relacionados con Cortana y la búsqueda
$searchFiles = @(
    "C:\Program Files\WindowsApps\Microsoft.Windows.Cortana_*\",
    "C:\Users\$env:USERNAME\AppData\Local\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\"
)

foreach ($file in $searchFiles) {
    if (Test-Path $file) {
        Remove-Item -Path $file -Recurse -Force
        Write-Host "Eliminado archivo o carpeta: $file"
    }
}