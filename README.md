# Profet AI 🔮

**Profet AI** is an immersive mystical prediction app that connects users with three unique AI-powered oracles. Each oracle has its own personality, visual theme, and approach to providing insights and predictions.

## ✨ Features

### 🧙‍♂️ Three Unique Oracles
- **Mystic Oracle** - Ancient wisdom and spiritual guidance
- **Chaotic Oracle** - Unpredictable and wild predictions
- **Cynical Oracle** - Sharp, realistic, and brutally honest insights

### 🎯 Core Functionality
- **Personalized Predictions** - Ask questions and receive tailored responses
- **Random Visions** - Get spontaneous insights from your chosen oracle
- **Vision Book** - Save and revisit your favorite predictions
- **Dynamic Theming** - Each oracle has unique colors and visual identity
- **Immersive UI** - Beautiful gradients and atmospheric backgrounds

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
   git clone https://github.com/giorgiococci/ProfetAI.git
   cd ProfetAI
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

```
lib/
├── main.dart                 # App entry point and navigation
├── models/                   # Data models and business logic
│   ├── profet.dart          # Abstract base class for oracles
│   ├── profet_manager.dart  # Oracle management system
│   ├── oracolo_mistico.dart # Mystic Oracle implementation
│   ├── oracolo_caotico.dart # Chaotic Oracle implementation
│   └── oracolo_cinico.dart  # Cynical Oracle implementation
└── screens/                 # UI screens
    ├── home_screen.dart         # Main interaction screen
    ├── profet_selection_screen.dart # Oracle selection
    ├── profile_screen.dart      # User profile
    └── vision_book_screen.dart  # Saved predictions
```

## 🎨 Design Philosophy

Profet AI embraces a **dark, mystical aesthetic** with:
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
