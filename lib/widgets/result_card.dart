import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'ai_card.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final Widget content;
  final String copyableText;
  final String? subtitle;

  const ResultCard({
    super.key,
    required this.title,
    required this.content,
    required this.copyableText,
    this.subtitle,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: copyableText));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Copied to clipboard!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareContent() {
    Share.share(copyableText, subject: title);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return AICard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: 'Copy',
                visualDensity: VisualDensity.compact,
                onPressed: () => _copyToClipboard(context),
              ),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                icon: const Icon(Icons.share_rounded, size: 18),
                tooltip: 'Share',
                visualDensity: VisualDensity.compact,
                onPressed: _shareContent,
              ),
            ],
          ),
          const Divider(height: 28),
          content,
        ],
      ),
    );
  }
}
