@echo off
setlocal

REM --- CONFIG ---
set PYDIR=py314
set PYEXE=%PYDIR%\python.exe
set WHEEL_DIR=wheels
set TEMP_DIR=__whl_extract
set PTH_FILE=%PYDIR%\%PYDIR%.pth

REM --- Clean temp ---
if exist %TEMP_DIR% rmdir /s /q %TEMP_DIR%
mkdir %TEMP_DIR%

REM --- Extract wheels ---
echo Extracting pip...
%PYEXE% -m zipfile -e %WHEEL_DIR%\pip-25.1.1-py3-none-any.whl %TEMP_DIR%\pip

echo Extracting setuptools...
%PYEXE% -m zipfile -e %WHEEL_DIR%\setuptools-70.0.0-py3-none-any.whl %TEMP_DIR%\setuptools

REM --- Ensure directories exist ---
mkdir %PYDIR%\Lib\site-packages
mkdir %PYDIR%\Scripts

REM --- Install pip/setuptools manually ---
xcopy /E /Y %TEMP_DIR%\pip\pip %PYDIR%\Lib\site-packages\pip\
xcopy /E /Y %TEMP_DIR%\pip\pip-25.1.1.dist-info %PYDIR%\Lib\site-packages\pip-25.1.1.dist-info\
xcopy /E /Y %TEMP_DIR%\setuptools\setuptools %PYDIR%\Lib\site-packages\setuptools\
xcopy /E /Y %TEMP_DIR%\setuptools\setuptools-70.0.0.dist-info %PYDIR%\Lib\site-packages\setuptools-70.0.0.dist-info\

REM --- Optional: create pip launcher ---
echo Checking pip...
%PYEXE% -m pip --version >nul 2>&1
if errorlevel 1 (
    echo Creating pip.py launcher...
    echo from pip._internal.cli.main import main as _main > %PYDIR%\Scripts\pip.py
    echo if __name__ == '__main__': >> %PYDIR%\Scripts\pip.py
    echo     _main() >> %PYDIR%\Scripts\pip.py
)

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

REM --- Activate the venv and open shell ---
echo Activating virtual environment...
call env\Scripts\activate.bat

REM --- Install all wheels in wheels directory ---
echo Installing all wheels in %WHEEL_DIR% ...
for %%f in (%WHEEL_DIR%\*.whl) do (
    echo Installing %%f ...
    env\Scripts\python.exe -m pip install "%%f"
)

cmd

endlocal
