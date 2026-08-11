import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'grammar_screen.dart';
import 'sentence_correction_screen.dart';
import 'draft_writer_screen.dart';
import 'dictionary_screen.dart';
import 'synonyms_screen.dart';
import 'sentence_maker_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _selectedNavTab; // 0: Home, 1: Fix & Rephrase, 2: AI Writer, 3: Vocabulary, 4: Settings
  int _fixSubTab = 0; // 0: Grammar, 1: Sentence
  int _vocabSubTab = 0; // 0: Dictionary, 1: Synonyms, 2: Sentence Maker

  @override
  void initState() {
    super.initState();
    _mapInitialIndex(widget.initialIndex);
  }

  void _mapInitialIndex(int index) {
    switch (index) {
      case 0:
        _selectedNavTab = 0;
        break;
      case 1:
        _selectedNavTab = 1;
        _fixSubTab = 0;
        break;
      case 2:
        _selectedNavTab = 1;
        _fixSubTab = 1;
        break;
      case 3:
        _selectedNavTab = 2;
        break;
      case 4:
        _selectedNavTab = 3;
        _vocabSubTab = 0;
        break;
      case 5:
        _selectedNavTab = 3;
        _vocabSubTab = 1;
        break;
      case 6:
        _selectedNavTab = 3;
        _vocabSubTab = 2;
        break;
      case 7:
        _selectedNavTab = 4;
        break;
      default:
        _selectedNavTab = 0;
    }
  }

  void _onDirectNavigate(int flatIndex) {
    setState(() {
      _mapInitialIndex(flatIndex);
    });
  }

  Widget _buildBody() {
    switch (_selectedNavTab) {
      case 0:
        return HomeScreen(onNavigateToTab: _onDirectNavigate);
      case 1:
        return _buildFixAndRephraseHub();
      case 2:
        return const DraftWriterScreen();
      case 3:
        return _buildVocabHub();
      case 4:
        return const SettingsScreen();
      default:
        return HomeScreen(onNavigateToTab: _onDirectNavigate);
    }
  }

  Widget _buildFixAndRephraseHub() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: theme.scaffoldBackgroundColor,
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF131C2E)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSubTabButton(
                    title: 'Grammar',
                    icon: Icons.spellcheck_rounded,
                    isSelected: _fixSubTab == 0,
                    onTap: () => setState(() => _fixSubTab = 0),
                  ),
                ),
                Expanded(
                  child: _buildSubTabButton(
                    title: 'Rephrase Sentence',
                    icon: Icons.auto_fix_high_rounded,
                    isSelected: _fixSubTab == 1,
                    onTap: () => setState(() => _fixSubTab = 1),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(
              key: ValueKey<int>(_fixSubTab),
              child: _fixSubTab == 0 ? const GrammarScreen() : const SentenceCorrectionScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVocabHub() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: theme.scaffoldBackgroundColor,
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF131C2E)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSubTabButton(
                    title: 'Dictionary',
                    icon: Icons.menu_book_rounded,
                    isSelected: _vocabSubTab == 0,
                    onTap: () => setState(() => _vocabSubTab = 0),
                  ),
                ),
                Expanded(
                  child: _buildSubTabButton(
                    title: 'Synonyms',
                    icon: Icons.style_rounded,
                    isSelected: _vocabSubTab == 1,
                    onTap: () => setState(() => _vocabSubTab = 1),
                  ),
                ),
                Expanded(
                  child: _buildSubTabButton(
                    title: 'Sentences',
                    icon: Icons.format_quote_rounded,
                    isSelected: _vocabSubTab == 2,
                    onTap: () => setState(() => _vocabSubTab = 2),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(
              key: ValueKey<int>(_vocabSubTab),
              child: _vocabSubTab == 0
                  ? const DictionaryScreen()
                  : _vocabSubTab == 1
                      ? const SynonymsScreen()
                      : const SentenceMakerScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
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
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : theme.textTheme.bodyMedium?.color?.withAlpha(180),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedNavTab) {
      case 0:
        return 'FluentAI';
      case 1:
        return 'Fix & Rephrase';
      case 2:
        return 'AI Studio';
      case 3:
        return 'Vocabulary & Usage';
      case 4:
        return 'Settings';
      default:
        return 'FluentAI';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (_selectedNavTab != 4)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () => setState(() => _selectedNavTab = 4),
            ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        color: theme.colorScheme.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FluentAI',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Writing Studio',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  children: [
                    _buildDrawerItem(0, Icons.grid_view_rounded, 'Dashboard', () => _onDirectNavigate(0)),
                    _buildDrawerItem(1, Icons.spellcheck_rounded, 'Grammar Correction', () => _onDirectNavigate(1)),
                    _buildDrawerItem(2, Icons.auto_fix_high_rounded, 'Sentence Correction', () => _onDirectNavigate(2)),
                    _buildDrawerItem(3, Icons.history_edu_rounded, 'Draft & Reply Writer', () => _onDirectNavigate(3)),
                    _buildDrawerItem(4, Icons.menu_book_rounded, 'Word Dictionary', () => _onDirectNavigate(4)),
                    _buildDrawerItem(5, Icons.style_rounded, 'Synonyms & Antonyms', () => _onDirectNavigate(5)),
                    _buildDrawerItem(6, Icons.format_quote_rounded, 'Sentence Maker', () => _onDirectNavigate(6)),
                    const Divider(height: 20),
                    _buildDrawerItem(7, Icons.settings_rounded, 'Settings', () => _onDirectNavigate(7)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedNavTab),
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: _selectedNavTab == 4
          ? null
          : Container(
              margin: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                12 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131C2E) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 60 : 15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: NavigationBar(
                  selectedIndex: _selectedNavTab > 3 ? 0 : _selectedNavTab,
                  onDestinationSelected: (idx) {
                    setState(() {
                      _selectedNavTab = idx;
                    });
                  },
                  height: 64,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  indicatorColor: theme.colorScheme.primary.withAlpha(35),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_outlined, size: 22),
                      selectedIcon: Icon(Icons.grid_view_rounded, size: 22),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.spellcheck_outlined, size: 22),
                      selectedIcon: Icon(Icons.spellcheck_rounded, size: 22),
                      label: 'Fix',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.history_edu_outlined, size: 22),
                      selectedIcon: Icon(Icons.history_edu_rounded, size: 22),
                      label: 'Writer',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.menu_book_outlined, size: 22),
                      selectedIcon: Icon(Icons.menu_book_rounded, size: 22),
                      label: 'Vocab',
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDrawerItem(int flatIndex, IconData icon, String title, VoidCallback onTap) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, size: 22, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }
}
