
import 'package:flutter/material.dart';
import 'package:mindshelf_note/services/local_storage_service.dart';
import 'package:mindshelf_note/services/note_service.dart' hide NoteServices;
import 'package:mindshelf_note/theme/color_app.dart';

import '../models/note_model.dart';
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

  bool _loading = true;

  // GOLD LUXE COLORS
  static const Color _gold = Color(0xFFE2B85F);
  static const Color _goldDark = Color(0xFF98753B);
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkCard = Color(0xFF27282B);
  static const Color _lightText = Color(0xFFFFF9ED);
  static const Color _mutedText = Color(0xFFC5BDAF);

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

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _backgroundColor =>
      _isDark ? _darkBackground : const Color(0xFFF7F4ED);

  Color get _cardColor =>
      _isDark ? _darkCard : Colors.white;

  Color get _textColor =>
      _isDark ? _lightText : const Color(0xFF25221D);

  Color get _secondaryColor =>
      _isDark ? _mutedText : const Color(0xFF77716A);

  Color get _borderColor =>
      _isDark ? const Color(0xFF383838) : const Color(0xFFE8E0D2);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // LOAD SAVED CATEGORIES AND NOTES
  Future<void> _loadData() async {
    try {
      final categories = await _service.getCategories();
      final notes = await _service.getNotes();
      final icons = await _service.getCategoryIcons();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _notes = notes;
        _categoryIconKeys = icons;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load categories: $e')),
      );
    }
  }

  // NOTES COUNT
  int _countNotes(String category) {
    return _notes.where(
      (note) => note.category == category,
    ).length;
  }

  // CATEGORY ICON
  IconData _iconFor(String category) {
    final key = _categoryIconKeys[category];

    if (key != null && _availableCategoryIcons.containsKey(key)) {
      return _availableCategoryIcons[key]!;
    }

    switch (category.toLowerCase()) {
      case 'personal':
        return Icons.person_outline_rounded;
      case 'work':
        return Icons.work_outline_rounded;
      case 'study':
        return Icons.menu_book_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'ideas':
        return Icons.lightbulb_outline_rounded;
      case 'important':
        return Icons.star_outline_rounded;
      default:
        return Icons.folder_outlined;
    }
  }

  // ADD / EDIT CATEGORY DIALOG
  Future<void> _showCategoryDialog({
    String? oldName,
  }) async {
    final controller = TextEditingController(text: oldName ?? '');

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
                isEditing ? 'Edit Category' : 'Add Category',
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

                    const SizedBox(height: 20),

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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(
                            color: _gold,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'Choose Category Icon',
                      style: TextStyle(
                        color: _textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableCategoryIcons.entries.map((entry) {
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
                                  ? _gold.withValues(alpha: 0.2)
                                  : _backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected ? _gold : _borderColor,
                              ),
                            ),
                            child: Icon(
                              entry.value,
                              color: selected ? _gold : _secondaryColor,
                              size: 21,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
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
                    backgroundColor: _gold,
                    foregroundColor: const Color(0xFF292016),
                  ),
                  child: Text(isEditing ? 'Update' : 'Add Category'),
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
      await _service.saveCategoryIcon(name, result.iconKey);
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
          content: Text('Category already exists or cannot be changed.'),
        ),
      );
    }
  }

  // DELETE CATEGORY
  Future<void> _deleteCategory(String category) async {
    if (category == 'Personal') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal is the default category and cannot be deleted.'),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _cardColor,
          title: Text(
            'Delete Category?',
            style: TextStyle(color: _textColor),
          ),
          content: Text(
            'Delete "$category"? Its notes will be moved to Personal.',
            style: TextStyle(color: _secondaryColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final success = await _service.deleteCategory(category);

    if (!mounted) return;

    if (success) {
      await _loadData();
    }
  }

  // CATEGORY OPTIONS
  Future<void> _showCategoryMenu(String category) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: _gold),
                title: Text(
                  'Rename Category',
                  style: TextStyle(color: _textColor),
                ),
                onTap: () => Navigator.pop(sheetContext, 'rename'),
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                title: Text(
                  'Delete Category',
                  style: TextStyle(color: _textColor),
                ),
                onTap: () => Navigator.pop(sheetContext, 'delete'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (choice == 'rename') {
      await _showCategoryDialog(oldName: category);
    } else if (choice == 'delete') {
      await _deleteCategory(category);
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

    if (mounted) await _loadData();
  }

  // CATEGORY CARD
  Widget _categoryCard(String category) {
    final count = _countNotes(category);

    return Material(
      color: _cardColor,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: () => _openCategory(category),
        onLongPress: () => _showCategoryMenu(category),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: _borderColor.withValues(alpha: 0.7),
              width: 0.7,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // GOLD ICON BACKGROUND
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: _isDark ? _goldDark : _gold,
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.12),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  _iconFor(category),
                  size: 43,
                  color: const Color(0xFFFFD77D),
                ),
              ),

              const SizedBox(height: 15),

              // CATEGORY NAME
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  category,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // NOTES COUNT
              Text(
                '$count ${count == 1 ? 'note' : 'notes'}',
                style: TextStyle(
                  color: _secondaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              // CATEGORY OPTIONS
              SizedBox(
                height: 25,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Category options',
                  onPressed: () => _showCategoryMenu(category),
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: _secondaryColor,
                    size: 21,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DASHED ADD NEW CARD
  Widget _addNewCard() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: () => _showCategoryDialog(),
        borderRadius: BorderRadius.circular(25),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: _gold,
            radius: 25,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_rounded,
                  color: _gold,
                  size: 43,
                ),
                const SizedBox(height: 9),
                const Text(
                  'Add New',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Material(
                color: _cardColor,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.maybePop(context),
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: _gold,
                      size: 27,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 17),

              Expanded(
                child: Text(
                  'Categories',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.9,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.only(left: 71),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organize your thoughts.',
                  style: TextStyle(
                    color: _secondaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: 95,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _gold,
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

  // BOTTOM ADD BUTTON
  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: SizedBox(
        height: 65,
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showCategoryDialog(),
          icon: const Icon(Icons.add_rounded, size: 26),
          label: const Text(
            'Add Category',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _gold,
            foregroundColor: const Color(0xFF282016),
            elevation: 3,
            shadowColor: _gold.withValues(alpha: 0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: _gold),
              )
            : Column(
                children: [
                  _buildHeader(),

                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 145,
                      ),
                      itemCount: _categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _categories.length) {
                          return _addNewCard();
                        }

                        return _categoryCard(_categories[index]);
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

// =====================================================
// DASHED BORDER PAINTER
// =====================================================

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

    final metrics = path.computeMetrics();

    for (final metric in metrics) {
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
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius;
  }
}

// =====================================================
// CATEGORY NOTES SCREEN
// =====================================================

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
      _isDark ? _CategoriesScreenState._lightText
          : const Color(0xFF25221D);

  Color get _secondaryColor =>
      _isDark ? _CategoriesScreenState._mutedText
          : const Color(0xFF77716A);

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
            .where((note) => note.category == widget.category)
            .toList()
          ..sort(
            (a, b) => b.updatedAt.compareTo(a.updatedAt),
          );

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _editNote(NoteModel note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(note: note),
      ),
    );

    if (!mounted) return;

    if (result == 'deleted' || result is NoteModel) {
      await _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF7F4ED),
      appBar: AppBar(
        backgroundColor: _isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF7F4ED),
        iconTheme: const IconThemeData(
          color: Color(0xFFE2B85F),
        ),
        title: Text(
          widget.category,
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE2B85F),
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
                          child: const Icon(
                            Icons.description_outlined,
                            color: Color(0xFFE2B85F),
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
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFE2B85F),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
