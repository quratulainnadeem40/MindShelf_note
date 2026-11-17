import 'package:flutter/material.dart';
import 'package:mindshelf_note/services/note_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindshelf_note/theme/color_app.dart';

import '../models/note_model.dart';
import '../services/local_storage_service.dart' hide NoteServices;
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
  final TextEditingController _searchController = TextEditingController();

  List<NoteModel> _notes = [];

  bool _isLoading = true;
  bool _isSearching = false;

  String _searchQuery = '';
  String _sortOrder = 'Last Edited';
  String _layout = 'List';

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _mainTextColor =>
      _isDark ? AppColors.darkText : AppColors.lightText;

  Color get _secondaryTextColor =>
      _isDark
          ? AppColors.darkSecondaryText
          : AppColors.lightSecondaryText;

  Color get _primaryColor =>
      _isDark ? AppColors.darkPrimary : AppColors.primary;

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
        _sortOrder = prefs.getString('notes_sort_order') ?? 'Last Edited';
        _layout = prefs.getString('notes_layout') ?? 'List';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load notes: $e')),
      );
    }
  }

  List<NoteModel> get _sortedNotes {
    final notes = _notes.where((note) {
      final query = _searchQuery.toLowerCase();

      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.category.toLowerCase().contains(query);
    }).toList();

    switch (_sortOrder) {
      case 'Date Created':
        notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
        notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }

    return notes;
  }

  List<NoteModel> get _pinnedNotes {
    return _sortedNotes.where((note) => note.isPinned).toList();
  }

  List<NoteModel> get _regularNotes {
    return _sortedNotes.where((note) => !note.isPinned).toList();
  }

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

  Future<void> _showSortOptions() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort Notes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...[
                'Last Edited',
                'Date Created',
                'Alphabetically',
              ].map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _sortOrder,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    Navigator.pop(context, value);
                  },
                );
              }),
            ],
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

  Future<void> _toggleLayout() async {
    final newLayout = _layout == 'List' ? 'Grid' : 'List';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes_layout', newLayout);

    if (!mounted) return;

    setState(() {
      _layout = newLayout;
    });
  }

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

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    final yesterday = now.subtract(const Duration(days: 1));

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  Color _noteColor(NoteModel note) {
    return Color(note.colorValue);
  }

  Future<void> _toggleNotePin(NoteModel note) async {
    final newValue = !note.isPinned;

    await _noteService.setPinStatus(note.id, newValue);

    if (!mounted) return;

    await _loadHomeData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newValue ? 'Note pinned successfully' : 'Note unpinned successfully',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _toggleNoteFavorite(NoteModel note) async {
    final newValue = !note.isFavorite;

    await _noteService.setFavoriteStatus(note.id, newValue);

    if (!mounted) return;

    await _loadHomeData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newValue ? 'Added to Favorites' : 'Removed from Favorites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    final noteColor = _noteColor(note);

    return GestureDetector(
      onTap: () => _openNote(note: note),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: noteColor.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: noteColor.withValues(alpha: 0.65),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title.isEmpty ? 'Untitled Note' : note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _mainTextColor,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                  tooltip: note.isPinned ? 'Unpin Note' : 'Pin Note',
                  onPressed: () => _toggleNotePin(note),
                  icon: Icon(
                    note.isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    size: 20,
                    color: note.isPinned
                        ? _primaryColor
                        : _secondaryTextColor,
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleNoteFavorite(note),
                  tooltip: note.isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                  visualDensity: VisualDensity.standard,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  padding: const EdgeInsets.all(12),
                  splashRadius: 25,
                  icon: Icon(
                    note.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 21,
                    color: note.isFavorite
                        ? _primaryColor
                        : _secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              note.content.isEmpty ? 'No additional text' : note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: _secondaryTextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 15,
                  color: _secondaryTextColor,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    note.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: _secondaryTextColor,
                    ),
                  ),
                ),
                Text(
                  _formatDate(note.updatedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: _secondaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesLayout(List<NoteModel> notes) {
    if (notes.isEmpty) {
      return _buildEmptyState(
        'No notes here',
        'Create a note to get started.',
      );
    }

    if (_layout == 'Grid') {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 0,
          childAspectRatio: 1.12,
        ),
        itemBuilder: (context, index) {
          return _buildNoteCard(notes[index]);
        },
      );
    }

    return Column(
      children: notes.map(_buildNoteCard).toList(),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 42,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _mainTextColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                color: _secondaryTextColor,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedSection() {
    if (_pinnedNotes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.push_pin_rounded,
              size: 18,
              color: _primaryColor,
            ),
            const SizedBox(width: 7),
            Text(
              'Pinned Notes',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _mainTextColor,
              ),
            ),
            const Spacer(),
            Text(
              '${_pinnedNotes.length}',
              style: TextStyle(
                color: _secondaryTextColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildNotesLayout(_pinnedNotes),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MindShelf',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${_notes.length} Notes  •  ${_notes.where((n) => n.isPinned).length} Pinned',
                style: TextStyle(
                  color: _secondaryTextColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _startSearch,
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search notes',
        ),
        IconButton(
          onPressed: _openSettings,
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    if (!_isSearching) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search notes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: _closeSearch,
            icon: const Icon(Icons.close),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesToolbar() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'All Notes',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: _mainTextColor,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _showSortOptions,
          icon: const Icon(Icons.sort_rounded, size: 19),
          label: Text(_sortOrder),
        ),
        IconButton(
          onPressed: _toggleLayout,
          tooltip: 'Change layout',
          icon: Icon(
            _layout == 'List'
                ? Icons.grid_view_rounded
                : Icons.view_agenda_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 'Home', true, () {}),
          _navItem(
            Icons.folder_open_outlined,
            'Categories',
            false,
            _openCategories,
          ),
          _navItem(
            Icons.favorite_border_rounded,
            'Favorites',
            false,
            _openFavorites,
          ),
          _navItem(
            Icons.settings_outlined,
            'Settings',
            false,
            _openSettings,
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final color = selected ? AppColors.primary : Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final regularNotes = _regularNotes;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadHomeData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildSearchBar(),
                      const SizedBox(height: 25),
                      if (_searchQuery.isEmpty) _buildPinnedSection(),
                      _buildNotesToolbar(),
                      const SizedBox(height: 12),
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
                        _buildNotesLayout(regularNotes),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNote(),
        tooltip: 'Create Note',
        heroTag: 'home_add_note_button',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 6,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: const Icon(
          Icons.add_rounded,
          size: 30,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}