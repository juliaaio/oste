@echo off
echo ============================================
echo   Osteocare Dev Runner
echo ============================================
echo.

:: Jalankan server FastAPI di background window terpisah
echo [1/2] Menjalankan server FastAPI di port 8000...
start "FastAPI Server" cmd /k "cd /d D:\FlutterProject\Osteo\api && .\venv\Scripts\uvicorn.exe main:app --host 0.0.0.0 --port 8000 --reload"

:: Tunggu server siap
echo Menunggu server siap (5 detik)...
timeout /t 5 /nobreak > nul

:: Forward port via USB (jika menggunakan HP fisik dengan kabel data)
echo Menyiapkan port forwarding USB (adb reverse)...
if exist "%LOCALAPPDATA%\Android\sdk\platform-tools\adb.exe" (
    "%LOCALAPPDATA%\Android\sdk\platform-tools\adb.exe" reverse tcp:8000 tcp:8000
) else (
    adb reverse tcp:8000 tcp:8000 2>nul
)

:: Jalankan Flutter
echo [2/2] Menjalankan Flutter app...
cd /d D:\FlutterProject\Osteo
flutter run --dart-define-from-file=.env

pause

