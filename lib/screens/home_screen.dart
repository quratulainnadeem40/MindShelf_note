
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mindshelf_note/services/note_service.dart';
import 'package:mindshelf_note/theme/color_app.dart';

import '../models/note_model.dart';
import 'category_screen.dart';
import 'favorite_screen.dart';
import 'note_editor_screen.dart';
import 'setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteServices _noteService = NoteServices();
  final TextEditingController _searchController =
      TextEditingController();

  List<NoteModel> _notes = [];

  bool _isLoading = true;
  bool _isSearching = false;

  String _searchQuery = '';
  String _sortOrder = 'Last Edited';
  String _layout = 'List';

  static const Color _gold = Color(0xFFE2B85F);
  static const Color _darkBackground = Color(0xFF111111);
  static const Color _darkCard = Color(0xFF242424);

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _mainTextColor =>
      _isDark ? Colors.white : AppColors.lightText;

  Color get _secondaryTextColor =>
      _isDark
          ? const Color(0xFFB9B9B9)
          : AppColors.lightSecondaryText;

  Color get _accentColor => _gold;

  Color get _backgroundColor =>
      _isDark
          ? _darkBackground
          : Theme.of(context).scaffoldBackgroundColor;

  Color get _cardBackground =>
      _isDark
          ? _darkCard
          : Theme.of(context).cardColor;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // LOAD ACTUAL USER NOTES

  Future<void> _loadHomeData() async {
    try {
      final results = await Future.wait([
        _noteService.getNotes(),
        SharedPreferences.getInstance(),
      ]);

      final notes = results[0] as List<NoteModel>;
      final prefs = results[1] as SharedPreferences;

      if (!mounted) return;

      setState(() {
        _notes = notes;

        _sortOrder =
            prefs.getString('notes_sort_order') ?? 'Last Edited';

        _layout =
            prefs.getString('notes_layout') ?? 'List';

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load notes: $e'),
        ),
      );
    }
  }

  // SORT AND SEARCH NOTES

  List<NoteModel> get _sortedNotes {
    final notes = _notes.where((note) {
      final query = _searchQuery.toLowerCase().trim();

      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.category.toLowerCase().contains(query);
    }).toList();

    switch (_sortOrder) {
      case 'Date Created':
        notes.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
        break;

      case 'Alphabetically':
        notes.sort(
          (a, b) => a.title.toLowerCase().compareTo(
                b.title.toLowerCase(),
              ),
        );
        break;

      case 'Last Edited':
      default:
        notes.sort(
          (a, b) => b.updatedAt.compareTo(a.updatedAt),
        );
        break;
    }

    return notes;
  }

  List<NoteModel> get _pinnedNotes =>
      _sortedNotes.where((note) => note.isPinned).toList();

  List<NoteModel> get _regularNotes =>
      _sortedNotes.where((note) => !note.isPinned).toList();

  int get _totalPinned =>
      _notes.where((note) => note.isPinned).length;

  int get _totalFavorites =>
      _notes.where((note) => note.isFavorite).length;

  // OPEN SCREENS

  Future<void> _openNote({NoteModel? note}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(note: note),
      ),
    );

    if (!mounted) return;
    await _loadHomeData();
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );

    if (!mounted) return;
    await _loadHomeData();
  }

  Future<void> _openCategories() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CategoriesScreen(),
      ),
    );

    if (!mounted) return;
    await _loadHomeData();
  }

  Future<void> _openFavorites() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FavoritesScreen(),
      ),
    );

    if (!mounted) return;
    await _loadHomeData();
  }

  // PIN NOTE

  Future<void> _toggleNotePin(NoteModel note) async {
    final newValue = !note.isPinned;

    try {
      await _noteService.setPinStatus(note.id, newValue);

      if (!mounted) return;

      await _loadHomeData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? 'Note pinned successfully'
                : 'Note unpinned successfully',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update pin: $e')),
      );
    }
  }

  // FAVORITE NOTE

  Future<void> _toggleNoteFavorite(NoteModel note) async {
    final newValue = !note.isFavorite;

    try {
      await _noteService.setFavoriteStatus(
        note.id,
        newValue,
      );

      if (!mounted) return;

      await _loadHomeData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? 'Added to Favorites'
                : 'Removed from Favorites',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update favorite: $e')),
      );
    }
  }

  // DATE FORMAT

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    final yesterday = now.subtract(
      const Duration(days: 1),
    );

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  // SEARCH

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _closeSearch() {
    _searchController.clear();

    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
  }

  // SORT OPTIONS

  Future<void> _showSortOptions() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort Notes',
                  style: TextStyle(
                    color: _mainTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),

                ...[
                  'Last Edited',
                  'Date Created',
                  'Alphabetically',
                ].map((option) {
                  final isSelected = _sortOrder == option;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      option,
                      style: TextStyle(
                        color: _mainTextColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: _gold,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context, option);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('notes_sort_order', selected);

    if (!mounted) return;

    setState(() {
      _sortOrder = selected;
    });
  }

  // GRID / LIST

  Future<void> _toggleLayout() async {
    final newLayout =
        _layout == 'List' ? 'Grid' : 'List';

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('notes_layout', newLayout);

    if (!mounted) return;

    setState(() {
      _layout = newLayout;
    });
  }

  // HEADER

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ShelfNote',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: _mainTextColor,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '${_notes.length} Notes  •  $_totalPinned Pinned',
                style: const TextStyle(
                  color: _gold,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        _buildHeaderButton(
          icon: Icons.search_rounded,
          tooltip: 'Search Notes',
          onTap: _startSearch,
        ),

        const SizedBox(width: 10),

        _buildHeaderButton(
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          onTap: _openSettings,
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _cardBackground,
        border: Border.all(
          color: _isDark
              ? Colors.white.withValues(alpha: 0.13)
              : Colors.black12,
          width: 1,
        ),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(
          icon,
          color: _gold,
          size: 23,
        ),
      ),
    );
  }

  // SEARCH BAR

  Widget _buildSearchBar() {
    if (!_isSearching) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: TextStyle(color: _mainTextColor),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search title, content or category...',
          hintStyle: TextStyle(
            color: _secondaryTextColor,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _gold,
          ),
          suffixIcon: IconButton(
            onPressed: _closeSearch,
            icon: Icon(
              Icons.close_rounded,
              color: _secondaryTextColor,
            ),
          ),
          filled: true,
          fillColor: _cardBackground,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: _gold.withValues(alpha: 0.25),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: _gold,
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  // SECTION HEADING

  Widget _buildSectionHeading({
    required String title,
    required IconData icon,
    String? count,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: _gold,
          size: 22,
        ),
        const SizedBox(width: 10),

        Text(
          title,
          style: TextStyle(
            color: _mainTextColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        const Spacer(),

        if (count != null)
          Text(
            count,
            style: const TextStyle(
              color: _gold,
              fontSize: 15,
            ),
          ),
      ],
    );
  }

  // PINNED NOTES

  Widget _buildPinnedSection() {
    final pinned = _pinnedNotes;

    if (pinned.isEmpty || _searchQuery.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading(
          title: 'Pinned Notes',
          icon: Icons.push_pin_rounded,
          count: '${pinned.length}',
        ),

        const SizedBox(height: 16),

        ...pinned.map(
          (note) => _buildNoteCard(note),
        ),

        const SizedBox(height: 28),
      ],
    );
  }

  // NOTE CARD

  Widget _buildNoteCard(
    NoteModel note, {
    bool isGrid = false,
  }) {
    final noteColor = Color(note.colorValue);

    final cardColor = _isDark
        ? Color.lerp(
            _darkCard,
            noteColor,
            0.30,
          )!
        : Color.lerp(
            Theme.of(context).cardColor,
            noteColor,
            0.13,
          )!;

    return GestureDetector(
      onTap: () => _openNote(note: note),
      child: Container(
        margin: EdgeInsets.only(
          bottom: isGrid ? 0 : 12,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isGrid ? 12 : 16,
          vertical: isGrid ? 12 : 15,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: note.isPinned
                ? _gold
                : (_isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.07)),
            width: note.isPinned ? 1.3 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE AND ACTIONS

            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title.isEmpty
                        ? 'Untitled Note'
                        : note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _mainTextColor,
                      fontSize: isGrid ? 14 : 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                _buildNoteAction(
                  icon: note.isPinned
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  color: note.isPinned
                      ? _gold
                      : _secondaryTextColor,
                  tooltip: note.isPinned
                      ? 'Unpin Note'
                      : 'Pin Note',
                  onPressed: () => _toggleNotePin(note),
                  isGrid: isGrid,
                ),

                _buildNoteAction(
                  icon: note.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: note.isFavorite
                      ? _gold
                      : _secondaryTextColor,
                  tooltip: note.isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                  onPressed: () => _toggleNoteFavorite(note),
                  isGrid: isGrid,
                ),
              ],
            ),

            SizedBox(height: isGrid ? 9 : 12),

            // CONTENT

            Text(
              note.content.isEmpty
                  ? 'No additional text'
                  : note.content,
              maxLines: isGrid ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _isDark
                    ? const Color(0xFFE0DDD5)
                    : _secondaryTextColor,
                fontSize: isGrid ? 11 : 15,
                height: 1.45,
              ),
            ),

            SizedBox(height: isGrid ? 12 : 15),

            // CATEGORY AND DATE

            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: isGrid ? 14 : 18,
                  color: _isDark
                      ? const Color(0xFFD5C7A4)
                      : _secondaryTextColor,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    note.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _isDark
                          ? const Color(0xFFD5C7A4)
                          : _secondaryTextColor,
                      fontSize: isGrid ? 10 : 14,
                    ),
                  ),
                ),

                Text(
                  _formatDate(note.updatedAt),
                  style: TextStyle(
                    color: _secondaryTextColor,
                    fontSize: isGrid ? 10 : 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // NOTE ACTION BUTTON

  Widget _buildNoteAction({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
    bool isGrid = false,
  }) {
    return SizedBox(
      width: isGrid ? 26 : 34,
      height: isGrid ? 30 : 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: isGrid ? 16 : 22,
          color: color,
        ),
      ),
    );
  }

  // ALL NOTES TOOLBAR

  Widget _buildNotesToolbar() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'All Notes',
            style: TextStyle(
              color: _mainTextColor,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        // SORT BUTTON

        Material(
          color: _isDark
              ? const Color(0xFF342F25)
              : const Color(0xFFF1E7D1),
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: _showSortOptions,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    color: _gold,
                    size: 19,
                  ),

                  const SizedBox(width: 7),

                  Text(
                    _sortOrder,
                    style: const TextStyle(
                      color: _gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 6),

        IconButton(
          tooltip: _layout == 'List'
              ? 'Grid View'
              : 'List View',
          onPressed: _toggleLayout,
          icon: Icon(
            _layout == 'List'
                ? Icons.grid_view_rounded
                : Icons.view_agenda_outlined,
            color: _gold,
            size: 23,
          ),
        ),
      ],
    );
  }

  // NOTES LAYOUT

  Widget _buildNotesLayout(List<NoteModel> notes) {
    if (notes.isEmpty) {
      return _buildEmptyState(
        'No notes here',
        'Create a note to get started.',
      );
    }

    if (_layout == 'Grid') {
      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 600 ? 3 : 2;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notes.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 160,
            ),
            itemBuilder: (context, index) {
              return _buildNoteCard(
                notes[index],
                isGrid: true,
              );
            },
          );
        },
      );
    }

    return Column(
      children: notes.map((note) {
        return _buildNoteCard(note);
      }).toList(),
    );
  }

  // EMPTY STATE

  Widget _buildEmptyState(
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 38,
        horizontal: 12,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 48,
              color: _secondaryTextColor.withValues(
                alpha: 0.65,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _mainTextColor,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryTextColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTTOM NAVIGATION

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        height: 65,
        margin: const EdgeInsets.fromLTRB(18, 5, 18, 10),
        decoration: BoxDecoration(
          color: _isDark
              ? const Color(0xFF242424)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isDark
                ? const Color(0xFF383838).withValues(alpha: 0.4)
                : const Color(0xFFE8E0D2).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            _homeNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              index: 0,
            ),
            _homeNavItem(
              icon: Icons.grid_view_rounded,
              label: 'Categories',
              index: 1,
            ),
            _homeNavItem(
              icon: Icons.favorite_rounded,
              label: 'Favorites',
              index: 2,
            ),
            _homeNavItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  // NAV ITEM
  Widget _homeNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = index == 0;

    final unselectedColor = _isDark
        ? Colors.white54
        : Colors.grey.shade600;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 1) {
            _openCategories();
          } else if (index == 2) {
            _openFavorites();
          } else if (index == 3) {
            _openSettings();
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? _gold : unselectedColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected
                      ? FontWeight.w800
                      : FontWeight.w500,
                  color: selected ? _gold : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MAIN UI

  @override
  Widget build(BuildContext context) {
    final regularNotes = _regularNotes;

    return Scaffold(
      backgroundColor: _backgroundColor,

      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                color: _gold,
                onRefresh: _loadHomeData,
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    22,
                    18,
                    105,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // HEADER

                      _buildHeader(),

                      // SEARCH

                      _buildSearchBar(),

                      const SizedBox(height: 35),

                      // PINNED NOTES

                      if (_searchQuery.isEmpty)
                        _buildPinnedSection(),

                      // ALL NOTES TOOLBAR

                      _buildNotesToolbar(),

                      const SizedBox(height: 18),

                      // ALL NOTES

                      if (_sortedNotes.isEmpty)
                        _buildEmptyState(
                          _searchQuery.isEmpty
                              ? 'No notes yet'
                              : 'No matching notes',
                          _searchQuery.isEmpty
                              ? 'Tap the + button to create your first note.'
                              : 'Try searching with another word.',
                        )
                      else
                        _buildNotesLayout(
                          _searchQuery.isEmpty
                              ? regularNotes
                              : _sortedNotes,
                        ),
                    ],
                  ),
                ),
              ),
      ),

      // ADD NOTE BUTTON

      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNote(),
        heroTag: 'home_add_note_button',
        tooltip: 'Create Note',
        backgroundColor: _gold,
        foregroundColor: Colors.white,
        elevation: 5,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add_rounded,
          size: 34,
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,

      // BOTTOM NAVIGATION

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
