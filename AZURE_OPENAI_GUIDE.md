# ProfetAI - Azure OpenAI Integration Guide

## Overview
ProfetAI now includes Azure OpenAI integration, allowing your oracles to provide AI-powered prophecies while maintaining their unique personalities.

## Features
- **Seamless Integration**: Each oracle (Mistico, Caotico, Cinico) can use AI when configured
- **Fallback System**: If AI is not configured or fails, the app falls back to original responses
- **Secure Storage**: API keys are stored securely using Flutter's secure storage
- **Real-time Loading**: Shows loading indicators when AI is generating responses

## Setup Instructions

### 1. Azure OpenAI Prerequisites
- Azure subscription
- Azure OpenAI resource deployed
- GPT model deployed (gpt-4o, gpt-35-turbo, etc.)

### 2. Configure Azure OpenAI in the App
1. Run the app
2. Navigate to "Impostazioni" (Settings) tab at the bottom
3. Fill in:
   - **Endpoint**: Your Azure OpenAI endpoint (e.g., `https://your-resource.openai.azure.com`)
   - **API Key**: Your Azure OpenAI API key
   - **Deployment Name**: Name of your deployed model (e.g., `gpt-4o`)
4. Tap "Salva Config" to save and test the connection

### 3. Using AI-Enhanced Prophecies
- **Random Prophecies**: Tap "Visione Spontanea" - AI will generate a prophecy in the oracle's style
- **Question-based Prophecies**: Ask a question and tap "Chiedi Profezia" - AI will respond in character
- **AI Indicator**: When AI is active, you'll see a blue "AI" badge in the prophecy dialog

## Oracle Personalities

### 🔮 Oracolo Mistico (Mystic Oracle)
- **Style**: Poetic, mystical, spiritual
- **AI Prompt**: Uses natural metaphors, cosmic themes, and ancient wisdom
- **Language**: Solemn and inspiring

### 🎲 Oracolo Caotico (Chaotic Oracle)  
- **Style**: Random, funny, unpredictable
- **AI Prompt**: Uses absurd humor, random references, and chaotic wisdom
- **Language**: Playful with random CAPS and memes

### 😒 Oracolo Cinico (Cynical Oracle)
- **Style**: Realistic, sarcastic, pragmatic
- **AI Prompt**: Provides harsh truths with dark humor
- **Language**: Direct and sometimes pessimistic but wise

## Technical Architecture

### Key Files
- `lib/models/profet.dart` - Base class with AI integration
- `lib/models/oracolo_*.dart` - Individual oracles with AI prompts
- `lib/services/azure_openai_service.dart` - Azure OpenAI API client
- `lib/screens/azure_openai_settings_screen.dart` - Configuration UI
- `lib/screens/home_screen.dart` - Updated to use AI responses

### Security Features
- API keys stored using FlutterSecureStorage
- Credentials encrypted on device
- No hardcoded secrets in the app
- Automatic fallback if AI fails

## Error Handling
- Network timeouts (30 seconds)
- Azure OpenAI API errors (401, 429, 500, etc.)
- Graceful fallback to original responses
- User-friendly error messages

## Dependencies Added
```yaml
dependencies:
  http: ^1.2.0                    # HTTP client for API calls
  flutter_secure_storage: ^9.2.2  # Secure credential storage  
  flutter_dotenv: ^5.1.0         # Environment variables
  json_annotation: ^4.9.0        # JSON serialization
```

## Usage Example

1. **Without AI configured**: App works as before with predefined responses
2. **With AI configured**: Each oracle generates contextual, AI-powered responses
3. **AI failure**: Automatically falls back to original responses

## Best Practices
- Keep your API keys secure and never commit them to version control
- Test the connection after configuration
- Monitor your Azure OpenAI usage and costs
- The app works perfectly fine without AI configuration
