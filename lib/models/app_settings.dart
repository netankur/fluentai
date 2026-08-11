import 'package:flutter/material.dart';

enum AIProviderType { gemini, openrouter, customApi }

class AppSettings {
  final AIProviderType provider;
  final String geminiApiKey;
  final String openrouterApiKey;
  final String customApiKey;
  final String geminiModel;
  final String openrouterModel;
  final String customApiModel;
  final String customApiEndpoint;
  final List<String> userCustomModels;
  final List<String> hiddenModels;
  final String defaultLaunchScreen;
  final double fontSizeScale;
  final String fontFamily;
  final ThemeMode themeMode;
  final int accentColorValue;

  const AppSettings({
    this.provider = AIProviderType.gemini,
    this.geminiApiKey = '',
    this.openrouterApiKey = '',
    this.customApiKey = '',
    this.geminiModel = 'gemini-3.6-flash',
    this.openrouterModel = 'openrouter/free',
    this.customApiModel = 'gpt-4o-mini',
    this.customApiEndpoint = 'https://api.openai.com/v1/chat/completions',
    this.userCustomModels = const [],
    this.hiddenModels = const [],
    this.defaultLaunchScreen = 'home',
    this.fontSizeScale = 1.0,
    this.fontFamily = 'Inter',
    this.themeMode = ThemeMode.system,
    this.accentColorValue = 0xFF6366F1, // Modern Indigo
  });

  Color get accentColor => Color(accentColorValue);

  String get activeModel {
    if (provider == AIProviderType.gemini) return geminiModel;
    if (provider == AIProviderType.openrouter) return openrouterModel;
    return customApiModel;
  }

  String get activeApiKey {
    if (provider == AIProviderType.gemini) return geminiApiKey;
    if (provider == AIProviderType.openrouter) return openrouterApiKey;
    return customApiKey;
  }

  AppSettings copyWith({
    AIProviderType? provider,
    String? geminiApiKey,
    String? openrouterApiKey,
    String? customApiKey,
    String? geminiModel,
    String? openrouterModel,
    String? customApiModel,
    String? customApiEndpoint,
    List<String>? userCustomModels,
    List<String>? hiddenModels,
    String? defaultLaunchScreen,
    double? fontSizeScale,
    String? fontFamily,
    ThemeMode? themeMode,
    int? accentColorValue,
  }) {
    return AppSettings(
      provider: provider ?? this.provider,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      openrouterApiKey: openrouterApiKey ?? this.openrouterApiKey,
      customApiKey: customApiKey ?? this.customApiKey,
      geminiModel: geminiModel ?? this.geminiModel,
      openrouterModel: openrouterModel ?? this.openrouterModel,
      customApiModel: customApiModel ?? this.customApiModel,
      customApiEndpoint: customApiEndpoint ?? this.customApiEndpoint,
      userCustomModels: userCustomModels ?? this.userCustomModels,
      hiddenModels: hiddenModels ?? this.hiddenModels,
      defaultLaunchScreen: defaultLaunchScreen ?? this.defaultLaunchScreen,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      fontFamily: fontFamily ?? this.fontFamily,
      themeMode: themeMode ?? this.themeMode,
      accentColorValue: accentColorValue ?? this.accentColorValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'geminiApiKey': geminiApiKey,
      'openrouterApiKey': openrouterApiKey,
      'customApiKey': customApiKey,
      'geminiModel': geminiModel,
      'openrouterModel': openrouterModel,
      'customApiModel': customApiModel,
      'customApiEndpoint': customApiEndpoint,
      'userCustomModels': userCustomModels,
      'hiddenModels': hiddenModels,
      'defaultLaunchScreen': defaultLaunchScreen,
      'fontSizeScale': fontSizeScale,
      'fontFamily': fontFamily,
      'themeMode': themeMode.name,
      'accentColorValue': accentColorValue,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final providerStr = json['provider'] as String?;
    AIProviderType p = AIProviderType.gemini;
    if (providerStr == 'openrouter') {
      p = AIProviderType.openrouter;
    } else if (providerStr == 'customApi') {
      p = AIProviderType.customApi;
    }

    return AppSettings(
      provider: p,
      geminiApiKey: json['geminiApiKey'] ?? '',
      openrouterApiKey: json['openrouterApiKey'] ?? '',
      customApiKey: json['customApiKey'] ?? '',
      geminiModel: json['geminiModel'] ?? 'gemini-3.6-flash',
      openrouterModel: json['openrouterModel'] ?? 'openrouter/free',
      customApiModel: json['customApiModel'] ?? 'gpt-4o-mini',
      customApiEndpoint: json['customApiEndpoint'] ?? 'https://api.openai.com/v1/chat/completions',
      userCustomModels: (json['userCustomModels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      hiddenModels: (json['hiddenModels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      defaultLaunchScreen: json['defaultLaunchScreen'] ?? 'home',
      fontSizeScale: (json['fontSizeScale'] as num?)?.toDouble() ?? 1.0,
      fontFamily: json['fontFamily'] ?? 'Inter',
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      accentColorValue: json['accentColorValue'] ?? 0xFF6366F1,
    );
  }
}
