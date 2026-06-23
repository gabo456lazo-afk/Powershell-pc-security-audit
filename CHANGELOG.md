# Changelog

Todos los cambios importantes de este proyecto serán documentados en este archivo.

El formato está basado en una estructura simple de versiones para mantener un historial claro del avance del repositorio.

## [0.2.0] - 2026-06-23

### Added

* Agregado el script `Get-PCSecurityForensicAuditV2.ps1`.
* Agregado análisis defensivo y forense básico-intermedio para equipos Windows.
* Recolección de procesos activos con ruta, firma digital y hash SHA256.
* Recolección de conexiones TCP activas con proceso asociado.
* Revisión de servicios automáticos en ejecución.
* Revisión de tareas programadas activas.
* Revisión de programas instalados.
* Revisión de eventos de seguridad relacionados con inicios de sesión fallidos.
* Revisión de eventos de privilegios especiales.
* Revisión de eventos recientes de PowerShell.
* Revisión de archivos recientes en rutas comunes de interés forense.
* Exportación de resultados en archivos `.txt` y `.csv`.

### Security

* Se agregó protección para la carpeta `reports-forensic-v2/` mediante `.gitignore`.
* Se reforzó la advertencia sobre no subir reportes reales a GitHub.
* Se mantiene el enfoque educativo, defensivo y autorizado del proyecto.

### Changed

* El proyecto evoluciona desde una auditoría básica hacia un análisis defensivo más completo.

## [0.1.0] - 2026-06-18

### Added

* Creación inicial del repositorio `powershell-pc-security-audit`.
* Agregado del archivo `README.md` con la descripción del proyecto.
* Agregado del script `Get-PCSecurityAudit.ps1` para análisis básico de seguridad en equipos Windows.
* Creación de la carpeta `scripts/` para almacenar scripts PowerShell.
* Creación de la carpeta `reports/` para reportes generados localmente.
* Agregado del archivo `.gitignore` para evitar subir reportes reales o archivos sensibles.
* Creación de la carpeta `docs/` para documentación y notas de aprendizaje.
* Creación de la carpeta `examples/` con un reporte anonimizado de ejemplo.
* Agregada licencia MIT al proyecto.

### Security

* Se agregó protección mediante `.gitignore` para evitar subir reportes reales generados por el script.
* Se incluyó una advertencia en el `README.md` sobre no publicar información sensible.
* Se documentó el uso responsable del proyecto con fines educativos y defensivos.

### Documentation

* Se agregó documentación inicial del objetivo del proyecto.
* Se documentó la estructura del repositorio.
* Se agregó una explicación básica de ejecución del script.
* Se creó un archivo de notas de aprendizaje en `docs/notas-de-aprendizaje.md`.

## Próximas mejoras

* Mejorar el script PowerShell con validaciones adicionales.
* Agregar una sección de resultados esperados en el `README.md`.
* Crear una guía paso a paso para ejecutar el script desde PowerShell.
* Agregar más ejemplos anonimizados.
* Crear una primera versión oficial del proyecto en GitHub Releases.
