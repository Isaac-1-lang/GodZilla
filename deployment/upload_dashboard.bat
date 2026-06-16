@echo off
REM Quick script to upload just the dashboard

echo ================================================
echo   Uploading Dashboard to VPS
echo ================================================

echo Creating directory...
ssh -p 24032 emg32@157.173.101.159 "mkdir -p /home/emg32/godzilla/web"

echo Uploading dashboard.html...
scp -P 24032 ..\web\dashboard.html emg32@157.173.101.159:/home/emg32/godzilla/web/

echo.
echo Verifying upload...
ssh -p 24032 emg32@157.173.101.159 "ls -lh /home/emg32/godzilla/web/"

echo.
echo ================================================
echo   Upload Complete!
echo ================================================
echo.
echo Now on VPS run:
echo   cd ~/godzilla/web
echo   python3 -m http.server 8083
echo.
echo Then access: http://157.173.101.159:8083/dashboard.html
echo ================================================
pause
