
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mindshelf_note/services/local_storage_service.dart';
import 'package:mindshelf_note/services/note_service.dart' hide NoteServices;

import '../models/note_model.dart';
import '../theme/color_app.dart';
import 'note_editor_screen.dart';

class _CategoryDialogResult {
  final String name;
  final String iconKey;

  const _CategoryDialogResult({
    required this.name,
    required this.iconKey,
  });
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final NoteServices _service = NoteServices();

  List<String> _categories = [];
  List<NoteModel> _notes = [];

  Map<String, String> _categoryIconKeys = {};
  Set<String> _pinnedCategories = {};

  bool _loading = true;

  static const String _pinnedKey = 'mindshelf_pinned_categories';

  final Map<String, IconData> _availableCategoryIcons = {
    'person': Icons.person_outline_rounded,
    'work': Icons.work_outline_rounded,
    'study': Icons.menu_book_rounded,
    'ideas': Icons.lightbulb_outline_rounded,
    'important': Icons.star_outline_rounded,
    'favorite': Icons.favorite_border_rounded,
    'home': Icons.home_outlined,
    'shopping': Icons.shopping_bag_outlined,
    'fitness': Icons.fitness_center_rounded,
    'food': Icons.restaurant_outlined,
    'travel': Icons.flight_outlined,
    'music': Icons.music_note_rounded,
    'gaming': Icons.sports_esports_rounded,
    'camera': Icons.camera_alt_outlined,
    'pets': Icons.pets_outlined,
    'school': Icons.school_outlined,
    'wallet': Icons.account_balance_wallet_outlined,
    'event': Icons.event_outlined,
    'code': Icons.code_rounded,
    'folder': Icons.folder_outlined,
  };

  // THEME COLORS

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _accentColor =>
      _isDark ? AppColors.darkPrimary : AppColors.primary;

  Color get _backgroundColor =>
      _isDark ? AppColors.darkBackground : AppColors.lightBackground;

  Color get _cardColor =>
      _isDark ? AppColors.darkCard : AppColors.lightSurface;

  Color get _textColor =>
      _isDark ? AppColors.darkText : AppColors.lightText;

  Color get _secondaryColor =>
      _isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

  Color get _borderColor =>
      _isDark ? AppColors.darkDivider : AppColors.lightDivider;

  Color get _iconBackground =>
      _isDark ? AppColors.darkPink : AppColors.lightPink;

  Color get _buttonColor =>
      _isDark ? AppColors.darkPrimary : AppColors.primary;

  Color get _buttonTextColor =>
      _isDark ? AppColors.darkBackground : AppColors.white;

