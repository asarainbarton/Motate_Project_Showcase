#!/bin/bash

echo "🚀 Setting up Flutter Emotion Journal App..."
echo "=" * 50

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Check Flutter doctor
echo "🔍 Running Flutter doctor..."
flutter doctor

# Get dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Check for connected devices
echo "📱 Checking for available devices..."
flutter devices

echo ""
echo "🎉 Setup complete! You can now run the app with:"
echo "   flutter run"
echo ""
echo "📱 Available run commands:"
echo "   flutter run -d chrome    # Run on web browser"
echo "   flutter run -d android   # Run on Android device/emulator"
echo "   flutter run -d ios       # Run on iOS device/simulator"
echo ""
echo "🔧 Make sure your backend server is running on http://localhost:8000"
