<#
.SYNOPSIS
    Realiza un análisis defensivo básico-intermedio con enfoque forense en Windows.

.DESCRIPTION
    Este script genera reportes locales para apoyar el análisis inicial de posibles
    señales de intrusión, malware, backdoors o persistencia en un equipo Windows.

    Recolecta información sobre:
    - Sistema operativo
    - Microsoft Defender
    - Firewall
    - Usuarios administradores
    - Procesos activos
    - Conexiones TCP
    - Servicios automáticos
    - Tareas programadas activas
    - Programas de inicio
    - Software instalado
    - Eventos de seguridad
    - Eventos de PowerShell
    - Archivos recientes en rutas comunes usadas por malware

.NOTES
    Uso educativo, defensivo y forense básico.
    Ejecutar solo en equipos propios o con autorización.
    No modifica configuraciones.
    No elimina archivos.
    No subas reportes reales a GitHub sin anonimizar.
#>

[CmdletBinding()]
param(
    [string]$OutputPath = ".\reports-forensic-v2"
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
        Write-Host "Carpeta principal de reportes creada en: $OutputPath" -ForegroundColor Green
    }
    catch {
        Write-Error "No se pudo crear la carpeta de reportes en: $OutputPath"
        exit 1
    }
}

$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$SafeComputerName = $env:COMPUTERNAME -replace '[^a-zA-Z0-9_-]', '_'
$ReportFolder = Join-Path $OutputPath "forensic_${SafeComputerName}_$Timestamp"

New-Item -ItemType Directory -Path $ReportFolder -Force | Out-Null

$SummaryFile = Join-Path $ReportFolder "00_resumen_forense.txt"

function Add-Section {
    param(
        [string]$Title
    )

    Add-Content -Path $SummaryFile -Value ""
    Add-Content -Path $SummaryFile -Value "=================================================="
    Add-Content -Path $SummaryFile -Value $Title
    Add-Content -Path $SummaryFile -Value "=================================================="
}

function Export-Data {
    param(
        [string]$Name,
        [object]$Data
    )

    $TxtPath = Join-Path $ReportFolder "$Name.txt"
    $CsvPath = Join-Path $ReportFolder "$Name.csv"

    $Data | Format-List * | Out-String | Out-File -FilePath $TxtPath -Encoding UTF8
    $Data | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
}

function Get-FileSignatureStatus {
    param(
        [string]$FilePath
    )

    if ([string]::IsNullOrWhiteSpace($FilePath)) {
        return "Sin ruta"
    }

    if (-not (Test-Path $FilePath)) {
        return "Archivo no encontrado"
    }

    $Signature = Get-AuthenticodeSignature -FilePath $FilePath

    return $Signature.Status
}

"Reporte forense básico-intermedio de seguridad en Windows" | Out-File -FilePath $SummaryFile -Encoding UTF8
"Fecha de generación: $(Get-Date)" | Add-Content -Path $SummaryFile
"Equipo analizado: $env:COMPUTERNAME" | Add-Content -Path $SummaryFile
"Usuario que ejecutó el script: $env:USERNAME" | Add-Content -Path $SummaryFile
"Ejecutado como administrador: $IsAdmin" | Add-Content -Path $SummaryFile
"Carpeta del reporte: $ReportFolder" | Add-Content -Path $SummaryFile

Add-Section "1. Información del sistema operativo"

$SystemInfo = Get-ComputerInfo |
    Select-Object CsName,
                  WindowsProductName,
                  WindowsVersion,
                  OsArchitecture,
                  OsBuildNumber,
                  CsManufacturer,
                  CsModel,
                  CsTotalPhysicalMemory,
                  OsLastBootUpTime

$SystemInfo | Format-List | Out-String | Add-Content -Path $SummaryFile
Export-Data -Name "01_sistema_operativo" -Data $SystemInfo

Add-Section "2. Estado de Microsoft Defender"

if (Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue) {
    $DefenderStatus = Get-MpComputerStatus |
        Select-Object AMServiceEnabled,
                      AntivirusEnabled,
                      AntispywareEnabled,
                      RealTimeProtectionEnabled,
                      BehaviorMonitorEnabled,
                      IoavProtectionEnabled,
                      AntivirusSignatureLastUpdated,
                      AntispywareSignatureLastUpdated,
                      QuickScanAge,
                      FullScanAge

    $DefenderStatus | Format-List | Out-String | Add-Content -Path $SummaryFile
    Export-Data -Name "02_defender_estado" -Data $DefenderStatus
}
else {
    "Get-MpComputerStatus no está disponible en este equipo." | Add-Content -Path $SummaryFile
}

Add-Section "3. Detecciones históricas de Microsoft Defender"

