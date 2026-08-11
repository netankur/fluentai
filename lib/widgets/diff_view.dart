import 'package:flutter/material.dart';
import '../utils/diff_util.dart';

class DiffView extends StatelessWidget {
  final List<DiffSegment> diffs;

  const DiffView({super.key, required this.diffs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final deletedBg = isDark ? Colors.red.withAlpha(60) : Colors.red.withAlpha(35);
    final deletedFg = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);

    final addedBg = isDark ? Colors.green.withAlpha(60) : Colors.green.withAlpha(35);
    final addedFg = isDark ? const Color(0xFF86EFAC) : const Color(0xFF16A34A);

    final normalFg = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: SelectableText.rich(
        TextSpan(
          children: diffs.map((seg) {
            switch (seg.type) {
              case DiffType.deleted:
                return TextSpan(
                  text: seg.text,
                  style: TextStyle(
                    color: deletedFg,
                    backgroundColor: deletedBg,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: deletedFg,
                    decorationThickness: 2,
                    fontWeight: FontWeight.w600,
                  ),
                );
              case DiffType.added:
                return TextSpan(
                  text: seg.text,
                  style: TextStyle(
                    color: addedFg,
                    backgroundColor: addedBg,
                    fontWeight: FontWeight.bold,
                  ),
                );
              case DiffType.unchanged:
                return TextSpan(
                  text: seg.text,
                  style: TextStyle(
                    color: normalFg,
                  ),
                );
            }
          }).toList(),
        ),
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }
}