  List<String> get _displayCategories {
    final result = [..._categories];

    result.sort((a, b) {
      final aPinned = _pinnedCategories.contains(a);
      final bPinned = _pinnedCategories.contains(b);

      if (aPinned == bPinned) return 0;

      return aPinned ? -1 : 1;
    });

    return result;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // LOAD DATA

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _service.getCategories(),
        _service.getNotes(),
        _service.getCategoryIcons(),
        SharedPreferences.getInstance(),
      ]);

      final categories = results[0] as List<String>;
      final notes = results[1] as List<NoteModel>;
      final icons = results[2] as Map<String, String>;
      final prefs = results[3] as SharedPreferences;

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _notes = notes;
        _categoryIconKeys = icons;
        _pinnedCategories =
            (prefs.getStringList(_pinnedKey) ?? []).toSet();
        _pinnedCategories.retainAll(categories);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load categories: $e'),
        ),
      );
    }
  }

  // CATEGORY NOTES COUNT

  int _countNotes(String category) {
    return _notes.where(
      (note) => note.category == category,
    ).length;
  }

  // CATEGORY ICON

  IconData _iconFor(String category) {
    final key = _categoryIconKeys[category];

    if (key != null &&
        _availableCategoryIcons.containsKey(key)) {
      return _availableCategoryIcons[key]!;
    }

    switch (category.toLowerCase()) {
      case 'personal':
        return Icons.person_outline_rounded;
      case 'work':
        return Icons.work_outline_rounded;
      case 'study':
      case 'education':
        return Icons.menu_book_rounded;
      case 'ideas':
        return Icons.lightbulb_outline_rounded;
      case 'important':
        return Icons.star_outline_rounded;
      case 'home':
        return Icons.home_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  // PIN / UNPIN

  Future<void> _toggleCategoryPin(String category) async {
    final prefs = await SharedPreferences.getInstance();

    final updated = {..._pinnedCategories};
    final isPinned = updated.contains(category);

    if (isPinned) {
      updated.remove(category);
    } else {
      updated.add(category);
    }

    await prefs.setStringList(
      _pinnedKey,
      updated.toList(),
    );

    if (!mounted) return;

    setState(() {
      _pinnedCategories = updated;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isPinned ? 'Category unpinned' : 'Category pinned',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ADD / RENAME CATEGORY

  Future<void> _showCategoryDialog({
    String? oldName,
  }) async {
    final controller = TextEditingController(
      text: oldName ?? '',
    );

    final isEditing = oldName != null;

    String selectedIconKey = isEditing
        ? (_categoryIconKeys[oldName] ?? 'folder')
        : 'folder';

    final result = await showDialog<_CategoryDialogResult>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _cardColor,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                isEditing ? 'Rename Category' : 'Add Category',
                style: TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Give your category a name and choose an icon.',
                      style: TextStyle(
                        color: _secondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 18),

                    TextField(
                      controller: controller,
                      autofocus: true,
                      maxLength: 25,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(color: _textColor),
                      decoration: InputDecoration(
                        hintText: 'Category name',
                        counterText: '',
                        filled: true,
                        fillColor: _backgroundColor,
                        hintStyle: TextStyle(color: _secondaryColor),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(color: _borderColor),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(
                            color: _accentColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 17),

                    Text(
                      'Choose Category Icon',
                      style: TextStyle(
                        color: _textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableCategoryIcons.entries.map(
                        (entry) {
                          final selected = selectedIconKey == entry.key;

                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedIconKey = entry.key;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 43,
                              height: 43,
                              decoration: BoxDecoration(
                                color: selected
                                    ? _accentColor.withValues(alpha: 0.16)
                                    : _iconBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? _accentColor
                                      : _borderColor,
                                  width: selected ? 1.5 : 0.8,
                                ),
                              ),
                              child: Icon(
                                entry.value,
                                color: _accentColor,
                                size: 21,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: _secondaryColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = controller.text.trim();

                    if (name.isEmpty) return;

                    Navigator.pop(
                      dialogContext,
                      _CategoryDialogResult(
                        name: name,
                        iconKey: selectedIconKey,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonColor,
                    foregroundColor: _buttonTextColor,
                  ),
                  child: Text(
                    isEditing ? 'Update' : 'Add Category',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (result == null || result.name.trim().isEmpty) return;

    final name = result.name.trim();

    final success = isEditing
        ? await _service.renameCategory(oldName, name)
        : await _service.addCategory(name);

    if (!mounted) return;

    if (success) {
      await _service.saveCategoryIcon(
        name,
        result.iconKey,
      );

      if (isEditing &&
          _pinnedCategories.contains(oldName)) {
        await _toggleCategoryPin(oldName);
        await _toggleCategoryPin(name);
      }

      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Category updated successfully'
                : 'Category added successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Category already exists or cannot be changed.',
          ),
        ),
      );
    }
  }

  // DELETE CATEGORY

  Future<void> _deleteCategory(String category) async {
    final noteCount = _countNotes(category);

    final remainingCategories = _categories
        .where((item) => item != category)
        .toList();

    final hasDestination = remainingCategories.isNotEmpty;

    final choice = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Delete Category?',
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            noteCount == 0
                ? 'Are you sure you want to delete "$category"?'
                : 'This category contains $noteCount ${noteCount == 1 ? 'note' : 'notes'}.\n\n'
                    'Choose whether to keep or permanently delete these notes.',
            style: TextStyle(
              color: _secondaryColor,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: _secondaryColor),
              ),
            ),
            if (noteCount > 0 && hasDestination)
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'Keep Notes',
                  style: TextStyle(color: _accentColor),
                ),
              ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: Text(
                noteCount > 0
                    ? 'Delete Category & Notes'
                    : 'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (choice == null) return;

    final success = await _service.deleteCategory(
      category,
      deleteNotes: choice,
    );

    if (!mounted) return;

    if (success) {
      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            choice
                ? 'Category and notes permanently deleted'
                : 'Category deleted. Notes moved to ${remainingCategories.first}',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete category.'),
        ),
      );
    }
  }

  // THREE DOT MENU

  Future<void> _showCategoryMenu(String category) async {
    final isPinned = _pinnedCategories.contains(category);

    final choice = await showMenu<String>(
      context: context,
      color: _cardColor,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
      position: const RelativeRect.fromLTRB(120, 180, 15, 0),
      items: [
        PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: _accentColor, size: 21),
              const SizedBox(width: 12),
              Text('Rename', style: TextStyle(color: _textColor)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'pin',
          child: Row(
            children: [
              Icon(
                isPinned
                    ? Icons.push_pin_rounded
                    : Icons.push_pin_outlined,
                color: _accentColor,
                size: 21,
              ),
              const SizedBox(width: 12),
              Text(
                isPinned ? 'Unpin' : 'Pin',
                style: TextStyle(color: _textColor),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 21,
              ),
              SizedBox(width: 12),
              Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ],
    );

    if (!mounted) return;

    switch (choice) {
      case 'rename':
        await _showCategoryDialog(oldName: category);
        break;
      case 'pin':
        await _toggleCategoryPin(category);
        break;
      case 'delete':
        await _deleteCategory(category);
        break;
    }
  }

  // OPEN CATEGORY NOTES

  Future<void> _openCategory(String category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryNotesScreen(category: category),
      ),
    );

    if (mounted) {
      await _loadData();
    }
  }

  // CATEGORY CARD

  Widget _categoryCard(String category) {
    final count = _countNotes(category);
    final isPinned = _pinnedCategories.contains(category);

    return Material(
      color: _cardColor,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: () => _openCategory(category),
        onLongPress: () => _showCategoryMenu(category),
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _borderColor.withValues(alpha: 0.7),
              width: 0.8,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // THEME MATCHING CATEGORY ICON

              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: _iconBackground,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: _accentColor.withValues(alpha: 0.22),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      _iconFor(category),
                      size: 43,
                      color: _accentColor,
                    ),
                    if (isPinned)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Icon(
                          Icons.push_pin_rounded,
                          color: _accentColor,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 13),

              Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                '$count ${count == 1 ? 'note' : 'notes'}',
                style: TextStyle(
                  color: _secondaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 5),

              SizedBox(
                height: 27,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Category options',
                  onPressed: () => _showCategoryMenu(category),
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: _secondaryColor,
                    size: 23,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ADD NEW DASHED CARD

  Widget _addNewCard() {
    return InkWell(
      onTap: () => _showCategoryDialog(),
      borderRadius: BorderRadius.circular(23),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: _accentColor,
          radius: 23,
        ),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                color: _accentColor,
                size: 48,
              ),
              const SizedBox(height: 10),
              Text(
                'Add New',
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
      child: Row(
        children: [
          Material(
            color: _cardColor,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                );
              },
              child: SizedBox(
                width: 53,
                height: 53,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: _accentColor,
                  size: 27,
                ),
              ),
            ),
          ),

          const SizedBox(width: 17),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categories',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Organize your thoughts.',
                  style: TextStyle(
                    color: _secondaryColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 11),
                Container(
                  width: 95,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BOTTOM ADD CATEGORY BUTTON

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton.icon(
          onPressed: () => _showCategoryDialog(),
          icon: const Icon(Icons.add_rounded, size: 24),
          label: const Text(
            'Add Category',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _buttonColor,
            foregroundColor: _buttonTextColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35),
            ),
          ),
        ),
      ),
    );
  }

  // MAIN SCREEN

  @override
  Widget build(BuildContext context) {
    final categories = _displayCategories;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(
                  color: _accentColor,
                ),
              )
            : Column(
                children: [
                  _buildHeader(),

                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final columns = width >= 650 ? 3 : 2;

                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            20, 0, 20, 18,
                          ),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            mainAxisExtent: 230,
                          ),
                          itemCount: categories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == categories.length) {
                              return _addNewCard();
                            }

                            return _categoryCard(categories[index]);
                          },
                        );
                      },
                    ),
                  ),

                  _buildAddButton(),
                ],
              ),
      ),
    );
  }
}

