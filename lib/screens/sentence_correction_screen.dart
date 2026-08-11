import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_response.dart';
import '../providers/ai_provider.dart';
import '../widgets/ai_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/primary_button.dart';
import '../widgets/result_card.dart';

class SentenceCorrectionScreen extends ConsumerStatefulWidget {
  const SentenceCorrectionScreen({super.key});

  @override
  ConsumerState<SentenceCorrectionScreen> createState() =>
      _SentenceCorrectionScreenState();
}

class _SentenceCorrectionScreenState
    extends ConsumerState<SentenceCorrectionScreen> {
  final TextEditingController _sentenceController = TextEditingController();
  String _selectedStyle = 'Natural';
  final List<String> _styles = ['Natural', 'Formal', 'Concise', 'Academic', 'Persuasive'];

  bool _isLoading = false;
  SentenceCorrectionResult? _result;
  String? _errorMessage;

  static const String _sampleSentence =
      "I want to tell you that I am very interested for this job position at your company.";

  @override
  void dispose() {
    _sentenceController.dispose();
    super.dispose();
  }

  Future<void> _rephraseSentence() async {
    final text = _sentenceController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a sentence to rephrase.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final res = await aiService.correctSentence(text, _selectedStyle);
      if (!mounted) return;
      setState(() {
        _result = res;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _sentenceController,
            labelText: 'Original Sentence',
            hintText: 'Enter sentence to fix or rephrase...',
            maxLines: 4,
            minLines: 2,
            sampleText: _sampleSentence,
          ),
          const SizedBox(height: 18),
          Text(
            'Target Style',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _styles.map((style) {
                final isSelected = _selectedStyle == style;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(style),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedStyle = style);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            text: 'Rephrase & Refine Sentence',
            icon: Icons.auto_fix_high_rounded,
            isLoading: _isLoading,
            onPressed: _rephraseSentence,
          ),
          const SizedBox(height: 24),
          if (_isLoading) ...[
            const LoadingIndicator(message: 'Rephrasing sentence...'),
          ] else if (_errorMessage != null) ...[
            AICard(
              backgroundColor: Colors.red.withAlpha(20),
              border: Border.all(color: Colors.red.withAlpha(80)),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.red, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_result != null) ...[
            ResultCard(
              title: 'Best Rephrased Sentence',
              subtitle: 'Style: $_selectedStyle',
              copyableText: _result!.primaryCorrection,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SelectableText(
                      _result!.primaryCorrection,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (_result!.alternatives.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      'Alternative Phrasings',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._result!.alternatives.map(
                      (alt) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                            Expanded(child: SelectableText(alt, style: const TextStyle(height: 1.4))),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_result!.keyImprovements.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      'Key Improvements',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _result!.keyImprovements.map(
                        (imp) => Chip(
                          label: Text(imp, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          avatar: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
                        ),
                      ).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
