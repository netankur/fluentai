import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_response.dart';
import '../providers/ai_provider.dart';
import '../widgets/ai_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/primary_button.dart';
import '../widgets/result_card.dart';

class SentenceMakerScreen extends ConsumerStatefulWidget {
  const SentenceMakerScreen({super.key});

  @override
  ConsumerState<SentenceMakerScreen> createState() => _SentenceMakerScreenState();
}

class _SentenceMakerScreenState extends ConsumerState<SentenceMakerScreen> {
  final TextEditingController _topicController = TextEditingController();
  bool _isLoading = false;
  SentenceMakerResult? _result;
  String? _errorMessage;

  static const String _sampleTopic = "Perseverance";

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateSentences() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a word or topic to generate sentences.'),
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
      final res = await aiService.makeSentences(topic);
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
            controller: _topicController,
            labelText: 'Word or Topic',
            hintText: 'Enter word or topic to generate sentences...',
            maxLines: 1,
            minLines: 1,
            sampleText: _sampleTopic,
            onSubmitted: _generateSentences,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Generate Example Sentences',
            icon: Icons.format_quote_rounded,
            isLoading: _isLoading,
            onPressed: _generateSentences,
          ),
          const SizedBox(height: 24),
          if (_isLoading) ...[
            const LoadingIndicator(message: 'Generating beginner to advanced sentences...'),
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
              title: _result!.topicOrWord,
              subtitle: 'Example sentences categorized by difficulty level',
              copyableText:
                  '${_result!.topicOrWord}\nBeginner:\n${_result!.beginnerSentences.join('\n')}\nIntermediate:\n${_result!.intermediateSentences.join('\n')}\nAdvanced:\n${_result!.advancedSentences.join('\n')}',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLevelSection(
                    context: context,
                    levelName: 'Beginner Level',
                    badgeColor: Colors.green,
                    sentences: _result!.beginnerSentences,
                  ),
                  const SizedBox(height: 18),
                  _buildLevelSection(
                    context: context,
                    levelName: 'Intermediate Level',
                    badgeColor: Colors.orange,
                    sentences: _result!.intermediateSentences,
                  ),
                  const SizedBox(height: 18),
                  _buildLevelSection(
                    context: context,
                    levelName: 'Advanced Level',
                    badgeColor: Colors.purple,
                    sentences: _result!.advancedSentences,
                  ),
                  if (_result!.usageTips.isNotEmpty) ...[
                    const Divider(height: 28),
                    Text(
                      'Usage & Grammar Note',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
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
                        _result!.usageTips,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
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

  Widget _buildLevelSection({
    required BuildContext context,
    required String levelName,
    required Color badgeColor,
    required List<String> sentences,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: badgeColor.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                levelName,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...sentences.map(
          (sent) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold)),
                Expanded(child: SelectableText(sent, style: const TextStyle(height: 1.4))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
