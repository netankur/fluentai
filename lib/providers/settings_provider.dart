import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final StorageService _storageService;

  SettingsNotifier(this._storageService) : super(const AppSettings()) {
    _init();
  }

  Future<void> _init() async {
    final loaded = await _storageService.loadSettings();
    state = loaded;
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    state = newSettings;
    await _storageService.saveSettings(newSettings);
  }

  Future<void> updateProvider(AIProviderType provider) async {
    final updated = state.copyWith(provider: provider);
    await updateSettings(updated);
  }

  Future<void> updateGeminiKey(String key) async {
    final updated = state.copyWith(geminiApiKey: key);
    await updateSettings(updated);
  }

  Future<void> updateOpenRouterKey(String key) async {
    final updated = state.copyWith(openrouterApiKey: key);
    await updateSettings(updated);
  }

  Future<void> updateCustomApiKey(String key) async {
    final updated = state.copyWith(customApiKey: key);
    await updateSettings(updated);
  }

  Future<void> updateCustomApiEndpoint(String endpoint) async {
    final updated = state.copyWith(customApiEndpoint: endpoint);
    await updateSettings(updated);
  }

  Future<void> updateGeminiModel(String model) async {
    final updated = state.copyWith(geminiModel: model);
    await updateSettings(updated);
  }

  Future<void> updateOpenRouterModel(String model) async {
    final updated = state.copyWith(openrouterModel: model);
    await updateSettings(updated);
  }

  Future<void> updateCustomApiModel(String model) async {
    final updated = state.copyWith(customApiModel: model);
    await updateSettings(updated);
  }

  Future<void> addCustomModel(String modelName) async {
    final name = modelName.trim();
    if (name.isEmpty) return;
    final updatedList = List<String>.from(state.userCustomModels);
    if (!updatedList.contains(name)) {
      updatedList.insert(0, name);
    }
    // Also select this new model for current provider
    AppSettings updated;
    if (state.provider == AIProviderType.gemini) {
      updated = state.copyWith(userCustomModels: updatedList, geminiModel: name);
    } else if (state.provider == AIProviderType.openrouter) {
      updated = state.copyWith(userCustomModels: updatedList, openrouterModel: name);
    } else {
      updated = state.copyWith(userCustomModels: updatedList, customApiModel: name);
    }
    await updateSettings(updated);
  }

  Future<void> removeModel(String modelName) async {
    final hiddenList = List<String>.from(state.hiddenModels);
    if (!hiddenList.contains(modelName)) {
      hiddenList.add(modelName);
    }
    final userCustomList = List<String>.from(state.userCustomModels)..remove(modelName);
    final updated = state.copyWith(hiddenModels: hiddenList, userCustomModels: userCustomList);
    await updateSettings(updated);
  }

  Future<void> updateDefaultScreen(String screenKey) async {
    final updated = state.copyWith(defaultLaunchScreen: screenKey);
    await updateSettings(updated);
  }

  Future<void> updateFontSizeScale(double scale) async {
    final updated = state.copyWith(fontSizeScale: scale);
    await updateSettings(updated);
  }

  Future<void> updateFontFamily(String family) async {
    final updated = state.copyWith(fontFamily: family);
    await updateSettings(updated);
  }

  Future<void> updateThemeMode(String modeStr) async {
    final mode = modeStr == 'light'
        ? ThemeMode.light
        : modeStr == 'dark'
            ? ThemeMode.dark
            : ThemeMode.system;
    final updated = state.copyWith(themeMode: mode);
    await updateSettings(updated);
  }

  Future<void> updateAccentColor(int colorVal) async {
    final updated = state.copyWith(accentColorValue: colorVal);
    await updateSettings(updated);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsNotifier(storage);
});
