
if not "%RUSTC_WRAPPER%" == "" (
    echo
    echo === Warning: Unset RUSTC_WRAPPER to prevent interference with sccache ===
    echo
    set RUSTC_WRAPPER=
)

set dir=%~dp0

set RUSTC=%dir%\bin\cg_clif
set RUSTDOCFLAGS=%LINKER%" -Cpanic=abort -Zpanic-abort-tests -Zcodegen-backend=%dir%\lib\librustc_codegen_cranelift.dll --sysroot %dir%"

for /F "tokens=*" %%f in (
    'rustc --print sysroot'
) do (
    set rustc_sysroot=%%f
)

set PATH=%rustc_sysroot%\lib;%dir%\lib;%PATH%
