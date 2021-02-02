@echo off

SETLOCAL enableextensions enableDelayedExpansion

cd "%~dp0"

for /F "tokens=*" %%x in (
    'rustup which rustc'
) do (
    SET SRC_DIR="%%~dpx\..\lib\rustlib\src\rust\"
)

SET DST_DIR="sysroot_src"

rd /S /Q %DST_DIR%
md %DST_DIR%\library || goto :error
xcopy /E /Y %SRC_DIR%\library %DST_DIR%\library || goto :error

pushd %DST_DIR%
echo [GIT] init
git init || goto :error
echo [GIT] add
git add . || goto :error
echo [GIT] commit
git commit -q -m "Initial commit" || goto :error
for /F %%f in (
    'dir "..\..\patches\" ^| findstr patcha'
) do (
    echo [GIT] apply %%f
    git apply "../../patches/%%f" || goto :error
    git add -A || goto :error
    git commit --no-gpg-sign -m "Patch %%f" || goto :error
)
popd

git clone https://github.com/rust-lang/compiler-builtins.git || echo rust-lang/compiler-builtins has already been cloned
pushd compiler-builtins
git checkout -- . || goto :error
git checkout 0.1.39 || goto :error
git apply ../../crate_patches/0001-compiler-builtins-Remove-rotate_left-from-Int.patch || goto :error
popd

echo Successfully prepared sysroot source for building
EXIT /b 0

:error
echo Failed to prepare sysroot
EXIT /b 1
