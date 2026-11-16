@echo off
title FastAPI Server - Osteoporosis Prediction
cd /d "%~dp0api"

echo ========================================================
echo   Menjalankan FastAPI Server untuk Aplikasi Osteo
echo ========================================================
echo.

if exist "venv\Scripts\activate.bat" (
    echo Mengaktifkan virtual environment (venv)...
    call venv\Scripts\activate.bat
) else (
    echo Virtual environment tidak ditemukan di api\venv, menggunakan python global...
)

echo.
echo Menjalankan uvicorn pada 0.0.0.0:8000 ...
echo Endpoint API: http://10.125.173.207:8000/predict
echo.
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload

echo.
echo Server dihentikan.
pause

