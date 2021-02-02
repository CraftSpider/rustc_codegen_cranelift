
SET CG_CLIF_DISPLAY_CG_TIME=1
SET CG_CLIF_INCR_CACHE_DISABLED=1

for /F "tokens=2 delims=: " %%x in (
    'rustc -vV ^| findstr host'
) do (
    SET HOST_TRIPLE=%%x
)

:: FIXME(CraftSpider) Allow customizing the target
SET TARGET_TRIPLE=%HOST_TRIPLE%

SET RUN_WRAPPER=""
SET JIT_SUPPORTED=0

if not %HOST_TRIPLE% == %TARGET_TRIPLE% (
    echo Not yet supported on Windows
    EXIT /b 1
)

EXIT /b 0
