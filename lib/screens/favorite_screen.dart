
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mindshelf_note/models/note_model.dart';
import 'package:mindshelf_note/services/local_storage_service.dart';
import 'package:mindshelf_note/services/note_service.dart' hide NoteServices;
import 'package:mindshelf_note/theme/color_app.dart';

import 'home_screen.dart';
import 'category_screen.dart';
import 'setting_screen.dart';
import 'note_editor_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // GOLD LUXE COLOR
  static const Color _gold = Color(0xFFE2B85F);
  static const Color _goldDark = Color(0xFF98753B);

  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkCard = Color(0xFF27282B);
  static const Color _darkNav = Color(0xFF242424);

  static const Color _lightText = Color(0xFFFFF9ED);
  static const Color _mutedText = Color(0xFFC5BDAF);

  final NoteServices _noteService = NoteServices();

  List<NoteModel> _favoriteNotes = [];

  bool _isLoading = true;

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _backgroundColor =>
      _isDark ? _darkBackground : const Color(0xFFF7F4ED);

  Color get _cardColor =>
      _isDark ? _darkCard : Colors.white;

  Color get _navColor =>
      _isDark ? _darkNav : Colors.white;

  Color get _textColor =>
      _isDark ? _lightText : const Color(0xFF25221D);

  Color get _secondaryColor =>
      _isDark ? _mutedText : const Color(0xFF77716A);

  Color get _borderColor =>
      _isDark ? const Color(0xFF383838) : const Color(0xFFE8E0D2);

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // =========================================
  // LOAD FAVORITES
  // =========================================

  Future<void> _loadFavorites() async {
    try {
      final notes = await _noteService.getFavoriteNotes();

      if (!mounted) return;

      setState(() {
        _favoriteNotes = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load favorites: $e'),
        ),
      );
    }
  }

  // =========================================
  // REMOVE FAVORITE
  // =========================================

  Future<void> _removeFavorite(NoteModel note) async {
    await _noteService.toggleFavorite(note.id);

    if (!mounted) return;

    await _loadFavorites();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from Favorites'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // =========================================
  // OPEN NOTE EDITOR
  // =========================================

  Future<void> _openNote(NoteModel note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(note: note),
      ),
    );

    if (!mounted) return;

    if (result == 'deleted' || result is NoteModel) {
      await _loadFavorites();
    }
  }

  // =========================================
  // FORMAT DATE
  // =========================================

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }

  // =========================================
  // NAVIGATION
  // =========================================

  void _navigateTo(int index) {
    if (index == 2) return;

    Widget screen;

    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;

      case 1:
        screen = const CategoriesScreen();
        break;

      case 3:
        screen = const SettingsScreen();
        break;

      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  // =========================================
  // HEADER
  // =========================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 5),
      child: Row(
        children: [
          // BACK BUTTON
          Material(
            color: _cardColor,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  ),
                  (route) => false,
                );
              },
              child: SizedBox(
                width: 43,
                height: 43,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: _gold,
                  size: 23,
                ),
              ),
            ),
          ),

          const Spacer(),

          // FAVORITE ICON
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _cardColor,
              border: Border.all(
                color: _gold.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: _gold,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================
  // FAVORITES LIST
  // =========================================

  Widget _favoritesList() {
    return RefreshIndicator(
      color: _gold,
      onRefresh: _loadFavorites,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
        children: [
          // TITLE
          Text(
            'Favorites',
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              color: _textColor,
            ),
          ),

          const SizedBox(height: 5),

          // SUBTITLE
          Text(
            'Your most important notes.',
            style: TextStyle(
              fontSize: 13,
              color: _secondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // GOLD UNDERLINE
          Container(
            width: 48,
            height: 3,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 23),

          // FAVORITE COUNT
          Text(
            '${_favoriteNotes.length} Favorite Notes',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _gold,
            ),
          ),

          const SizedBox(height: 14),

          // FAVORITE CARDS
          ..._favoriteNotes.map(
            (note) => _favoriteCard(note),
          ),
        ],
      ),
    );
  }

  // =========================================
  // FAVORITE NOTE CARD
  // =========================================

  Widget _favoriteCard(NoteModel note) {
    final noteColor = Color(note.colorValue);

    final hasImage = note.imagePath != null &&
        File(note.imagePath!).existsSync();

    return Material(
      color: _cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => _openNote(note),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _borderColor.withValues(alpha: 0.45),
              width: 0.7,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE PREVIEW
              if (hasImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(note.imagePath!),
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // NOTE DETAILS
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!hasImage)
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _gold,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF352817),
                        size: 23,
                      ),
                    ),

                  if (!hasImage)
                    const SizedBox(width: 9),

                  // TITLE AND DESCRIPTION
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          note.content.isEmpty
                              ? 'No description'
                              : note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _secondaryColor,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // REMOVE FAVORITE
                  IconButton(
                    onPressed: () => _removeFavorite(note),
                    tooltip: 'Remove from Favorites',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    padding: const EdgeInsets.all(10),
                    icon: const Icon(
                      Icons.favorite_rounded,
                      color: _gold,
                      size: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // CATEGORY AND DATE
              Row(
                children: [
                  // CATEGORY CHIP
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _gold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      note.category,
                      style: const TextStyle(
                        color: Color(0xFF352817),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // DATE ICON
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: _gold,
                  ),

                  const SizedBox(width: 5),

                  // DATE
                  Text(
                    _formatDate(note.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: _secondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================
  // EMPTY FAVORITES STATE
  // =========================================

  Widget _emptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // HEART ILLUSTRATION
            Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                color: _cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _gold.withValues(alpha: 0.10),
                    blurRadius: 25,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned(
                    top: 25,
                    left: 30,
                    child: Icon(
                      Icons.auto_awesome,
                      color: _gold,
                      size: 22,
                    ),
                  ),

                  Positioned(
                    right: 25,
                    top: 40,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: _gold.withValues(alpha: 0.5),
                      size: 18,
                    ),
                  ),

                  const Icon(
                    Icons.favorite_rounded,
                    size: 80,
                    color: _gold,
                  ),

                  Positioned(
                    bottom: 25,
                    right: 30,
                    child: Icon(
                      Icons.auto_awesome,
                      color: _gold.withValues(alpha: 0.6),
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 27),

            // EMPTY TITLE
            Text(
              'No more favorites!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: _textColor,
              ),
            ),

            const SizedBox(height: 10),

            // EMPTY DESCRIPTION
            Text(
              'Mark your important notes as favorite '
              'and they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: _secondaryColor,
              ),
            ),

            const SizedBox(height: 22),

            // ADD FAVORITE BUTTON
            InkWell(
              onTap: () => _navigateTo(0),
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: _gold.withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      color: _gold,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Add your first favorite',
                      style: TextStyle(
                        color: _gold,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================
  // BOTTOM NAVIGATION
  // =========================================

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      top: false,
      child: Container(
        height: 65,
        margin: const EdgeInsets.fromLTRB(18, 5, 18, 10),
        decoration: BoxDecoration(
          color: _navColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _borderColor.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            _navItem(
              icon: Icons.home_rounded,
              label: 'Home',
              index: 0,
            ),

            _navItem(
              icon: Icons.grid_view_rounded,
              label: 'Categories',
              index: 1,
            ),

            _navItem(
              icon: Icons.favorite_rounded,
              label: 'Favorites',
              index: 2,
            ),

            _navItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  // NAV ITEM WITHOUT DOT INDICATOR
  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = index == 2;

    return Expanded(
      child: InkWell(
        onTap: () => _navigateTo(index),
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected
                    ? _gold
                    : _isDark
                        ? Colors.white54
                        : Colors.grey.shade600,
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
                  color: selected
                      ? _gold
                      : _isDark
                          ? Colors.white54
                          : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================
  // MAIN BUILD
  // =========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            _buildHeader(),

            // MAIN CONTENT
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: _gold,
                      ),
                    )
                  : _favoriteNotes.isEmpty
                      ? _emptyState()
                      : _favoritesList(),
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
