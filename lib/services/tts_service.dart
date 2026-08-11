import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> _init() async {
    if (!_isInitialized) {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.45); // Slightly slower for clear dictionary pronunciation
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    }
  }

  static Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _init();
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {
      // Fallback gracefully if TTS audio engine is unavailable
    }
  }

  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }
}
