@echo off
REM build_release.bat - Build release APK with embedded credentials (Windows)

REM Check if credentials are provided
if "%AZURE_OPENAI_ENDPOINT%"=="" (
    echo Error: AZURE_OPENAI_ENDPOINT not set!
    goto :error
)
if "%AZURE_OPENAI_API_KEY%"=="" (
    echo Error: AZURE_OPENAI_API_KEY not set!
    goto :error
)
if "%AZURE_OPENAI_DEPLOYMENT_NAME%"=="" (
    echo Error: AZURE_OPENAI_DEPLOYMENT_NAME not set!
    goto :error
)

echo Building release APK with embedded credentials...
echo Endpoint: %AZURE_OPENAI_ENDPOINT%
echo Deployment: %AZURE_OPENAI_DEPLOYMENT_NAME%
echo API Key: [HIDDEN]

REM Build the release APK with embedded credentials
flutter build apk --release ^
    --dart-define=AZURE_OPENAI_ENDPOINT=%AZURE_OPENAI_ENDPOINT% ^
    --dart-define=AZURE_OPENAI_API_KEY=%AZURE_OPENAI_API_KEY% ^
    --dart-define=AZURE_OPENAI_DEPLOYMENT_NAME=%AZURE_OPENAI_DEPLOYMENT_NAME% ^
    --dart-define=ENABLE_AI=true

if %ERRORLEVEL% EQU 0 (
    echo Release APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-release.apk
) else (
    echo Build failed!
    exit /b 1
)
goto :end

:error
echo.
echo Please set the required environment variables:
echo   set AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
echo   set AZURE_OPENAI_API_KEY=your-api-key
echo   set AZURE_OPENAI_DEPLOYMENT_NAME=your-deployment-name
echo.
echo Then run this script again.
exit /b 1

:end
