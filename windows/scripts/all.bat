@echo off
powershell -ExecutionPolicy Bypass -File 1-Hardening-Services.ps1 -Apply"
powershell -ExecutionPolicy Bypass -File 2-Debloater.ps1"
powershell -ExecutionPolicy Bypass -File 3-TaskDebloater.ps1"
powershell -ExecutionPolicy Bypass -File 4-HardeningRegistry.ps1"
powershell -ExecutionPolicy Bypass -File noia.ps1"
powershell -ExecutionPolicy Bypass -File nologs.ps1"
powershell -ExecutionPolicy Bypass -File noprocess.ps1"
pause