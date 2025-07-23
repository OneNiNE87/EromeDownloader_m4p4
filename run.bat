@echo off
setlocal

REM --- CONFIG ---
set PYDIR=py314
set PYEXE=%PYDIR%\python.exe
set WHEEL_DIR=wheels
set PIP_WHL=%WHEEL_DIR%\pip-25.1.1-py3-none-any.whl
set PTH_FILE=%PYDIR%\%PYDIR%.pth

REM --- Ensure site-packages is enabled ---
findstr /C:"import site" %PTH_FILE% >nul 2>&1
if errorlevel 1 (
    echo Enabling site-packages...
    echo import site>> %PTH_FILE%
)

REM --- Create virtual environment if not exists ---
if not exist env\Scripts\activate.bat (
    echo Creating virtual environment...
    %PYEXE% -m venv env
)

REM --- Install pip from wheel if not present ---
if not exist env\Scripts\pip.exe (
    echo Installing pip from wheel...
    env\Scripts\python.exe %PIP_WHL --no-warn-script-location
)

REM --- Activate the venv ---
echo Activating virtual environment...
call env\Scripts\activate.bat

REM --- Install all wheels in wheels directory except pip ---
echo Installing all wheels in %WHEEL_DIR% ...
for %%f in (%WHEEL_DIR%\*.whl) do (
    echo %%f | findstr /I "pip-25.1.1-py3-none-any.whl" >nul
    if errorlevel 1 (
        echo Installing %%f ...
        python -m pip install "%%f"
    )
)

cmd

endlocal
