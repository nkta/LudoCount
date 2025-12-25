#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "🚀 Starting Android App Bundle build..."

# Navigate to the project root
# Assuming the script is in scripts/ directory
cd "$(dirname "$0")/.."

echo "🧹 Cleaning project..."
flutter clean

echo "📦 Getting packages..."
flutter pub get

echo "🏗️  Building App Bundle..."
flutter build appbundle --release

echo "✅ Build complete!"
echo "📂 Output: build/app/outputs/bundle/release/app-release.aab"
