@echo off
mkdir release 2>nul
mkdir \Toonku-Release\lib 2>nul
robocopy lib Toonku-Release/lib LightVolumes.cginc >nul
robocopy . Toonku-Release ^
Toonku.cginc ^
Util.cginc ^
ToonkuInclude.cginc ^
toonku_fireworks.cginc ^
snowflake.cginc ^
Snow2.cginc ^
ny2022.cginc ^
Toonku.shader ^
ToonkuAlpha.shader ^
ToonkuAlpha2Sided.shader ^
ToonkuFireworks.shader ^
ToonkuRobePattern.shader ^
ToonkuSnow.shader ^
ToonkuSnow2.shader ^
ToonkuXmasLights.shader >nul

for /f %%i in ('git rev-parse --short HEAD') do set HASH=%%i
7z a release/Toonku-%HASH%.zip Toonku-Release >nul
rmdir Toonku-Release /S /Q
