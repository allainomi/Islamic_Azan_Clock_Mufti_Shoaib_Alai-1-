Islamic Azan & Clock by Mufti Shoaib Alai

This is a ready-to-use Flutter project (skeleton) that contains:
- lib/main.dart : main application code (digital clock + Hijri date + manual prayer times + azan playback)
- pubspec.yaml : required dependencies
- assets/ : placeholder for azan.mp3 (replace with your azan audio)
- android/ : minimal Android manifest and launcher icons

IMPORTANT:
1) Replace `assets/azan.mp3` with a real Azan MP3 file (clear audio) before building release APK.
2) To build:
   flutter pub get
   flutter build apk --release

3) If you want a custom app icon, replace files in android/app/src/main/res/mipmap-*/ic_launcher.png