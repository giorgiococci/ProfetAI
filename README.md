# Orakl 🔮

**Orakl** is an immersive mystical prediction app that connects users with three unique AI-powered oracles. Each oracle has its own personality, visual theme, and approach to providing insights and predictions.

## ✨ Features

### 🧙‍♂️ Three Unique Oracles

- **Mystic Oracle** - Ancient wisdom and spiritual guidance
- **Chaotic Oracle** - Unpredictable and wild predictions
- **Cynical Oracle** - Sharp, realistic, and brutally honest insights

### 🎯 Core Functionality

- **Onboarding Experience** - Welcome flow introducing app features and optional personalization
- **Personalized Predictions** - Ask questions and receive tailored responses
- **Random Visions** - Get spontaneous insights from your chosen oracle
- **Vision Book** - Save and revisit your favorite predictions
- **Conversation System** - Persistent conversations with oracles across sessions
- **AI-Powered Bio System** - Invisible personalization that learns from your interactions
- **Dynamic Theming** - Each oracle has unique colors and visual identity
- **Immersive UI** - Beautiful gradients and atmospheric backgrounds

### 🧠 AI-Powered Personalization

- **Invisible Bio Collection** - System learns your interests and preferences through natural interactions
- **Smart Context Integration** - Oracles reference your personal details (hobbies, interests) naturally
- **Privacy-First Design** - 4-tier privacy filtering ensures sensitive information stays protected
- **Cross-Session Memory** - Oracles remember your previous conversations and insights
- **Adaptive Responses** - Predictions become more relevant and personalized over time

### 📱 Cross-Platform Support

- iOS
- Android
- Windows
- macOS
- Linux
- Web

## 🚀 Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (latest stable version)
- [Dart SDK](https://dart.dev/get-dart)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/giorgiococci/Orakl.git
   cd Orakl
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**

   ```bash
   flutter run
   ```

   For specific platforms:

   ```bash
   # iOS
   flutter run -d ios

   # Android
   flutter run -d android

   # Windows
   flutter run -d windows

   # Web
   flutter run -d web
   ```

## 🏗️ Project Structure

```text
lib/
├── main.dart                 # App entry point and navigation
├── models/                   # Data models and business logic
│   ├── profet.dart          # Abstract base class for oracles
│   ├── profet_manager.dart  # Oracle management system
│   ├── oracolo_mistico.dart # Mystic Oracle implementation
│   ├── oracolo_caotico.dart # Chaotic Oracle implementation
│   └── oracolo_cinico.dart  # Cynical Oracle implementation
├── screens/                 # UI screens
│   ├── home_screen.dart         # Main interaction screen
│   ├── profet_selection_screen.dart # Oracle selection
│   ├── profile_screen.dart      # User profile
│   ├── vision_book_screen.dart  # Saved predictions
│   └── onboarding/              # Onboarding flow
│       ├── onboarding_flow.dart           # Main onboarding controller
│       ├── onboarding_welcome_screen.dart # Welcome & app intro
│       ├── onboarding_features_screen.dart # Features showcase
│       └── onboarding_personalization_screen.dart # Optional user setup
└── services/                # Business logic and data services
    ├── onboarding_service.dart  # Onboarding state management
    └── user_profile_service.dart # User preferences and data
```

## 🎨 Design Philosophy

Orakl embraces a **dark, mystical aesthetic** with:

- Deep purple and gradient color schemes
- Atmospheric backgrounds and overlays
- Smooth animations and transitions
- Intuitive bottom navigation
- Responsive design across all platforms

## 🔮 Oracle Personalities

Each oracle is carefully designed with unique characteristics:

- **Visual Identity** - Custom colors, gradients, and backgrounds
- **Response Style** - Distinct personality in predictions
- **Thematic Consistency** - Icons, imagery, and language that match their nature

## 🛠️ Built With

- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **Material 3** - Modern design system
- **Custom Theming** - Dynamic color schemes per oracle

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 Acknowledgments

- Flutter community for excellent documentation
- Material Design team for beautiful components
- The mystical forces that inspired this creation ✨

---

*"The future is not set in stone, but in the wisdom of the oracles."* 🔮
