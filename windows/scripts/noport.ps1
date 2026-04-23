# Script para cerrar puertos no necesarios mediante reglas de Firewall

# Función para bloquear un puerto
function Block-Port {
    param (
        [int]$Port
    )

    # Crear una nueva regla en el firewall para bloquear el puerto
    New-NetFirewallRule -DisplayName "Bloquear puerto $Port" -Direction Inbound -Protocol TCP -LocalPort $Port -Action Block
    Write-Host "Regla creada para bloquear el puerto $Port."
    
    New-NetFirewallRule -DisplayName "Bloquear puerto $Port UDP" -Direction Inbound -Protocol UDP -LocalPort $Port -Action Block
    Write-Host "Regla creada para bloquear el puerto $Port (UDP)."
}

# Lista de puertos a bloquear (especificados en el ejemplo)
$portsToBlock = @(
    135,    # RPC
    500,    # IKE
    4500,   # IKE NAT-T
    5353,   # DNS
    5355,   # DNS
    49664..49671  # Puertos temporales de Windows
)

# Bloquear los puertos especificados
foreach ($port in $portsToBlock) {
    Block-Port -Port $port
}

Write-Host "Todos los puertos especificados han sido bloqueados."