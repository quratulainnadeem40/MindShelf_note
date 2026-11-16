
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mindshelf_note/models/note_model.dart';
import 'package:mindshelf_note/services/local_storage_service.dart';
import 'package:mindshelf_note/services/note_service.dart' hide NoteServices;
import 'package:mindshelf_note/theme/color_app.dart';

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

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

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
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: textColor,
                      size: 19,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primary,
                    size: 23,
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
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
      color: AppColors.primary,
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
              color: AppColors.primary,
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
                    child: const Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
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

                IconButton(
                  onPressed: () => _removeFavorite(note),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primary,
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
                    style: const TextStyle(
                      color: AppColors.primaryDark,
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
            // HEART ILLUSTRATION
            Container(
              width: 175,
              height: 175,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE9ED),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE7A6B4)
                        .withValues(alpha: 0.2),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned(
                    top: 29,
                    left: 35,
                    child: Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFE7A6B4),
                      size: 24,
                    ),
                  ),
                  const Positioned(
                    right: 29,
                    top: 45,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFF2B9C5),
                      size: 19,
                    ),
                  ),
                  const Icon(
                    Icons.favorite_rounded,
                    size: 92,
                    color: Color(0xFFB34C60),
                  ),
                  const Positioned(
                    bottom: 33,
                    right: 34,
                    child: Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFE7A6B4),
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
                  color: const Color(0xFFFFE9ED),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      color: AppColors.primary,
                      size: 17,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Add your first favorite',
                      style: TextStyle(
                        color: AppColors.primaryDark,
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
