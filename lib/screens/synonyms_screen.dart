import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_response.dart';
import '../providers/ai_provider.dart';
import '../widgets/ai_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/primary_button.dart';
import '../widgets/result_card.dart';

class SynonymsScreen extends ConsumerStatefulWidget {
  const SynonymsScreen({super.key});

  @override
  ConsumerState<SynonymsScreen> createState() => _SynonymsScreenState();
}

class _SynonymsScreenState extends ConsumerState<SynonymsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  SynonymsResult? _result;
  String? _errorMessage;

  static const String _sampleWord = "Meticulous";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSynonyms([String? wordToSearch]) async {
    final word = (wordToSearch ?? _searchController.text).trim();
    if (wordToSearch != null) {
      _searchController.text = wordToSearch;
    }

    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a word to find synonyms & antonyms.'),
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
      final res = await aiService.fetchSynonymsAndAntonyms(word);
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
            controller: _searchController,
            labelText: 'Word Search',
            hintText: 'Enter a word to find synonyms & antonyms...',
            maxLines: 1,
            minLines: 1,
            sampleText: _sampleWord,
            onSubmitted: () => _fetchSynonyms(),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Find Synonyms & Antonyms',
            icon: Icons.style_rounded,
            isLoading: _isLoading,
            onPressed: () => _fetchSynonyms(),
          ),
          const SizedBox(height: 24),
          if (_isLoading) ...[
            const LoadingIndicator(message: 'Finding synonyms & antonyms...'),
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
              subtitle: 'Tap any chip below to search that word instantly!',
              copyableText:
                  '${_result!.word}\nSynonyms: ${_result!.synonyms.join(', ')}\nAntonyms: ${_result!.antonyms.join(', ')}',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Synonyms',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _result!.synonyms.map((syn) {
                      return ActionChip(
                        avatar: const Icon(Icons.search_rounded, size: 14, color: Colors.green),
                        label: Text(syn),
                        backgroundColor: Colors.green.withAlpha(20),
                        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onPressed: () => _fetchSynonyms(syn),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Antonyms',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _result!.antonyms.map((ant) {
                      return ActionChip(
                        avatar: const Icon(Icons.search_rounded, size: 14, color: Colors.redAccent),
                        label: Text(ant),
                        backgroundColor: Colors.red.withAlpha(20),
                        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onPressed: () => _fetchSynonyms(ant),
                      );
                    }).toList(),
                  ),
                  if (_result!.contextNote != null && _result!.contextNote!.isNotEmpty) ...[
                    const Divider(height: 28),
                    Text(
                      'Usage Nuance',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _result!.contextNote!,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
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
