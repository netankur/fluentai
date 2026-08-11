# FluentAI — AI-Powered English Writing Assistant

<p align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="120" alt="FluentAI Logo" />
  <br>
  <b>An ultra-modern, production-quality Flutter Android app for instant grammar correction, sentence rephrasing, draft writing, audio dictionary, and vocabulary mastery.</b>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-v3.0+-02569B?logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-v3.0+-0175C2?logo=dart&logoColor=white" alt="Dart"></a>
  <a href="https://android.com"><img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white" alt="Android"></a>
  <a href="https://material.io/blog/material-3-is-open-source"><img src="https://img.shields.io/badge/Design-Material--3-6750A4?logo=materialdesign&logoColor=white" alt="Material 3"></a>
  <a href="#license"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"></a>
</p>

---

## 📱 App Screenshots

<p align="center">
  <img src="flutter_01.png" width="19%" alt="Dashboard" />
  <img src="flutter_02.png" width="19%" alt="Grammar Fix" />
  <img src="flutter_03.png" width="19%" alt="Draft Writer" />
  <img src="flutter_04.png" width="19%" alt="Dictionary TTS" />
  <img src="flutter_05.png" width="19%" alt="Settings" />
</p>

---

## ✨ Features Overview

### 1. ✍️ Grammar & Spelling Correction
- **Diff Visualizer**: Highlights changes with red strikethrough for deleted text and green background for added fixes.
- **Rule Breakdown**: Clear summaries explaining why each correction was made.
- **Sample Helper**: 1-tap sample text button to quickly test grammar checking.

### 2. 🪄 Sentence Rephrasing & Refinement
- Rephrase sentences across 5 distinct target styles: **Natural**, **Formal**, **Concise**, **Academic**, and **Persuasive**.
- Provides a primary suggestion, alternative options, and key structural improvements.

### 3. 📝 AI Draft & Reply Composer
- **Dual Mode**: Switch seamlessly between **New Draft** and **Reply Draft** mode.
- **Tone Selector**: Formal, Casual, Persuasive, Professional, or Friendly.
- **Format Selector**: Email, Job Application, Letter, Essay, or Messaging.
- Generates optional subject lines, complete formatted draft text, and key points covered.

### 4. 📚 Word Dictionary & TTS Audio Pronunciation
- Detailed word lookup featuring IPA phonetics, parts of speech, definition lists, example sentences, and etymology notes.
- **Text-to-Speech (TTS) Speech Playback**: Integrated speaker button (🔊) powered by `flutter_tts` next to word definitions and example sentences for native English audio pronunciation.

### 5. 🔍 Interactive Synonyms & Antonyms
- Chip-style list of synonyms and antonyms.
- **Tappable Chip Search**: Tap any synonym or antonym chip to instantly trigger a new dictionary search for that word.

### 6. 🎓 Multi-Level Sentence Maker
- Generates practical example sentences categorized across 3 difficulty levels: **Beginner**, **Intermediate**, and **Advanced**.

---

## ⚙️ Provider & Integration Settings

- **Multiple AI Providers**:
  - **Google Gemini API**: `gemini-3.6-flash` (default), `gemini-3.5-flash`, `gemini-3.5-flash-lite`, `gemini-3.1-flash-lite`, `gemini-2.5-flash`, `gemini-2.0-flash-exp`.
  - **OpenRouter API**: `openrouter/free` (default free router), `openrouter/auto`, `google/gemma-4-26b-a4b-it:free`, `meta-llama/llama-3.3-70b-instruct:free`, `deepseek/deepseek-r1:free`, `qwen/qwen-2.5-72b-instruct:free`.
  - **Custom / OpenAI API**: Connect to self-hosted Ollama, LocalAI, vLLM, DeepSeek, or OpenAI endpoints (`https://api.openai.com/v1/chat/completions`).
- **Model List Management**:
  - Tap **`+ Add Custom Model...`** directly inside the dropdown to add custom model identifiers that persist across sessions.
  - Tap **`Manage List`** to remove unwanted preset or custom models.
- **Real-Time UI Customization**:
  - Theme mode (System / Light / Dark).
  - Dynamic Accent Color palette picker.
  - Text size scaling slider (0.8x to 1.3x).
  - Google Fonts typography picker (Inter, Poppins, Roboto, Outfit, Lora).
  - Default screen preference on launch.

---

## 🚀 Building & Running

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) v3.0.0 or higher
- Android Studio / Android SDK

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/NetAnkur/fluentai.git
   cd fluentai
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run on a connected Android device or emulator:
   ```bash
   flutter run
   ```
4. Build Release APK:
   ```bash
   flutter build apk --release
   ```
   The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 👨‍💻 Developer & Credits

- **Created & Developed by**: **NetAnkur**
- **App Version**: `v1.0.0`
- **Package Name**: `com.ad.fluentai`

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
