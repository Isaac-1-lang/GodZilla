@echo off
REM Deployment script for Godzilla dashboard to VPS (Windows)

set VPS_USER=emg32
set VPS_HOST=157.173.101.159
set VPS_PORT=24032
set DEPLOY_PATH=/home/emg32/godzilla

echo ================================================
echo   Deploying Godzilla Dashboard to VPS
echo ================================================

echo Creating directory on VPS...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mkdir -p %DEPLOY_PATH%/web"
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mkdir -p %DEPLOY_PATH%/mqtt_bridge"

echo Uploading dashboard...
scp -P %VPS_PORT% ..\web\dashboard.html %VPS_USER%@%VPS_HOST%:%DEPLOY_PATH%/web/

echo Uploading MQTT bridge scripts...
scp -P %VPS_PORT% ..\mqtt_bridge\*.py %VPS_USER%@%VPS_HOST%:%DEPLOY_PATH%/mqtt_bridge/
scp -P %VPS_PORT% ..\mqtt_bridge\requirements.txt %VPS_USER%@%VPS_HOST%:%DEPLOY_PATH%/mqtt_bridge/

echo.
echo ================================================
echo   Files Uploaded Successfully!
echo ================================================
echo.
echo Next steps:
echo 1. Connect to VPS: ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST%
echo 2. Setup web server (see deployment/DEPLOY_README.md)
echo ================================================
pause
