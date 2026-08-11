import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_response.dart';
import '../providers/ai_provider.dart';
import '../widgets/ai_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/diff_view.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/primary_button.dart';
import '../widgets/result_card.dart';

class GrammarScreen extends ConsumerStatefulWidget {
  const GrammarScreen({super.key});

  @override
  ConsumerState<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends ConsumerState<GrammarScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;
  GrammarResult? _result;
  String? _errorMessage;

  static const String _sampleText =
      "He go to school yesterday and he don't brought his books because he forget them at home.";

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _checkGrammar() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or paste text to check grammar.'),
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
      final res = await aiService.correctGrammar(text);
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
            controller: _inputController,
            labelText: 'Original Text to Fix',
            hintText: 'Type or paste text to check grammar & spelling...',
            maxLines: 6,
            minLines: 4,
            sampleText: _sampleText,
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            text: 'Check Grammar & Spelling',
            icon: Icons.spellcheck_rounded,
            isLoading: _isLoading,
            onPressed: _checkGrammar,
          ),
          const SizedBox(height: 24),
          if (_isLoading) ...[
            const LoadingIndicator(message: 'Analyzing grammar & syntax...'),
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
              title: 'Corrected Text & Changes',
              subtitle: 'Red strikethrough = removed, Green = added',
              copyableText: _result!.correctedText,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DiffView(diffs: _result!.diffs),
                  const SizedBox(height: 18),
                  Text(
                    'Explanation & Improvements',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _result!.explanation,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