// ======================================================
// DASHED BORDER PAINTER
// ======================================================

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final end = (distance + 8).clamp(0.0, metric.length);

        canvas.drawPath(
          metric.extractPath(distance, end),
          paint,
        );

        distance = end + 5;
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant _DashedBorderPainter oldDelegate,
  ) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius;
  }
}

// ======================================================
// CATEGORY NOTES SCREEN
// ======================================================

class CategoryNotesScreen extends StatefulWidget {
  final String category;

  const CategoryNotesScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryNotesScreen> createState() =>
      _CategoryNotesScreenState();
}

class _CategoryNotesScreenState extends State<CategoryNotesScreen> {
  final NoteServices _service = NoteServices();

  List<NoteModel> _notes = [];
  bool _loading = true;

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _textColor =>
      _isDark ? AppColors.darkText : AppColors.lightText;

  Color get _secondaryColor =>
      _isDark
          ? AppColors.darkSecondaryText
          : AppColors.lightSecondaryText;

  Color get _accentColor =>
      _isDark ? AppColors.darkPrimary : AppColors.primary;

  Color get _backgroundColor =>
      _isDark ? AppColors.darkBackground : AppColors.lightBackground;

  Color get _cardColor =>
      _isDark ? AppColors.darkCard : AppColors.lightSurface;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final allNotes = await _service.getNotes();

      if (!mounted) return;

      setState(() {
        _notes = allNotes
            .where(
              (note) => note.category == widget.category,
            )
            .toList()
          ..sort(
            (a, b) => b.updatedAt.compareTo(a.updatedAt),
          );

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load notes: $e'),
        ),
      );
    }
  }

  Future<void> _editNote(NoteModel note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(note: note),
      ),
    );

    if (!mounted) return;

    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        iconTheme: IconThemeData(color: _accentColor),
        title: Text(
          widget.category,
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: _accentColor,
              ),
            )
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        size: 55,
                        color: _secondaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No notes in ${widget.category}',
                        style: TextStyle(
                          color: _textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your notes will appear here.',
                        style: TextStyle(
                          color: _secondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];

                    return Card(
                      color: _cardColor,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        onTap: () => _editNote(note),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Color(note.colorValue)
                                .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            Icons.description_outlined,
                            color: _accentColor,
                          ),
                        ),
                        title: Text(
                          note.title,
                          style: TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          note.content.isEmpty
                              ? 'No additional text'
                              : note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _secondaryColor,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: _accentColor,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
