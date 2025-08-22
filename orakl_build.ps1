# orakl_build.ps1
# Unified build/run script for Orakl

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("release", "debug", "production", "local_debug")]
    [string]$Mode
)

# Function to load environment variables from .env file
function Load-EnvVars {
    param(
        [string]$EnvFilePath = "./local_credentials.env"
    )
    if (Test-Path $EnvFilePath) {
        Get-Content $EnvFilePath | ForEach-Object {
            if ($_ -match "^\s*#" -or $_ -match "^\s*$") { return }
            $parts = $_ -split "=", 2
            if ($parts.Length -eq 2) {
                $name = $parts[0].Trim()
                $value = $parts[1].Trim()
                [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
            }
        }
    } else {
        Write-Host "Env file not found: $EnvFilePath" -ForegroundColor Red
        exit 1
    }
}

# Load environment variables
Load-EnvVars

# Functions for each mode
function Build-Release {
    Write-Host "Building Orakl Production App Bundle..."
    flutter build appbundle --release `
        --dart-define=AZURE_OPENAI_ENDPOINT="$env:AZURE_OPENAI_ENDPOINT" `
        --dart-define=AZURE_OPENAI_API_KEY="$env:AZURE_OPENAI_API_KEY" `
        --dart-define=AZURE_OPENAI_DEPLOYMENT_NAME="$env:AZURE_OPENAI_DEPLOYMENT_NAME" `
        --dart-define=ENABLE_AI=true `
        --dart-define=DEBUG_LOGGING=false `
        --dart-define=DEBUG_ALERTS=false

    Write-Host "Production App Bundle build completed!"
    Write-Host "AAB location: build\app\outputs\bundle\release\app-release.aab"
}

function Build-Debug {
    Write-Host "Building Orakl Release with AI and Debug..."
    flutter build apk --release `
        --dart-define=AZURE_OPENAI_ENDPOINT="$env:AZURE_OPENAI_ENDPOINT" `
        --dart-define=AZURE_OPENAI_API_KEY="$env:AZURE_OPENAI_API_KEY" `
        --dart-define=AZURE_OPENAI_DEPLOYMENT_NAME="$env:AZURE_OPENAI_DEPLOYMENT_NAME" `
        --dart-define=ENABLE_AI=true `
        --dart-define=DEBUG_LOGGING=true `
        --dart-define=DEBUG_ALERTS=true

    Write-Host "Build completed!"
    Write-Host "APK location: build\app\outputs\flutter-apk\app-release.apk"
}

function Build-Production {
    Write-Host "Building Orakl Production Release..."
    flutter build apk --release `
        --dart-define=AZURE_OPENAI_ENDPOINT="$env:AZURE_OPENAI_ENDPOINT" `
        --dart-define=AZURE_OPENAI_API_KEY="$env:AZURE_OPENAI_API_KEY" `
        --dart-define=AZURE_OPENAI_DEPLOYMENT_NAME="$env:AZURE_OPENAI_DEPLOYMENT_NAME" `
        --dart-define=ENABLE_AI=true `
        --dart-define=DEBUG_LOGGING=false `
        --dart-define=DEBUG_ALERTS=false

    Write-Host "Production build completed!"
    Write-Host "APK location: build\app\outputs\flutter-apk\app-release.apk"
}

function Run-LocalDebug {
    Write-Host "Running Orakl locally with AI and Debug enabled..."
    flutter run `
        --dart-define=AZURE_OPENAI_ENDPOINT="$env:AZURE_OPENAI_ENDPOINT" `
        --dart-define=AZURE_OPENAI_API_KEY="$env:AZURE_OPENAI_API_KEY" `
        --dart-define=AZURE_OPENAI_DEPLOYMENT_NAME="$env:AZURE_OPENAI_DEPLOYMENT_NAME" `
        --dart-define=ENABLE_AI=true `
        --dart-define=DEBUG_LOGGING=true `
        --dart-define=DEBUG_ALERTS=true

    Write-Host "Local development session started with AI configuration!"
}

# Main logic
switch ($Mode) {
    "release"      { Build-Release }
    "debug"        { Build-Debug }
    "production"   { Build-Production }
    "local_debug"  { Run-LocalDebug }
    default        { Write-Host "Unknown mode: $Mode" -ForegroundColor Red; exit 1 }
}
