import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/app_settings.dart';
import '../providers/settings_provider.dart';
import '../widgets/ai_card.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _geminiKeyController;
  late TextEditingController _openrouterKeyController;
  late TextEditingController _customApiKeyController;
  late TextEditingController _customEndpointController;

  final List<String> _baseGeminiModels = [
    'gemini-3.6-flash',
    'gemini-3.5-flash',
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
    'gemini-2.5-flash',
    'gemini-2.0-flash-exp',
    'gemini-1.5-flash',
    'gemini-1.5-pro',
  ];

  final List<String> _baseOpenRouterModels = [
    'openrouter/free',
    'openrouter/auto',
    'google/gemma-4-26b-a4b-it:free',
    'openai/gpt-oss-20b:free',
    'google/gemma-4-31b-it:free',
    'nvidia/nemotron-3-ultra-550b-a55b:free',
    'nvidia/nemotron-3-super-120b-a12b:free',
    'cohere/north-mini-code:free',
    'google/gemini-2.5-flash',
    'google/gemini-2.0-flash-exp:free',
    'meta-llama/llama-3.3-70b-instruct:free',
    'deepseek/deepseek-r1:free',
    'qwen/qwen-2.5-72b-instruct:free',
    'mistralai/mistral-7b-instruct:free',
    'openai/gpt-4o-mini',
  ];

  final List<String> _fontFamilies = [
    'Inter',
    'Poppins',
    'Roboto',
    'Outfit',
    'Lora',
  ];

  final List<int> _presetAccentColors = [
    0xFF6366F1, // Indigo
    0xFF8B5CF6, // Purple
    0xFFEC4899, // Pink
    0xFF10B981, // Emerald
    0xFFF59E0B, // Amber
    0xFF06B6D4, // Cyan
    0xFF3B82F6, // Blue
    0xFFEF4444, // Red
  ];

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _geminiKeyController = TextEditingController(text: settings.geminiApiKey);
    _openrouterKeyController =
        TextEditingController(text: settings.openrouterApiKey);
    _customApiKeyController =
        TextEditingController(text: settings.customApiKey);
    _customEndpointController =
        TextEditingController(text: settings.customApiEndpoint);
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    _openrouterKeyController.dispose();
    _customApiKeyController.dispose();
    _customEndpointController.dispose();
    super.dispose();
  }

  List<String> _getAvailableModels(AppSettings settings) {
    List<String> baseList;
    if (settings.provider == AIProviderType.gemini) {
      baseList = List.from(_baseGeminiModels);
    } else if (settings.provider == AIProviderType.openrouter) {
      baseList = List.from(_baseOpenRouterModels);
    } else {
      baseList = ['gpt-4o-mini', 'gpt-4o', 'claude-3-5-sonnet', 'llama3'];
    }

    // Add user custom models
    for (final custom in settings.userCustomModels) {
      if (!baseList.contains(custom)) {
        baseList.add(custom);
      }
    }

    // Filter out hidden models
    return baseList.where((m) => !settings.hiddenModels.contains(m)).toList();
  }

  void _showAddCustomModelModal(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, color: Colors.indigo),
              SizedBox(width: 10),
              Text('Add Custom Model'),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. meta-llama/llama-3-70b',
              labelText: 'Model Identifier',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final modelStr = controller.text.trim();
                if (modelStr.isNotEmpty) {
                  ref.read(settingsProvider.notifier).addCustomModel(modelStr);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added model "$modelStr" to your list.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Add Model'),
            ),
          ],
        );
      },
    );
  }

  void _showManageModelsModal(BuildContext context, AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final currentSettings = ref.watch(settingsProvider);
            final available = _getAvailableModels(currentSettings);

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.tune_rounded, color: Colors.indigo),
                  SizedBox(width: 10),
                  Text('Manage Model List'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: available.isEmpty
                    ? const Center(child: Text('No models in list.'))
                    : ListView.builder(
                        itemCount: available.length,
                        itemBuilder: (context, idx) {
                          final m = available[idx];
                          return ListTile(
                            dense: true,
                            title: Text(m,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.redAccent, size: 20),
                              tooltip: 'Remove model from list',
                              onPressed: () {
                                ref
                                    .read(settingsProvider.notifier)
                                    .removeModel(m);
                              },
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showColorPickerModal(BuildContext context, int currentColorValue) {
    Color selected = Color(currentColorValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick Accent Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selected,
              availableColors:
                  _presetAccentColors.map((c) => Color(c)).toList(),
              onColorChanged: (color) {
                ref
                    .read(settingsProvider.notifier)
                    .updateAccentColor(color.toARGB32());
                Navigator.of(context).pop();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    final availableModels = _getAvailableModels(settings);
    final currentActiveModel = settings.activeModel;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: AI Provider & API Settings
          _buildSectionHeader('AI Provider & Integration'),

          AICard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Provider Selection',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildProviderChoiceChip(
                      type: AIProviderType.gemini,
                      label: 'Gemini API',
                      icon: Icons.auto_awesome_rounded,
                      current: settings.provider,
                      onSelect: () =>
                          notifier.updateProvider(AIProviderType.gemini),
                    ),
                    _buildProviderChoiceChip(
                      type: AIProviderType.openrouter,
                      label: 'OpenRouter API',
                      icon: Icons.hub_rounded,
                      current: settings.provider,
                      onSelect: () =>
                          notifier.updateProvider(AIProviderType.openrouter),
                    ),
                    _buildProviderChoiceChip(
                      type: AIProviderType.customApi,
                      label: 'Custom / OpenAI API',
                      icon: Icons.api_rounded,
                      current: settings.provider,
                      onSelect: () =>
                          notifier.updateProvider(AIProviderType.customApi),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // API Key / Endpoint Fields based on Provider
                if (settings.provider == AIProviderType.gemini) ...[
                  _buildApiKeyField(
                    controller: _geminiKeyController,
                    label: 'Gemini API Key',
                    hint: 'Paste Google Gemini API Key...',
                    onSave: (val) => notifier.updateGeminiKey(val),
                  ),
                ] else if (settings.provider == AIProviderType.openrouter) ...[
                  _buildApiKeyField(
                    controller: _openrouterKeyController,
                    label: 'OpenRouter API Key',
                    hint: 'Paste OpenRouter API Key...',
                    onSave: (val) => notifier.updateOpenRouterKey(val),
                  ),
                ] else ...[
                  // Custom Endpoint Fields
                  Text(
                    'Custom API Base Endpoint URL',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _customEndpointController,
                    decoration: const InputDecoration(
                      hintText: 'https://api.openai.com/v1/chat/completions',
                      prefixIcon: Icon(Icons.link_rounded, size: 20),
                    ),
                    onChanged: (val) =>
                        notifier.updateCustomApiEndpoint(val.trim()),
                  ),
                  const SizedBox(height: 12),
                  _buildApiKeyField(
                    controller: _customApiKeyController,
                    label: 'Custom API Key (Optional)',
                    hint: 'Bearer token or API key if required...',
                    onSave: (val) => notifier.updateCustomApiKey(val),
                  ),
                ],
                const SizedBox(height: 16),

                // Model Selector with Add & Remove options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Model',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.tune_rounded, size: 16),
                      label: const Text('Manage List',
                          style: TextStyle(fontSize: 12)),
                      onPressed: () =>
                          _showManageModelsModal(context, settings),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: availableModels.contains(currentActiveModel)
                          ? currentActiveModel
                          : (availableModels.isNotEmpty
                              ? availableModels.first
                              : null),
                      items: [
                        ...availableModels.map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(m),
                          ),
                        ),
                        const DropdownMenuItem(
                          value: '__ADD_NEW_CUSTOM__',
                          child: Row(
                            children: [
                              Icon(Icons.add_circle_outline_rounded,
                                  size: 18, color: Colors.indigo),
                              SizedBox(width: 8),
                              Text('+ Add Custom Model...',
                                  style: TextStyle(
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          if (val == '__ADD_NEW_CUSTOM__') {
                            _showAddCustomModelModal(context);
                          } else {
                            if (settings.provider == AIProviderType.gemini) {
                              notifier.updateGeminiModel(val);
                            } else if (settings.provider ==
                                AIProviderType.openrouter) {
                              notifier.updateOpenRouterModel(val);
                            } else {
                              notifier.updateCustomApiModel(val);
                            }
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 2: App Launch Preferences
          _buildSectionHeader('Launch Preference'),

          AICard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Default Screen on App Launch',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: settings.defaultLaunchScreen,
                      items: const [
                        DropdownMenuItem(
                            value: 'home', child: Text('Home Dashboard')),
                        DropdownMenuItem(
                            value: 'grammar',
                            child: Text('Grammar Correction')),
                        DropdownMenuItem(
                            value: 'sentence',
                            child: Text('Sentence Correction')),
                        DropdownMenuItem(
                            value: 'draft', child: Text('Draft Writer')),
                        DropdownMenuItem(
                            value: 'dictionary',
                            child: Text('Word Dictionary')),
                        DropdownMenuItem(
                            value: 'synonyms',
                            child: Text('Synonyms & Antonyms')),
                        DropdownMenuItem(
                            value: 'sentence_maker',
                            child: Text('Sentence Maker')),
                      ],
                      onChanged: (val) {
                        if (val != null) notifier.updateDefaultScreen(val);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 3: Appearance & Typography
          _buildSectionHeader('Appearance & Typography'),

          SettingsTile(
            icon: Icons.palette_rounded,
            title: 'Accent Color',
            subtitle: 'Customize primary theme color',
            trailing: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(settings.accentColorValue),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(blurRadius: 4, color: Colors.black26)
                ],
              ),
            ),
            onTap: () =>
                _showColorPickerModal(context, settings.accentColorValue),
          ),

          SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: 'Theme Mode',
            subtitle: settings.themeMode.name.toUpperCase(),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: settings.themeMode.name,
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('System')),
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                ],
                onChanged: (val) {
                  if (val != null) notifier.updateThemeMode(val);
                },
              ),
            ),
          ),

          SettingsTile(
            icon: Icons.font_download_rounded,
            title: 'Font Family',
            subtitle: settings.fontFamily,
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: settings.fontFamily,
                items: _fontFamilies
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) notifier.updateFontFamily(val);
                },
              ),
            ),
          ),

          AICard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Text Size Scaling',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(settings.fontSizeScale * 100).toInt()}%',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: settings.fontSizeScale,
                  min: 0.8,
                  max: 1.3,
                  divisions: 10,
                  label: '${(settings.fontSizeScale * 100).toInt()}%',
                  onChanged: (val) => notifier.updateFontSizeScale(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 4: About & Developer Credits
          _buildSectionHeader('About & Credits'),

          AICard(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.verified_user_rounded,
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FluentAI Assistant',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Version 1.0.0',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Created & Developed by',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.textTheme.bodyMedium?.color?.withAlpha(180),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'NetAnkur',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'FluentAI is an AI-powered writing companion designed to streamline grammar, rephrasing, draft composition & vocabulary mastery.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildProviderChoiceChip({
    required AIProviderType type,
    required String label,
    required IconData icon,
    required AIProviderType current,
    required VoidCallback onSelect,
  }) {
    final isSelected = current == type;
    final theme = Theme.of(context);

    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : theme.colorScheme.primary,
      ),
      label: Text(label),
      selected: isSelected,
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (val) {
        if (val) onSelect();
      },
    );
  }

  Widget _buildApiKeyField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ValueChanged<String> onSave,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: IconButton(
              icon: const Icon(Icons.save_rounded),
              tooltip: 'Save API Key',
              onPressed: () {
                onSave(controller.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('API Key saved locally.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
          onChanged: (val) => onSave(val.trim()),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
