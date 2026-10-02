@echo off
cd /d "%~dp0"

if not exist ".venv\Scripts\activate.bat" (
    echo Could not find .venv in this folder. Put start.bat in the project folder.
    pause
    exit /b 1
)

call .venv\Scripts\activate.bat

echo Starting backend...
start "Fraud Detection - Backend" cmd /k python "script\app.py"

echo Waiting for backend to load the model...
timeout /t 8 /nobreak >nul

echo Starting front end...
start "Fraud Detection - Streamlit" cmd /k streamlit run streamlit_app.py
