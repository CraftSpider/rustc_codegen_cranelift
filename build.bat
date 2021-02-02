@echo off

:: This makes variables in loops behave like a sane language
SETLOCAL enableDelayedExpansion

:: Settings
SET CHANNEL="release"
SET build_sysroot="clif"
SET target_dir="build"
SET oldbe=

:: No, there are no while loops in batch
:while_loop
if not "%1" == "" (
    if "%1" == "--debug" (
        SET CHANNEL="debug"
    ) else if "%1" == "--sysroot" (
        SET build_sysroot=%2
        SHIFT
    ) else if "%1" == "--target-dir" (
        SET target_dir=%2
        SHIFT
    ) else if "%1" == "--oldbe" (
        SET oldbe=--features oldbe
    ) else (
        ECHO Unknown flag '%1'
        ECHO Usage: ./build.bat [--debug] [--sysroot none^|clif^|llvm] [--target-dir DIR] [--oldbe]
        GOTO :error
    )
    SHIFT
    GOTO :while_loop
)

SET CARGO_TARGET_DIR=
:: SET RUSTFLAGS=

if %CHANNEL% == "release" (
    cargo build %oldbe% --release || GOTO :error
) else (
    cargo build %oldbe% || GOTO :error
)

CALL scripts\ext_config.bat || GOTO :error

rd /S /Q %target_dir% || GOTO :error
md %target_dir% || GOTO :error
md %target_dir%\lib %target_dir%\bin || GOTO :error

mklink /h %target_dir%\bin\cg_clif.exe target\%CHANNEL%\cg_clif.exe || GOTO :error
mklink /h %target_dir%\bin\cg_clif_build_sysroot.exe target\%CHANNEL%\cg_clif_build_sysroot.exe || GOTO :error

for %%f in ("target\%CHANNEL%\*rustc_codegen_cranelift*") do (
    mklink /h %target_dir%\lib\%%~nxf %%f || GOTO :error
)

mklink /h %target_dir%\rust-toolchain rust-toolchain || GOTO :error
mklink /h %target_dir%\config.bat scripts\config.bat || GOTO :error
:: mklink /h %target_dir%\cargo.bat scripts\cargo.bat || GOTO :error

md %target_dir%\lib\rustlib\%TARGET_TRIPLE%\lib\

if %build_sysroot% == "none" (
    rem
) else if %build_sysroot% == "llvm" (
    echo FIXME^(LLVM^)
) else if %build_sysroot% == "clif" (
    echo [BUILD] sysroot
    SET dir=%cd%
    cd %target_dir%
    CALL !dir!\build_sysroot\build_sysroot.bat || GOTO :error
) else (
    echo Unknown sysroot kind `%build_sysroot%`.
    echo The allowed values are:
    echo     none A sysroot that doesn't contain the standard library
    echo     llvm Copy the sysroot from rustc compiled by cg_llvm
    echo     clif Build a new sysroot using cg_clif
    EXIT /b 1
)

EXIT /b 0

:error
echo Failed to build cg_clif
EXIT /b 1
