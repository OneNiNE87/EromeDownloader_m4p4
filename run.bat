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

REM --- Set PATH to use venv Scripts first ---
set "PATH=%CD%\env\Scripts;%PATH%"

REM --- Activate the venv ---
echo Activating virtual environment...
call env\Scripts\activate.bat

REM --- Ensure pip is installed in the venv ---
if not exist env\Scripts\pip.exe (
    echo Bootstrapping pip in the virtual environment...
    "%CD%\env\Scripts\python.exe" -m ensurepip --upgrade
    REM Check again if pip exists
    if not exist env\Scripts\pip.exe (
        echo ensurepip failed, trying to install pip from wheel directly...
        "%CD%\env\Scripts\python.exe" "%WHEEL_DIR%\pip-25.1.1-py3-none-any.whl/pip/__main__.py" install "%PIP_WHL%"
    )
    REM Final check
    if not exist env\Scripts\pip.exe (
        echo ERROR: pip could not be installed in the virtual environment!
        exit /b 1
    )
)

REM --- Install all wheels in wheels directory except pip ---
echo Installing all wheels in %WHEEL_DIR% ...
for %%f in (%WHEEL_DIR%\*.whl) do (
    echo %%f | findstr /I "pip-25.1.1-py3-none-any.whl" >nul
    if errorlevel 1 (
        echo Installing %%f ...
        "%CD%\env\Scripts\python.exe" -m pip install "%%f"
    )
)

cmd

endlocal
