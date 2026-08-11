import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/ai_service.dart';
import '../services/custom_api_service.dart';
import '../services/gemini_service.dart';
import '../services/openrouter_service.dart';
import 'settings_provider.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  final settings = ref.watch(settingsProvider);

  if (settings.provider == AIProviderType.gemini) {
    return GeminiService(
      apiKey: settings.geminiApiKey,
      model: settings.geminiModel,
    );
  } else if (settings.provider == AIProviderType.openrouter) {
    return OpenRouterService(
      apiKey: settings.openrouterApiKey,
      model: settings.openrouterModel,
    );
  } else {
    return CustomApiService(
      apiKey: settings.customApiKey,
      endpoint: settings.customApiEndpoint,
      model: settings.customApiModel,
    );
  }
});
