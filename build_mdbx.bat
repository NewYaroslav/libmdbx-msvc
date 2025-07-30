@echo off
setlocal enabledelayedexpansion

:: === Step 0: Paths ===
set DLL_NAME=mdbx
set BUILD_DIR=build
set BIN_DIR=bin
set LIB_DIR=lib
set DEF_FILE=%BUILD_DIR%\%LIB_DIR%\%DLL_NAME%.def
set LIB_FILE=%BUILD_DIR%\%LIB_DIR%\%DLL_NAME%.lib

:: === Step 1: Locate MinGW ===
set "MINGW_BIN="

for %%I in ("%PATH:;=","%") do (
    if exist "%%~I\gcc.exe" (
        set "MINGW_BIN=%%~I\"
        goto found_mingw
    )
)

:found_mingw
if not defined MINGW_BIN (
    echo [ERROR] MinGW not found in PATH.
    goto END
)
echo [INFO] MinGW found at: !MINGW_BIN!

:: === Step 2: Locate vcvars64.bat ===
echo [INFO] Searching for Visual Studio using vswhere...
for /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
    set "VS_PATH=%%i"
)

if not defined VS_PATH (
    echo [ERROR] Visual Studio not found!
    goto END
)

set "VCVARS_PATH=%VS_PATH%\VC\Auxiliary\Build\vcvars64.bat"
if not exist "!VCVARS_PATH!" (
    echo [ERROR] vcvars64.bat not found at expected path: !VCVARS_PATH!
    goto END
)
echo [INFO] Visual Studio found at: !VS_PATH!

:: === Step 3: Build DLL with MinGW ===
echo [INFO] Building %DLL_NAME%.dll using MinGW...
cmake -S . -B %BUILD_DIR% -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DMDBX_BUILD_SHARED_LIBRARY=ON -DBUILD_MDBX_DLL=ON
cmake --build %BUILD_DIR% --config Release

if not exist "%BUILD_DIR%\bin\libmdbx.dll" (
    echo [ERROR] DLL not found after build!
    goto END
)

:: === Step 4: Extract .def file using nm ===
echo [INFO] Generating .def file from DLL exports...
echo EXPORTS > "%DEF_FILE%"

"%MINGW_BIN%nm.exe" -g --defined-only "%BUILD_DIR%\bin\libmdbx.dll" ^
  | findstr " T _" ^
  | findstr /V ".refptr" ^
  | findstr /V ".weak." ^
  | findstr /V "__Z" ^
  | findstr /V "__guard" ^
  | findstr /V "__imp_" ^
  | findstr /V "__CTOR_LIST__" ^
  | findstr /V "__cpu_model" ^
  | findstr /V "__TI" ^
  | findstr /V ".data" ^
  | findstr /V ".rdata" ^
  | findstr /V ".pdata" ^
  | findstr /V ".bss" ^
  | findstr /V ".xdata" ^
  | findstr /V "$" ^
  | findstr /V "??" ^
  | findstr /R "^[^\.].*" ^
  | for /f "tokens=3" %%s in ('more') do echo %%s >> "%DEF_FILE%"

if not exist "%DEF_FILE%" (
    echo [ERROR] Failed to generate .def file!
    goto END
)

:: === Step 5: Create .lib using MSVC ===
echo [INFO] Creating .lib from .def using MSVC...

if not exist "%BUILD_DIR%\%LIB_DIR%" mkdir "%BUILD_DIR%\%LIB_DIR%"

:: call vcvars in *current shell* by using cmd /k then continuing
cmd /C ""%VCVARS_PATH%" && lib /def:"%DEF_FILE%" /machine:x64 /out:"%LIB_FILE%""

if exist "%LIB_FILE%" (
    echo [SUCCESS] .lib created at: %LIB_FILE%
) else (
    echo [ERROR] Failed to create .lib file!
)

:END
echo [INFO] DLL is in %BIN_DIR%, LIB is in %LIB_DIR%

:: === Step 6: Cleanup unnecessary files ===
echo [INFO] Cleaning up unnecessary files from %BUILD_DIR%...

for /d %%D in (%BUILD_DIR%\*) do (
    set "folder=%%~nxD"
    if /I not "!folder!"=="%BIN_DIR%" if /I not "!folder!"=="%LIB_DIR%" if /I not "!folder!"=="include" (
        rmdir /s /q "%%D"
    )
)

pushd %BUILD_DIR%
del /f /q * >nul 2>&1
popd

for %%F in (%BUILD_DIR%\%LIB_DIR%\*) do (
    if /I not "%%~xF"==".lib" if /I not "%%~xF"==".def" (
        del /f /q "%%F"
    )
)

echo [INFO] Cleanup complete.
echo.
echo [DONE] Build complete.
pause
