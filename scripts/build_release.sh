#!/bin/bash
# build_release.sh - Build release APK with embedded credentials

# Check if credentials are provided
if [ -z "$AZURE_OPENAI_ENDPOINT" ] || [ -z "$AZURE_OPENAI_API_KEY" ] || [ -z "$AZURE_OPENAI_DEPLOYMENT_NAME" ]; then
    echo "Error: Required environment variables not set!"
    echo "Please set:"
    echo "  - AZURE_OPENAI_ENDPOINT"
    echo "  - AZURE_OPENAI_API_KEY"
    echo "  - AZURE_OPENAI_DEPLOYMENT_NAME"
    exit 1
fi

echo "Building release APK with embedded credentials..."
echo "Endpoint: $AZURE_OPENAI_ENDPOINT"
echo "Deployment: $AZURE_OPENAI_DEPLOYMENT_NAME"
echo "API Key: [HIDDEN]"

# Build the release APK with embedded credentials
flutter build apk --release \
    --dart-define=AZURE_OPENAI_ENDPOINT="$AZURE_OPENAI_ENDPOINT" \
    --dart-define=AZURE_OPENAI_API_KEY="$AZURE_OPENAI_API_KEY" \
    --dart-define=AZURE_OPENAI_DEPLOYMENT_NAME="$AZURE_OPENAI_DEPLOYMENT_NAME" \
    --dart-define=ENABLE_AI=true

echo "Release APK built successfully!"
echo "Location: build/app/outputs/flutter-apk/app-release.apk"
