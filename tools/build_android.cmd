@echo off
echo Building for arm32... &
cmd /c adt -package -target apk -arch armv7 -storetype pkcs12 -keystore afclient.p12 -storepass 192837465 Astroflux_arm32.apk application.xml Preload.swf icons &
echo Building for arm64... &
cmd /c adt -package -target apk -arch armv8 -storetype pkcs12 -keystore afclient.p12 -storepass 192837465 Astroflux_arm64.apk application.xml Preload.swf icons &
echo Finished all builds!