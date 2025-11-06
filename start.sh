#!/bin/bash

# Check if Flutter is installed, if not install it
if ! command -v flutter &> /dev/null; then
    echo "Flutter not found, installing..."
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable
    export PATH="$PATH:$(pwd)/flutter/bin"
fi

# Build the Flutter web app
echo "Building Flutter web app..."
flutter build web --release --web-renderer canvaskit

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful! Starting server..."
    # Serve the built app
    cd build/web
    python3 -m http.server 8080
else
    echo "Build failed!"
    exit 1
fi