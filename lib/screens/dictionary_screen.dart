import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_response.dart';
import '../providers/ai_provider.dart';
import '../services/tts_service.dart';
import '../widgets/ai_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/primary_button.dart';
import '../widgets/result_card.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isPlayingAudio = false;
  DictionaryResult? _result;
  String? _errorMessage;

  static const String _sampleWord = "Eloquence";

  @override
  void dispose() {
    _searchController.dispose();
    TTSService.stop();
    super.dispose();
  }

  Future<void> _speakWord(String text) async {
    setState(() => _isPlayingAudio = true);
    await TTSService.speak(text);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isPlayingAudio = false);
  }

  Future<void> _lookupWord() async {
    final word = _searchController.text.trim();
    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a word or phrase to lookup.'),
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
      final res = await aiService.lookupWord(word);
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
    final primary = theme.colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _searchController,
            labelText: 'Search Word or Phrase',
            hintText: 'Enter a word to lookup definitions & audio pronunciation...',
            maxLines: 1,
            minLines: 1,
            sampleText: _sampleWord,
            onSubmitted: _lookupWord,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Lookup Dictionary',
            icon: Icons.search_rounded,
            isLoading: _isLoading,
            onPressed: _lookupWord,
          ),
          const SizedBox(height: 24),
          if (_isLoading) ...[
            const LoadingIndicator(message: 'Searching dictionary & phonetics...'),
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
              title: _result!.word,
              subtitle: _result!.pronunciation.isNotEmpty ? _result!.pronunciation : null,
              copyableText:
                  '${_result!.word} (${_result!.partOfSpeech})\nDefinitions:\n${_result!.definitions.join('\n')}',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _result!.partOfSpeech,
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (_result!.pronunciation.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Text(
                          _result!.pronunciation,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: primary,
                          ),
                        ),
                      ],
                      const Spacer(),
                      // TTS Audio Pronounce Button
                      IconButton.filledTonal(
                        icon: Icon(
                          _isPlayingAudio ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                          size: 22,
                          color: primary,
                        ),
                        tooltip: 'Listen to Pronunciation (TTS)',
                        onPressed: () => _speakWord(_result!.word),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Definitions',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._result!.definitions.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key + 1}. ',
                            style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                          ),
                          Expanded(child: SelectableText(entry.value, style: const TextStyle(height: 1.4))),
                        ],
                      ),
                    ),
                  ),
                  if (_result!.exampleSentences.isNotEmpty) ...[
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Example Sentences',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tap 🔊 to listen',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._result!.exampleSentences.map(
                      (ex) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withAlpha(10)
                              : Colors.black.withAlpha(6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                '"$ex"',
                                style: const TextStyle(fontStyle: FontStyle.italic, height: 1.4),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.volume_up_rounded, size: 18, color: primary),
                              tooltip: 'Read sentence aloud',
                              onPressed: () => _speakWord(ex),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_result!.originNote != null && _result!.originNote!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Etymology & Note: ${_result!.originNote}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(160),
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
}