if (Get-Command Get-MpThreatDetection -ErrorAction SilentlyContinue) {
    $DefenderThreats = Get-MpThreatDetection |
        Sort-Object InitialDetectionTime -Descending |
        Select-Object ThreatName,
                      ActionSuccess,
                      CleaningActionID,
                      ThreatStatusID,
                      Resources,
                      InitialDetectionTime,
                      RemediationTime

    $DefenderThreats | Select-Object -First 20 | Format-List | Out-String | Add-Content -Path $SummaryFile
    Export-Data -Name "03_defender_detecciones" -Data $DefenderThreats
}
else {
    "Get-MpThreatDetection no está disponible en este equipo." | Add-Content -Path $SummaryFile
}

Add-Section "4. Estado del Firewall de Windows"

$FirewallProfiles = Get-NetFirewallProfile |
    Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction

$FirewallProfiles | Format-Table -AutoSize | Out-String | Add-Content -Path $SummaryFile
Export-Data -Name "04_firewall_perfiles" -Data $FirewallProfiles

Add-Section "5. Miembros del grupo de administradores locales"

$AdministratorsGroup = Get-LocalGroup | Where-Object { $_.SID -eq "S-1-5-32-544" }

if ($AdministratorsGroup) {
    $Admins = Get-LocalGroupMember -Group $AdministratorsGroup.Name |
        Select-Object Name, ObjectClass, PrincipalSource

    $Admins | Format-Table -AutoSize | Out-String | Add-Content -Path $SummaryFile
    Export-Data -Name "05_administradores_locales" -Data $Admins
}
else {
    "No se pudo identificar el grupo de administradores locales." | Add-Content -Path $SummaryFile
}

Add-Section "6. Procesos activos con ruta, firma digital y hash"

$Processes = Get-Process | ForEach-Object {
    $Path = $_.Path
    $Hash = $null

    if ($Path -and (Test-Path $Path)) {
        $Hash = (Get-FileHash -Path $Path -Algorithm SHA256).Hash
    }

    [PSCustomObject]@{
        Name            = $_.Name
        Id              = $_.Id
        CPU             = $_.CPU
        Path            = $Path
        SignatureStatus = Get-FileSignatureStatus -FilePath $Path
        SHA256          = $Hash
    }
}

$Processes |
    Sort-Object Name |
    Select-Object -First 40 |
    Format-Table -AutoSize |
    Out-String |
    Add-Content -Path $SummaryFile

Export-Data -Name "06_procesos_firma_hash" -Data $Processes

Add-Section "7. Procesos ubicados en rutas comúnmente sospechosas"

$SuspiciousPathPatterns = @(
    "\AppData\",
    "\Temp\",
    "\Downloads\",
    "\Public\",
    "\ProgramData\"
)

$ProcessesFromSuspiciousPaths = $Processes | Where-Object {
    $ProcessPath = $_.Path
    $SuspiciousPathPatterns | Where-Object { $ProcessPath -like "*$_*" }
}

$ProcessesFromSuspiciousPaths |
    Format-Table -AutoSize |
    Out-String |
    Add-Content -Path $SummaryFile

Export-Data -Name "07_procesos_rutas_sospechosas" -Data $ProcessesFromSuspiciousPaths

Add-Section "8. Conexiones TCP activas con proceso asociado"

$TcpConnections = Get-NetTCPConnection | ForEach-Object {
    $Process = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        LocalAddress  = $_.LocalAddress
        LocalPort     = $_.LocalPort
        RemoteAddress = $_.RemoteAddress
        RemotePort    = $_.RemotePort
        State         = $_.State
        PID           = $_.OwningProcess
        ProcessName   = $Process.ProcessName
        ProcessPath   = $Process.Path
    }
}

$TcpConnections |
    Sort-Object State, ProcessName |
    Select-Object -First 50 |
    Format-Table -AutoSize |
    Out-String |
    Add-Content -Path $SummaryFile

Export-Data -Name "08_conexiones_tcp" -Data $TcpConnections

Add-Section "9. Servicios automáticos en ejecución con ruta"

$Services = Get-CimInstance Win32_Service |
    Where-Object { $_.StartMode -eq "Auto" -and $_.State -eq "Running" } |
    Select-Object Name,
                  DisplayName,
                  State,
                  StartMode,
                  PathName,
                  StartName |
    Sort-Object Name

$Services |
    Format-Table -AutoSize |
    Out-String |
    Add-Content -Path $SummaryFile

Export-Data -Name "09_servicios_automaticos" -Data $Services

Add-Section "10. Servicios automáticos ubicados en rutas comunes de riesgo"

$SuspiciousServices = $Services | Where-Object {
    $ServicePath = $_.PathName
    $SuspiciousPathPatterns | Where-Object { $ServicePath -like "*$_*" }
}

$SuspiciousServices |
    Format-Table -AutoSize |
    Out-String |
    Add-Content -Path $SummaryFile

Export-Data -Name "10_servicios_rutas_sospechosas" -Data $SuspiciousServices

Add-Section "11. Elementos que inician con Windows"

