import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: FluentAIApp()));
}

class FluentAIApp extends ConsumerWidget {
  const FluentAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final lightTheme = AppTheme.createTheme(
      brightness: Brightness.light,
      primaryColor: settings.accentColor,
      fontFamily: settings.fontFamily,
      textScaleFactor: settings.fontSizeScale,
    );

    final darkTheme = AppTheme.createTheme(
      brightness: Brightness.dark,
      primaryColor: settings.accentColor,
      fontFamily: settings.fontFamily,
      textScaleFactor: settings.fontSizeScale,
    );

    return MaterialApp(
      title: 'FluentAI',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.themeMode,
      home: const SplashScreen(),
    );
  }
}
