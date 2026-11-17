
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mindshelf_note/models/note_model.dart';
import 'package:mindshelf_note/services/local_storage_service.dart';
import 'package:mindshelf_note/services/note_service.dart' hide NoteServices;
import 'package:mindshelf_note/theme/color_app.dart';

import 'home_screen.dart';
import 'note_editor_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final NoteServices _noteService = NoteServices();

  List<NoteModel> _favoriteNotes = [];
  bool _isLoading = true;

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _primaryColor =>
      _isDark ? AppColors.darkPrimary : AppColors.primary;

  Color get _primaryDark =>
      _isDark ? AppColors.darkPrimary : AppColors.primaryDark;

  Color get _illustrationBackground =>
      _isDark
          ? AppColors.darkPink
          : AppColors.lightCard;

  Color get _illustrationAccent =>
      _isDark
          ? AppColors.darkPrimary.withValues(alpha: 0.45)
          : AppColors.accent.withValues(alpha: 0.55);

  Color get _illustrationHeart =>
      _isDark
          ? AppColors.darkPrimary
          : AppColors.primary;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final notes = await _noteService.getFavoriteNotes();

    if (!mounted) return;

    setState(() {
      _favoriteNotes = notes;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(NoteModel note) async {
    await _noteService.toggleFavorite(note.id);
    await _loadFavorites();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from Favorites'),
        duration: Duration(seconds: 1),
      ),
    );
  }

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

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final secondaryColor = _isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 12, 18, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: textColor,
                      size: 19,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.favorite_rounded,
                    color: _primaryColor,
                    size: 23,
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: _primaryColor,
                      ),
                    )
                  : _favoriteNotes.isEmpty
                      ? _emptyState(textColor, secondaryColor)
                      : _favoritesList(textColor, secondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _favoritesList(
    Color textColor,
    Color secondaryColor,
  ) {
    return RefreshIndicator(
      color: _primaryColor,
      onRefresh: _loadFavorites,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          Text(
            'Favorites',
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Your most important notes.',
            style: TextStyle(
              fontSize: 13,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            '${_favoriteNotes.length} Favorite Notes',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 13),

          ..._favoriteNotes.map(
            (note) => _favoriteCard(
              note,
              textColor,
              secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _favoriteCard(
    NoteModel note,
    Color textColor,
    Color secondaryColor,
  ) {
    final noteColor = Color(note.colorValue);

    final hasImage = note.imagePath != null &&
        File(note.imagePath!).existsSync();

    return InkWell(
      onTap: () => _openNote(note),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isDark
              ? AppColors.darkCard
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: _isDark
                ? AppColors.darkDivider
                : AppColors.lightDivider.withValues(alpha: 0.7),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(note.imagePath!),
                  width: double.infinity,
                  height: 155,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasImage)
                  Container(
                    width: 49,
                    height: 49,
                    decoration: BoxDecoration(
                      color: noteColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: _primaryColor,
                      size: 25,
                    ),
                  ),

                if (!hasImage) const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
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
                          color: secondaryColor,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // LARGER FAVORITE REMOVE TAP AREA
                IconButton(
                  onPressed: () => _removeFavorite(note),
                  tooltip: 'Remove from Favorites',
                  visualDensity: VisualDensity.standard,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  padding: const EdgeInsets.all(12),
                  icon: Icon(
                    Icons.favorite_rounded,
                    color: _primaryColor,
                    size: 23,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: noteColor.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    note.category,
                    style: TextStyle(
                      color: _primaryDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: secondaryColor,
                ),
                const SizedBox(width: 5),
                Text(
                  _formatDate(note.updatedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(
    Color textColor,
    Color secondaryColor,
  ) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // THEME BASED HEART ILLUSTRATION
            Container(
              width: 175,
              height: 175,
              decoration: BoxDecoration(
                color: _illustrationBackground,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withValues(alpha: 0.12),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 29,
                    left: 35,
                    child: Icon(
                      Icons.auto_awesome,
                      color: _illustrationAccent,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    right: 29,
                    top: 45,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: _illustrationAccent,
                      size: 19,
                    ),
                  ),
                  Icon(
                    Icons.favorite_rounded,
                    size: 92,
                    color: _illustrationHeart,
                  ),
                  Positioned(
                    bottom: 33,
                    right: 34,
                    child: Icon(
                      Icons.auto_awesome,
                      color: _illustrationAccent,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 29),

            Text(
              'No more favorites!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Mark your important notes as favorite '
              'and they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: secondaryColor,
              ),
            ),

            const SizedBox(height: 22),

            // THEME BASED ADD FAVORITE BUTTON
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: _isDark
                      ? AppColors.darkPink
                      : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: _primaryColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      color: _primaryColor,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Add your first favorite',
                      style: TextStyle(
                        color: _primaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
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
}