$StartupItems = Get-CimInstance Win32_StartupCommand |
    Select-Object Name, Command, Location, User

$StartupItems |
    Format-Table -AutoSize |
    Out-String |
    Add-Content -Path $SummaryFile

Export-Data -Name "11_inicio_windows" -Data $StartupItems

Add-Section "12. Tareas programadas activas"

$ScheduledTasks = Get-ScheduledTask |
    Where-Object { $_.State -ne "Disabled" } |
    Select-Object TaskName, TaskPath, State

$ScheduledTasks |
    Sort-Object TaskPath, TaskName |
    Select-Object -First 80 |
    Format-Table -AutoSize |
    Out-String |
    Add-Content -Path $SummaryFile

Export-Data -Name "12_tareas_programadas_activas" -Data $ScheduledTasks

Add-Section "13. Programas instalados"

$InstalledPrograms = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,
                                     HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Sort-Object DisplayName

$InstalledPrograms |
    Select-Object -First 80 |
    Format-Table -AutoSize |
    Out-String |
    Add-Content -Path $SummaryFile

Export-Data -Name "13_programas_instalados" -Data $InstalledPrograms

Add-Section "14. Eventos de inicio de sesión fallido en los últimos 7 días"

$FailedLogons = Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4625
    StartTime = (Get-Date).AddDays(-7)
} |
Select-Object TimeCreated, Id, ProviderName, Message

$FailedLogons |
    Select-Object -First 20 |
    Format-List |
    Out-String |
    Add-Content -Path $SummaryFile

Export-Data -Name "14_logins_fallidos_7_dias" -Data $FailedLogons

Add-Section "15. Eventos de privilegios especiales en los últimos 7 días"

$SpecialPrivileges = Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4672
    StartTime = (Get-Date).AddDays(-7)
} |
Select-Object TimeCreated, Id, ProviderName, Message

$SpecialPrivileges |
    Select-Object -First 20 |
    Format-List |
    Out-String |
    Add-Content -Path $SummaryFile

Export-Data -Name "15_privilegios_especiales_7_dias" -Data $SpecialPrivileges

Add-Section "16. Eventos recientes de PowerShell"

$PowerShellEvents = Get-WinEvent -FilterHashtable @{
    LogName   = 'Windows PowerShell'
    StartTime = (Get-Date).AddDays(-7)
} |
Select-Object TimeCreated, Id, ProviderName, Message

$PowerShellEvents |
    Select-Object -First 20 |
    Format-List |
    Out-String |
    Add-Content -Path $SummaryFile

Export-Data -Name "16_eventos_powershell_7_dias" -Data $PowerShellEvents

Add-Section "17. Archivos recientes en rutas comunes de interés forense"

$InterestingFolders = @(
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\OneDrive\Escritorio",
    "$env:TEMP",
    "C:\Users\Public",
    "C:\ProgramData"
)

$RecentInterestingFiles = foreach ($Folder in $InterestingFolders) {
    if (Test-Path $Folder) {
        Get-ChildItem -Path $Folder -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) } |
            Select-Object FullName, Length, CreationTime, LastWriteTime
    }
}

$RecentInterestingFiles |
    Select-Object -First 80 |
    Format-Table -AutoSize |
    Out-String |
    Add-Content -Path $SummaryFile

Export-Data -Name "17_archivos_recientes_rutas_interes" -Data $RecentInterestingFiles

Add-Section "18. Reglas de firewall habilitadas para entrada"

$InboundFirewallRules = Get-NetFirewallRule |
    Where-Object { $_.Enabled -eq "True" -and $_.Direction -eq "Inbound" } |
    Select-Object DisplayName, Enabled, Direction, Action, Profile

$InboundFirewallRules |
    Select-Object -First 80 |
    Format-Table -AutoSize |
    Out-String |
    Add-Content -Path $SummaryFile

Export-Data -Name "18_reglas_firewall_entrada" -Data $InboundFirewallRules

Add-Section "19. Recomendaciones de análisis"

@"
- Revisar procesos sin firma digital o con ruta vacía.
- Revisar procesos ejecutándose desde AppData, Temp, Downloads, Public o ProgramData.
- Revisar conexiones TCP en estado Established hacia IPs desconocidas.
- Revisar servicios automáticos con rutas fuera de Windows o Program Files.
- Revisar tareas programadas que no reconozcas.
- Revisar elementos de inicio de Windows.
- Revisar eventos 4625 para intentos fallidos de inicio de sesión.
- Revisar eventos 4672 para uso de privilegios especiales.
- Revisar eventos recientes de PowerShell.
- Revisar detecciones históricas de Microsoft Defender.
- No eliminar evidencia sin documentarla primero.
- No subir reportes reales a GitHub sin anonimizar.
"@ | Add-Content -Path $SummaryFile

Write-Host "Análisis forense V2 terminado correctamente." -ForegroundColor Green
Write-Host "Carpeta del reporte:"
Write-Host $ReportFolder
