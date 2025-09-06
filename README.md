# QuizApp

A comprehensive quiz application built with Flutter and Firebase, featuring modern UI design and robust functionality.

## Overview

QuizApp is a Quizlet-inspired mobile application that allows users to create, manage, and take quizzes. The app supports multiple study modes including flashcards, practice tests, and timed quizzes with detailed analytics and progress tracking.

## Features

- **Authentication**: Secure user registration and login with Firebase Auth
- **Quiz Management**: Create, edit, and organize quizzes with multiple question types
- **Study Modes**: Flashcards, practice mode, and timed tests
- **Progress Tracking**: Detailed statistics and performance analytics
- **Modern UI**: Material 3 design with light/dark theme support

## Tech Stack

- **Framework**: Flutter/Dart
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Architecture**: Clean Architecture with MVVM pattern
- **State Management**: Provider
- **UI**: Material 3 with Google Fonts

## Project Structure

```
lib/
├── core/                 # Core utilities and constants
│   ├── constants/
│   ├── themes/
│   └── utils/
├── data/                 # Data layer
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/               # Business logic layer
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/         # UI layer
    ├── screens/
    ├── widgets/
    └── providers/
```

## Firebase Setup

### Prerequisites

1. Flutter SDK installed
2. Firebase CLI installed
3. Firebase project created

### Configuration Steps

1. **Create Firebase Project**
   ```bash
   # Visit Firebase Console and create a new project
   # Project ID: quiz-1155b (or your custom ID)
   ```

2. **Enable Required Services**
   - Authentication (Email/Password)
   - Cloud Firestore (in test mode)
   - Storage (optional, for image uploads)

3. **Configure Android**
   ```bash
   # Download google-services.json from Firebase Console
   # Place it in android/app/google-services.json
   ```

4. **Configure iOS**
   ```bash
   # Download GoogleService-Info.plist from Firebase Console
   # Place it in ios/Runner/GoogleService-Info.plist
   ```

5. **Generate Firebase Options**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Configure Flutter project
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

6. **Install Dependencies**
   ```bash
   flutter pub get
   ```

## Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd quizapp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (follow Firebase Setup section above)

4. **Run the application**
   ```bash
   flutter run
   ```

### Development

- **Run on specific device**
  ```bash
  flutter run -d <device-id>
  ```

- **Build for production**
  ```bash
  # Android
  flutter build apk --release
  
  # iOS
  flutter build ios --release
  
  # Web
  flutter build web
  ```

## Contributing

1. Fork the project
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
