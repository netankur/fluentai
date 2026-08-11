import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final int maxLines;
  final int minLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final String? sampleText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.maxLines = 5,
    this.minLines = 3,
    this.onChanged,
    this.onSubmitted,
    this.sampleText,
  });

  Future<void> _pasteFromClipboard(BuildContext context) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      controller.text = data.text!;
      if (onChanged != null) onChanged!(data.text!);
    }
  }

  void _clearText() {
    controller.clear();
    if (onChanged != null) onChanged!('');
  }

  void _useSampleText() {
    if (sampleText != null && sampleText!.isNotEmpty) {
      controller.text = sampleText!;
      if (onChanged != null) onChanged!(sampleText!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  labelText!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (sampleText != null && sampleText!.isNotEmpty)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _useSampleText,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Try Sample',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131C2E) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.black.withAlpha(8),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: controller,
                maxLines: maxLines,
                minLines: minLines,
                onChanged: onChanged,
                textInputAction: maxLines == 1 ? TextInputAction.done : TextInputAction.newline,
                onSubmitted: (_) => onSubmitted?.call(),
                style: const TextStyle(fontSize: 15, height: 1.5),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withAlpha(120),
                    fontSize: 14,
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Word & Character counter
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, child) {
                        final text = value.text.trim();
                        final wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
                        final charCount = value.text.length;
                        return Text(
                          '$wordCount words · $charCount chars',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: theme.textTheme.bodySmall?.color?.withAlpha(130),
                          ),
                        );
                      },
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller,
                          builder: (context, value, child) {
                            if (value.text.isEmpty) return const SizedBox.shrink();
                            return Container(
                              height: 32,
                              margin: const EdgeInsets.only(right: 6),
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.clear_rounded, size: 16),
                                label: const Text('Clear', style: TextStyle(fontSize: 12)),
                                onPressed: _clearText,
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 32,
                          child: FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.content_paste_rounded, size: 14),
                            label: const Text('Paste', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () => _pasteFromClipboard(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
