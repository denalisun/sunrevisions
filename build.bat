@echo off

set GAME_FOLDER=C:\Users\Aurora\Games\Plutonium\bo2
set OAT_BASE=C:\OpenAssetTools
set MOD_BASE=%cd%
set MOD_NAME=zm_sunrevisions
"%OAT_BASE%\Linker.exe" ^
-v ^
--load "%GAME_FOLDER%\zone\all\zm_transit.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_prison.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_highrise.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_buried.ff" ^
--load "%GAME_FOLDER%\zone\all\zm_tomb.ff" ^
--load "%GAME_FOLDER%\zone\all\patch_mp.ff" ^
--load "%GAME_FOLDER%\zone\all\common_patch_mp.ff" ^
--load "%GAME_FOLDER%\zone\all\common_mp.ff" ^
--base-folder "%OAT_BASE%" ^
--asset-search-path "%MOD_BASE%" ^
--source-search-path "%MOD_BASE%\zone_source" ^
--output-folder "%MOD_BASE%\zone" ^ mod

if %ERRORLEVEL% NEQ 0 pause

set err=%ERRORLEVEL%

pwsh -Command "Compress-Archive -Force -Path attachmentunique,scripts,weapons -DestinationPath mod.iwd"

if %err% EQU 0 (
XCOPY "%MOD_BASE%\zone\mod.ff" "%LOCALAPPDATA%\Plutonium\storage\t6\mods\%MOD_NAME%\mod.ff" /Y
XCOPY "%MOD_BASE%\mod.iwd" "%LOCALAPPDATA%\Plutonium\storage\t6\mods\%MOD_NAME%\mod.iwd" /Y
XCOPY "%MOD_BASE%\zone\mod.all.sabl" "%LOCALAPPDATA%\Plutonium\storage\t6\mods\%MOD_NAME%\mod.all.sabl" /Y
XCOPY "%MOD_BASE%\mod.json" "%LOCALAPPDATA%\Plutonium\storage\t6\mods\%MOD_NAME%\mod.json" /Y
) ELSE (
echo FAIL!
)

pause