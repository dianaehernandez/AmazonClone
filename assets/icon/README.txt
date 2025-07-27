AMAZON ICON SETUP INSTRUCTIONS
==============================

To complete the setup of your Amazon clone app, please follow these steps:

1. Save the Amazon logo image (the one you shared) as "amazon_icon.png"
2. Place it in this folder: assets/icon/amazon_icon.png
3. Make sure the image is square (recommended: 512x512 pixels or 1024x1024 pixels)
4. Run "flutter pub get" to install the flutter_launcher_icons package
5. Run "dart run flutter_launcher_icons" to generate the app icons

The app will use this icon for:
- App launcher icon on all platforms (Android, iOS, Web, Windows)
- Splash screen logo
- Login screen logo  
- Register screen logo

If the amazon_icon.png file is not found, the app will fallback to:
1. Network image from Amazon's official logo URL
2. Text fallback saying "amazon"

Current file structure should be:
assets/
  icon/
    amazon_icon.png  <-- Place your Amazon logo here
    README.txt       <-- This file
