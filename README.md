# Olympus Balance

A beautiful, glassmorphism-styled food tracking app for iOS and Android, built with Flutter.

## Features

### 🎯 Core Features
- **User Profile Management**: Track your body metrics (age, gender, height, weight)
- **Progress Tracking**: Monitor weight changes over time with historical data
- **Calorie Tracking**: Automatic BMR and TDEE calculations based on your profile
- **Meal Logging**: Add meals with photos, calories, and macronutrients
- **Custom & Predefined Menus**: Follow meal plans or create your own
- **Smart Notifications**: Reminders for water intake and meals
- **Beautiful Statistics**: Daily and weekly progress visualization

### 📱 App Screens
1. **Welcome Screen**: Elegant introduction to the app
2. **Profile Setup**: Step-by-step onboarding to collect user data
3. **Home Screen**: Daily calorie tracking with circular progress indicator
4. **Add Meal Screen**: Camera integration for meal photos with detailed nutrition entry
5. **Menus Screen**: Browse and follow predefined or custom meal plans
6. **Profile Screen**: View statistics, update weight, manage settings

### 🎨 Design
- **Glassmorphism UI**: Frosted glass effect with blur and transparency
- **Soft Color Palette**: Calm, light colors (light blue, purple, orange tones)
- **Monochrome Text**: Black, white, and gray text only
- **Rounded Corners**: 16-20px border radius throughout
- **White Borders**: 1.5px white borders on glass elements
- **iOS-Inspired**: Glass effect similar to iOS design language

## Tech Stack

- **Flutter SDK**: 3.9.2+
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Notifications**: flutter_local_notifications
- **Image Handling**: image_picker, path_provider
- **Date Formatting**: intl

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme/
│   └── app_theme.dart       # Glassmorphism theme & colors
├── models/
│   ├── user_profile.dart    # User data model with BMR/TDEE calculations
│   ├── meal.dart            # Meal and daily meals models
│   ├── menu.dart            # Menu and menu meal models
│   └── notification_settings.dart
├── providers/
│   ├── user_provider.dart   # User state management
│   ├── meal_provider.dart   # Meal tracking state
│   └── menu_provider.dart   # Menu management state
├── services/
│   ├── storage_service.dart # Local data persistence
│   └── notification_service.dart # Push notifications
├── widgets/
│   ├── glass_container.dart # Reusable glass effect container
│   ├── glass_button.dart    # Glassmorphism buttons
│   └── glass_text_field.dart # Glass-styled text inputs
└── screens/
    ├── welcome_screen.dart
    ├── profile_setup_screen.dart
    ├── main_navigation.dart  # Bottom navigation with glass effect
    ├── home_screen.dart
    ├── add_meal_screen.dart
    ├── menus_screen.dart
    └── profile_screen.dart
```

## Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK
- iOS Simulator or Android Emulator

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

### iOS Setup
For camera and photo library access, the required permissions are already configured in `ios/Runner/Info.plist`.

### Android Setup
For camera and storage access, the required permissions are already configured in the Android manifest.

## Features in Detail

### Calorie Calculations
- **BMR (Basal Metabolic Rate)**: Calculated using Mifflin-St Jeor Equation
  - Male: (10 × weight) + (6.25 × height) - (5 × age) + 5
  - Female: (10 × weight) + (6.25 × height) - (5 × age) - 161
- **TDEE (Total Daily Energy Expenditure)**: BMR × Activity Level Multiplier
  - Sedentary: 1.2
  - Lightly Active: 1.375
  - Moderately Active: 1.55
  - Very Active: 1.725
  - Extremely Active: 1.9

### Meal Tracking
- Photo capture or gallery selection
- Nutritional information: calories, protein, carbs, fat, weight
- Meal categorization: breakfast, lunch, dinner, snack
- Historical tracking by day
- Daily and weekly statistics

### Notification System
- Water intake reminders (customizable times)
- Meal reminders (breakfast, lunch, dinner)
- Daily summary notifications
- Fully customizable in settings

## Color Palette

- **Primary Light**: `#E8F4F8` (Very light blue)
- **Secondary Light**: `#F5E6F8` (Very light purple)
- **Accent Light**: `#FFF4E6` (Very light orange)
- **Background**: `#F8F9FA` (Off-white)
- **Text Black**: `#1A1A1A`
- **Text Gray**: `#6B7280`
- **Glass White**: `#FFFFFF` (with opacity)

## Future Enhancements

- Water intake tracking
- Barcode scanner for food items
- Recipe database integration
- Social features (share meals, follow friends)
- Export data (PDF reports, CSV)
- Dark mode support
- Multi-language support
- Integration with fitness trackers

## License

This project is created for educational and personal use.

## Author

Created with ❤️ using Flutter

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
