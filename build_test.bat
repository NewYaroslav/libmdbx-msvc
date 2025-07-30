@echo off
setlocal enabledelayedexpansion

echo [INFO] Searching for installed Visual Studio using vswhere...

:: Get the installation path of the latest Visual Studio instance
for /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`) do (
    set "VS_PATH=%%i"
)

if not defined VS_PATH (
    echo [ERROR] Visual Studio not found!
    exit /b 1
)

echo [INFO] Visual Studio found at: !VS_PATH!

:: Detect version from path
set "GEN="
echo !VS_PATH! | findstr /I "2017" >nul && set GEN=Visual Studio 15 2017
echo !VS_PATH! | findstr /I "2019" >nul && set GEN=Visual Studio 16 2019
echo !VS_PATH! | findstr /I "2022" >nul && set GEN=Visual Studio 17 2022

:: Fallback if not detected
if not defined GEN (
    echo [WARN] Could not detect Visual Studio version from path
    echo [WARN] Defaulting to Visual Studio 17 2022
    set "GEN=Visual Studio 17 2022"
)

echo [INFO] Using CMake generator: !GEN!

cmake -S . -B build -G "!GEN!" -A x64 -DBUILD_TEST_PROGRAM=ON
cmake --build build --config Release

echo [DONE]
pause