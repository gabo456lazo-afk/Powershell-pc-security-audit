# PowerShell PC Security Audit

Repositorio educativo con scripts en PowerShell para realizar análisis básico de seguridad y diagnóstico en equipos Windows.

## Objetivo

Este proyecto tiene como finalidad practicar ciberseguridad defensiva desde un nivel básico, documentando scripts útiles para revisar el estado general de una computadora Windows.

Los scripts incluidos están pensados para:

* Analizar información básica del sistema operativo.
* Revisar actualizaciones instaladas.
* Consultar el estado de Microsoft Defender.
* Verificar perfiles del Firewall de Windows.
* Identificar miembros del grupo de administradores locales.
* Generar reportes locales para análisis posterior.

## Uso responsable

Este repositorio es únicamente para fines educativos, defensivos y de aprendizaje.

No debe utilizarse para analizar equipos ajenos sin autorización previa.
No se deben subir reportes reales con información sensible a GitHub.
Los ejemplos publicados deben estar anonimizados.

## Estructura del repositorio

```text
powershell-pc-security-audit/
│
├── scripts/
│   └── Get-PCSecurityAudit.ps1
│
├── docs/
│   └── notas-de-aprendizaje.md
│
├── examples/
│   └── reporte-ejemplo-anonimizado.txt
│
├── reports/
│   └── .gitkeep
│
├── .gitignore
├── LICENSE
└── README.md
```

## Primer script

El primer script del proyecto se llama:

```text
Get-PCSecurityAudit.ps1
```

Este script genera un reporte básico del equipo en modo lectura. No modifica configuraciones del sistema.

## Requisitos

* Windows 10 o Windows 11.
* PowerShell 5.1 o superior.
* Ejecutar PowerShell como administrador para obtener mejores resultados.

## Guía de ejecución paso a paso

Sigue estos pasos para ejecutar el script de forma local en un equipo Windows.

### 1. Descargar el repositorio

Puedes descargar el repositorio desde GitHub usando la opción:

```text
Code > Download ZIP
```

Luego descomprime el archivo en una carpeta local de tu computadora.

También puedes clonar el repositorio si ya tienes Git instalado:

```powershell
git clone https://github.com/gabo456lazo-afk/powershell-pc-security-audit.git
```

### 2. Abrir PowerShell como administrador

Busca PowerShell en el menú de inicio de Windows.

Haz clic derecho y selecciona:

```text
Ejecutar como administrador
```

Esto permite obtener información más completa del sistema.

### 3. Entrar a la carpeta del proyecto

Usa el comando `cd` para entrar a la carpeta donde descargaste el repositorio.

Ejemplo:

```powershell
cd .\Downloads\powershell-pc-security-audit
```

Ajusta la ruta según la ubicación real del proyecto en tu computadora.

### 4. Permitir ejecución temporal de scripts

Ejecuta el siguiente comando:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
```

Este cambio solo aplica a la sesión actual de PowerShell y permite ejecutar el script durante esa sesión.

### 5. Ejecutar el script

Ejecuta el script con:

```powershell
.\scripts\Get-PCSecurityAudit.ps1
```

### 6. Revisar el reporte generado

El script generará un archivo de reporte dentro de la carpeta:

```text
reports/
```

El archivo tendrá un nombre parecido a:

```text
pc-security-audit_NOMBRE-EQUIPO_2026-06-18_21-00-00.txt
```

### 7. Advertencia sobre reportes reales

No subas reportes reales a GitHub.

Los reportes pueden contener información sensible como nombre del equipo, usuarios locales, servicios instalados, fechas de actualización o configuraciones del sistema.

Antes de compartir evidencia, crea una versión anonimizada y elimina cualquier dato sensible.

## Ejecución básica

Desde la carpeta del repositorio:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
.\scripts\Get-PCSecurityAudit.ps1
```

El reporte se guardará en la carpeta `reports`.

## Advertencia

No publiques reportes reales generados desde equipos personales, laborales o de terceros. Antes de compartir cualquier evidencia, elimina nombres de usuarios, nombres de equipos, rutas internas, direcciones IP privadas, correos, claves, tokens o cualquier otro dato sensible.

## Estado del proyecto

Proyecto en etapa inicial.
Este repositorio forma parte de una ruta de aprendizaje en GitHub, PowerShell y ciberseguridad defensiva.

