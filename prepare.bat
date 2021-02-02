@echo off

:: This makes variables in loops behave like a sane language
SETLOCAL enableDelayedExpansion

rustup component add rust-src rustc-dev llvm-tools-preview || goto :error
CALL build_sysroot\prepare_sysroot_src.bat || goto :error
cargo install hyperfine || echo Skipping hyperfine install

git clone https://github.com/rust-random/rand.git || echo rust-random/rand has already been cloned
pushd rand
git checkout -- . || goto :error
git checkout 0f933f9c7176e53b2a3c7952ded484e1783f0bf1 || goto :error
for %%f in ("..\crate_patches\*-rand-*.patch") do (
    git am "..\crate_patches\%%f" || goto :error
)
popd

git clone https://github.com/rust-lang/regex.git || echo rust-lang/regex has already been cloned
pushd regex
git checkout -- . || goto :error
git checkout 341f207c1071f7290e3f228c710817c280c8dca1 || goto :error
popd

git clone https://github.com/ebobby/simple-raytracer || echo ebobby/simple-raytracer has already been cloned
pushd simple-raytracer
git checkout -- . || goto :error
git checkout 804a7a21b9e673a482797aa289a18ed480e4d813 || goto :error

:: Build with cg_llvm for perf comparison
SET CARGO_TARGET_DIR=
cargo build || goto :error
echo "%cd%"
move target\debug\main.exe raytracer_cg_llvm || goto :error
popd

EXIT /b 0

:error
echo Failed to prepare cg_clif
EXIT /b 1
