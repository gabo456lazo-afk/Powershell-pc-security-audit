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

## Guia de ejecucion paso a paso







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

