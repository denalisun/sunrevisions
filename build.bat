if exist "dist" (
    del /s /f /q dist
)

if exist "inter" (
    del /s /f /q inter
)

mkdir inter
mkdir dist

if exist "zm_weapons" (
    xcopy "zm_weapons\mod.iwd" "inter" /Y
    ren "inter\mod.iwd" "mod.zip"
    powershell -Command Expand-Archive "inter\mod.zip" "inter"
    del "inter\mod.zip"
)

xcopy "src\" "inter\" /Y
powershell -Command Compress-Archive "inter\*" "dist\mod.zip"
ren "dist\mod.zip" "mod.iwd"
xcopy "mod.json" "dist\mod.json" /Y /F

del /s /f /q inter

xcopy "dist\" "%LOCALAPPDATA%\Plutonium\storage\t6\mods\zm_overhaul" /E /H /I /Y

if exist "zm_weapons" (
    xcopy "zm_weapons\mod.ff" "%LOCALAPPDATA%\Plutonium\storage\t6\mods\zm_overhaul" /E /H /I /Y
    xcopy "zm_weapons\mod.all.sabl" "%LOCALAPPDATA%\Plutonium\storage\t6\mods\zm_overhaul" /E /H /I /Y
)

pause