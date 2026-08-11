import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/settings_provider.dart';
import 'main_shell.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const String _fullTitle = 'FluentAI';
  String _displayedTitle = '';
  int _charIndex = 0;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();
  }

  void _startTypingAnimation() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 140), (timer) {
      if (_charIndex < _fullTitle.length) {
        setState(() {
          _displayedTitle += _fullTitle[_charIndex];
          _charIndex++;
        });
      } else {
        _typingTimer?.cancel();
        _navigateToNext();
      }
    });
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final settings = ref.read(settingsProvider);
    final initialTab = _getInitialTabIndex(settings.defaultLaunchScreen);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secondaryAnim) => MainShell(initialIndex: initialTab),
        transitionsBuilder: (context, anim, secondaryAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  int _getInitialTabIndex(String key) {
    switch (key) {
      case 'grammar':
        return 1;
      case 'sentence':
        return 2;
      case 'draft':
        return 3;
      case 'dictionary':
        return 4;
      case 'synonyms':
        return 5;
      case 'sentence_maker':
        return 6;
      case 'home':
      default:
        return 0;
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.brightness == Brightness.dark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E1B4B),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFEEF2FF),
                  ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primary.withAlpha(30),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primary.withAlpha(80),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.edit_note_rounded,
                size: 64,
                color: primary,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _displayedTitle,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: primary,
                    letterSpacing: -1,
                  ),
                ),
                Container(
                  width: 3,
                  height: 38,
                  margin: const EdgeInsets.only(left: 4),
                  color: primary,
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .fade(duration: 500.ms),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your AI-Powered Writing Assistant',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
                letterSpacing: 0.5,
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
