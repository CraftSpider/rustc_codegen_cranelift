@echo off

setlocal enableDelayedExpansion

CALL config.bat || GOTO :error

SET RUSTC=%cd%\bin\cg_clif_build_sysroot.exe
SET RUSTFLAGS=%RUSTFLAGS% --clif

cd %~dp0

:: FIXME Make this not clean up build scripts/incremental
rd /S /Q target

set CARGO_TARGET_DIR=target
set RUSTFLAGS=%RUSTFLAGS% -Zforce-unstable-if-unmarked -Cpanic=abort
set __CARGO_DEFAULT_LIB_METADATA="cg_clif"
if not "%1" == "--debug" (
    set sysroot_channel="release"
    setlocal
    set CARGO_INCREMENTAL=0
    set RUSTFLAGS=%RUSTFLAGS% -Zmir-opt-level=2
    cargo build --target %TARGET_TRIPLE% --release || GOTO :error
    endlocal
) else (
    set sysroot_channel="debug"
    cargo build --target %TARGET_TRIPLE% || GOTO :error
)

for /F %%f ("target\%TARGET_TRIPLE%\%sysroot_channel%\deps\*") do (
    mklink %cd%\lib\rustlib\%TARGET_TRIPLE%\lib\%%~nxf %%f || GOTO :error
)

mkdir /h %cd%\lib\rustlib\%TARGET_TRIPLE%\lib\ target\%TARGET_TRIPLE%\%sysroot_channel%\deps\

for /F %%f ("%cd%\lib\rustlib\%TARGET_TRIPLE%\lib\*.rmeta") do (
    rm %%f
)
for /F %%f ("%cd%\lib\rustlib\%TARGET_TRIPLE%\lib\*.d") do (
    rm %%f
)

EXIT /b 0

:error
echo Failed to build sysroot
EXIT /b 1
