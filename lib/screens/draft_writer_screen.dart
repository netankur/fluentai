import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_response.dart';
import '../providers/ai_provider.dart';
import '../widgets/ai_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/primary_button.dart';
import '../widgets/result_card.dart';

class DraftWriterScreen extends ConsumerStatefulWidget {
  const DraftWriterScreen({super.key});

  @override
  ConsumerState<DraftWriterScreen> createState() => _DraftWriterScreenState();
}

class _DraftWriterScreenState extends ConsumerState<DraftWriterScreen> {
  int _modeIndex = 0; // 0 = New Draft, 1 = Reply Draft
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _replyToController = TextEditingController();

  String _selectedTone = 'Formal';
  final List<String> _tones = ['Formal', 'Casual', 'Persuasive', 'Professional', 'Friendly'];

  String _selectedType = 'Email';
  final List<String> _types = ['Email', 'Application', 'Letter', 'Essay', 'Message'];

  bool _isLoading = false;
  DraftResult? _result;
  String? _errorMessage;

  static const String _sampleNewDraftPrompt =
      "Requesting 3 days annual leave starting next Monday due to a family emergency.";

  static const String _sampleReplyMsg =
      "Hi Ankur, Are you available for a 30-minute technical interview next Tuesday at 3:00 PM EST?";
  static const String _sampleReplyIntent =
      "Confirm Tuesday 3 PM works great, ask for the video call link.";

  @override
  void dispose() {
    _promptController.dispose();
    _replyToController.dispose();
    super.dispose();
  }

  Future<void> _generateDraft() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _modeIndex == 0
                ? 'Please enter prompt details for your draft.'
                : 'Please enter what you want to reply.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_modeIndex == 1 && _replyToController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please paste the message you are replying to.'),
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
      final res = await aiService.generateDraft(
        prompt: prompt,
        tone: _selectedTone,
        type: _selectedType,
        replyToMessage: _modeIndex == 1 ? _replyToController.text.trim() : null,
      );
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
          // Mode Switcher (New Draft vs Reply Draft)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF131C2E)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildModeTab(
                    title: 'New Draft',
                    icon: Icons.note_add_rounded,
                    isSelected: _modeIndex == 0,
                    onTap: () {
                      setState(() {
                        _modeIndex = 0;
                        _result = null;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildModeTab(
                    title: 'Reply Draft',
                    icon: Icons.reply_rounded,
                    isSelected: _modeIndex == 1,
                    onTap: () {
                      setState(() {
                        _modeIndex = 1;
                        _result = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (_modeIndex == 1) ...[
            CustomTextField(
              controller: _replyToController,
              labelText: 'Received Message to Reply To',
              hintText: 'Paste the email or message you received...',
              maxLines: 4,
              minLines: 3,
              sampleText: _sampleReplyMsg,
            ),
            const SizedBox(height: 16),
          ],

          CustomTextField(
            controller: _promptController,
            labelText: _modeIndex == 0 ? 'Draft Prompt & Details' : 'Your Reply Intent',
            hintText: _modeIndex == 0
                ? 'What do you want to write? (e.g. Leave request, thank-you email)...'
                : 'What is your response intent? (e.g. Confirm Tuesday 3 PM works)...',
            maxLines: 4,
            minLines: 3,
            sampleText: _modeIndex == 0 ? _sampleNewDraftPrompt : _sampleReplyIntent,
          ),
          const SizedBox(height: 18),

          // Tone Selector
          Text(
            'Select Tone',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tones.map((tone) {
                final isSelected = _selectedTone == tone;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tone),
                    selected: isSelected,
                    selectedColor: primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedTone = tone);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Type Selector
          Text(
            'Format Type',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _types.map((type) {
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    selectedColor: primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedType = type);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 22),

          PrimaryButton(
            text: _modeIndex == 0 ? 'Generate Draft' : 'Generate Reply Draft',
            icon: Icons.history_edu_rounded,
            isLoading: _isLoading,
            onPressed: _generateDraft,
          ),
          const SizedBox(height: 24),

          if (_isLoading) ...[
            LoadingIndicator(
              message: _modeIndex == 0 ? 'Crafting your draft...' : 'Formulating reply draft...',
            ),
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
              title: _modeIndex == 0 ? 'Generated Draft' : 'Suggested Reply Draft',
              subtitle: 'Type: $_selectedType | Tone: $_selectedTone',
              copyableText: _result!.generatedDraft,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_result!.subjectLine != null && _result!.subjectLine!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: SelectableText.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Subject: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: _result!.subjectLine),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SelectableText(
                    _result!.generatedDraft,
                    style: const TextStyle(fontSize: 15, height: 1.6),
                  ),
                  if (_result!.keyPointsCovered.isNotEmpty) ...[
                    const Divider(height: 28),
                    Text(
                      'Key Points Included',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._result!.keyPointsCovered.map(
                      (kp) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(kp, style: theme.textTheme.bodySmall?.copyWith(fontSize: 13))),
                          ],
                        ),
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

  Widget _buildModeTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : theme.textTheme.bodyMedium?.color?.withAlpha(180),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : theme.textTheme.bodyMedium?.color?.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
