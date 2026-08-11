import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/settings_provider.dart';
import '../widgets/ai_card.dart';

class HomeScreen extends ConsumerWidget {
  final ValueChanged<int> onNavigateToTab;

  const HomeScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final hasApiKey = settings.activeApiKey.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Minimalist Glass Banner
          AICard(
            backgroundColor: isDark
                ? primary.withAlpha(25)
                : primary.withAlpha(15),
            border: Border.all(color: primary.withAlpha(45)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        settings.provider.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.memory_rounded, size: 14, color: primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              settings.activeModel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Write with Precision',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Grammar correction, sentence rephrasing, instant draft writer & vocabulary studio.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withAlpha(170),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),

          if (!hasApiKey) ...[
            const SizedBox(height: 8),
            AICard(
              backgroundColor: Colors.amber.withAlpha(20),
              border: Border.all(color: Colors.amber.withAlpha(90)),
              onTap: () => onNavigateToTab(7), // Open Settings
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.key_rounded, color: Colors.amber, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'API Key Required',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Tap to enter your ${settings.provider.name.toUpperCase()} API key in Settings.',
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.amber),
                ],
              ),
            ).animate().shake(delay: 400.ms, duration: 500.ms),
          ],

          const SizedBox(height: 24),
          Text(
            'Quick Action Studio',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),

          // Dynamically Responsive Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width < 340 ? 1 : (width < 600 ? 2 : 3);
              final aspectRatio = width < 340 ? 2.5 : (width < 380 ? 1.05 : (width < 600 ? 1.15 : 1.3));

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: aspectRatio,
                children: [
                  _buildFeatureTile(
                    context: context,
                    flatIndex: 1,
                    icon: Icons.spellcheck_rounded,
                    accentColor: const Color(0xFF3B82F6),
                    title: 'Grammar Fix',
                    description: 'Strikethrough diff & syntax corrections.',
                  ),
                  _buildFeatureTile(
                    context: context,
                    flatIndex: 2,
                    icon: Icons.auto_fix_high_rounded,
                    accentColor: const Color(0xFF8B5CF6),
                    title: 'Rephrase Sentence',
                    description: 'Formal, natural & concise styles.',
                  ),
                  _buildFeatureTile(
                    context: context,
                    flatIndex: 3,
                    icon: Icons.history_edu_rounded,
                    accentColor: const Color(0xFFEC4899),
                    title: 'Draft & Reply Writer',
                    description: 'Emails, replies & essays.',
                  ),
                  _buildFeatureTile(
                    context: context,
                    flatIndex: 4,
                    icon: Icons.menu_book_rounded,
                    accentColor: const Color(0xFF10B981),
                    title: 'Word Dictionary',
                    description: 'Definitions & phonetics lookup.',
                  ),
                  _buildFeatureTile(
                    context: context,
                    flatIndex: 5,
                    icon: Icons.style_rounded,
                    accentColor: const Color(0xFFF59E0B),
                    title: 'Synonyms & Antonyms',
                    description: 'Interactive chip re-search.',
                  ),
                  _buildFeatureTile(
                    context: context,
                    flatIndex: 6,
                    icon: Icons.format_quote_rounded,
                    accentColor: const Color(0xFF06B6D4),
                    title: 'Sentence Maker',
                    description: 'Beginner to advanced examples.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required BuildContext context,
    required int flatIndex,
    required IconData icon,
    required Color accentColor,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return AICard(
      padding: const EdgeInsets.all(14),
      onTap: () => onNavigateToTab(flatIndex),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
