
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (note.isPinned)
                  const Icon(
                    Icons.push_pin_rounded,
                    size: 17,
                    color: Colors.black54,
                  ),
                if (note.isFavorite)
                  const Padding(
                    padding: EdgeInsets.only(left: 7),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 17,
                      color: Colors.redAccent,
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
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 15,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    note.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Text(
                  _formatDate(note.updatedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
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
            const Icon(
              Icons.push_pin_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 7),
            const Text(
              'Pinned Notes',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${_pinnedNotes.length}',
              style: TextStyle(
                color: Colors.grey.shade600,
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
                  color: Colors.grey.shade600,
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
        const Expanded(
          child: Text(
            'All Notes',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
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
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
