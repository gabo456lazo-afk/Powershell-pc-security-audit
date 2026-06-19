<#
.SYNOPSIS
    Realiza un análisis básico de seguridad y diagnóstico en un equipo Windows.

.DESCRIPTION
    Este script genera un reporte local con información básica del sistema,
    actualizaciones, Microsoft Defender, Firewall de Windows, administradores
    locales y servicios iniciados automáticamente.

.NOTES
    Uso educativo y defensivo.
    Ejecutar solo en equipos propios o con autorización.
    No subir reportes reales a repositorios públicos.
#>

[CmdletBinding()]
param(
    [string]$OutputPath = ".\reports"
)

$ErrorActionPreference = "SilentlyContinue"
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $IsAdmin) {
    Write-Warning "PowerShell no se está ejecutando como administrador. Algunos datos podrían no mostrarse completos."
}
else {
    Write-Host "PowerShell se está ejecutando como administrador." -ForegroundColor Green
}
if (-not (Test-Path $OutputPath)) {
    try {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        Write-Host "Carpeta de reportes creada en: $OutputPath" -ForegroundColor Green
    }
    catch {
        Write-Error "No se pudo crear la carpeta de reportes en: $OutputPath"
        exit 1
    }
}
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$SafeComputerName = $env:COMPUTERNAME -replace '[^a-zA-Z0-9_-]', '_'
$ReportFile = Join-Path $OutputPath "pc-security-audit_${SafeComputerName}_$Timestamp.txt"

function Add-Section {
    param(
        [string]$Title
    )

    Add-Content -Path $ReportFile -Value ""
    Add-Content -Path $ReportFile -Value "=================================================="
    Add-Content -Path $ReportFile -Value $Title
    Add-Content -Path $ReportFile -Value "=================================================="
}

"Reporte básico de análisis de seguridad del equipo" | Out-File -FilePath $ReportFile -Encoding UTF8
"Fecha de generación: $(Get-Date)" | Add-Content -Path $ReportFile
"Equipo analizado: $env:COMPUTERNAME" | Add-Content -Path $ReportFile

Add-Section "1. Información del sistema operativo"

Get-ComputerInfo |
    Select-Object CsName, WindowsProductName, WindowsVersion, OsArchitecture, OsBuildNumber |
    Format-List |
    Out-String |
    Add-Content -Path $ReportFile

Add-Section "2. Últimas actualizaciones instaladas"

Get-HotFix |
    Sort-Object InstalledOn -Descending |
    Select-Object -First 10 |
    Format-Table -AutoSize |
    Out-String |
    Add-Content -Path $ReportFile

Add-Section "3. Estado de Microsoft Defender"

if (Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue) {
    Get-MpComputerStatus |
        Select-Object AMServiceEnabled,
                      AntivirusEnabled,
                      AntispywareEnabled,
                      RealTimeProtectionEnabled,
                      BehaviorMonitorEnabled,
                      IoavProtectionEnabled,
                      AntivirusSignatureLastUpdated,
                      AntispywareSignatureLastUpdated |
        Format-List |
        Out-String |
        Add-Content -Path $ReportFile
}
else {
    "Get-MpComputerStatus no está disponible en este equipo." | Add-Content -Path $ReportFile
}

Add-Section "4. Estado del Firewall de Windows"

Get-NetFirewallProfile |
    Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction |
    Format-Table -AutoSize |
    Out-String |
    Add-Content -Path $ReportFile

Add-Section "5. Miembros del grupo de administradores locales"

$AdministratorsGroup = Get-LocalGroup | Where-Object { $_.SID -eq "S-1-5-32-544" }

if ($AdministratorsGroup) {
    Get-LocalGroupMember -Group $AdministratorsGroup.Name |
        Select-Object Name, ObjectClass, PrincipalSource |
        Format-Table -AutoSize |
        Out-String |
        Add-Content -Path $ReportFile
}
else {
    "No se pudo identificar el grupo de administradores locales." | Add-Content -Path $ReportFile
}

Add-Section "6. Servicios iniciados automáticamente"

Get-CimInstance Win32_Service |
    Where-Object { $_.StartMode -eq "Auto" -and $_.State -eq "Running" } |
    Select-Object Name, DisplayName, State, StartMode |
    Sort-Object Name |
    Format-Table -AutoSize |
    Out-String |
    Add-Content -Path $ReportFile

Add-Section "7. Recomendaciones iniciales"

@"
- Revisar que Microsoft Defender esté activo.
- Confirmar que el Firewall de Windows esté habilitado.
- Verificar que no existan usuarios administradores desconocidos.
- Mantener Windows actualizado.
- No compartir este reporte públicamente sin anonimizarlo.
"@ | Add-Content -Path $ReportFile

Write-Host "Reporte creado correctamente en: $ReportFile"
