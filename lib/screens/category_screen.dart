
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

  bool _loading = true;

  // Stable icon keys are saved in SharedPreferences by NoteServices.
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

  Map<String, String> _categoryIconKeys = {};

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _textColor =>
      _isDark ? AppColors.darkText : AppColors.lightText;

  Color get _secondaryColor =>
      _isDark
          ? AppColors.darkSecondaryText
          : AppColors.lightSecondaryText;

  Color get _cardColor =>
      _isDark ? AppColors.darkCard : AppColors.lightSurface;

  Color get _dividerColor =>
      _isDark ? AppColors.darkDivider : AppColors.lightDivider;

  Color get _primaryColor =>
      _isDark ? AppColors.darkPrimary : AppColors.primary;

  Color get _backgroundColor =>
      _isDark ? AppColors.darkBackground : AppColors.lightBackground;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await _service.getCategories();
    final notes = await _service.getNotes();
    final categoryIconKeys = await _service.getCategoryIcons();

    if (!mounted) return;

    setState(() {
      _categories = categories;
      _notes = notes;
      _categoryIconKeys = categoryIconKeys;
      _loading = false;
    });
  }

  int _countNotes(String category) {
    return _notes.where(
      (note) => note.category == category,
    ).length;
  }

  IconData _iconFor(String category) {
    final savedKey = _categoryIconKeys[category];
    if (savedKey != null && _availableCategoryIcons.containsKey(savedKey)) {
      return _availableCategoryIcons[savedKey]!;
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
              titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
              contentPadding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
              actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              title: Text(
                isEditing ? 'Rename Category' : 'Add Category',
                style: TextStyle(
                  color: _textColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create a category to organize your notes.',
                      style: TextStyle(
                        color: _secondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Category name',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      maxLength: 25,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Enter category name',
                        counterText: '',
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(color: _dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(color: _dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(
                            color: _primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Choose an icon',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableCategoryIcons.entries.map((entry) {
                        final iconKey = entry.key;
                        final icon = entry.value;
                        final isSelected = selectedIconKey == iconKey;
                        return InkWell(
                          onTap: () {
                            setDialogState(() => selectedIconKey = iconKey);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _primaryColor.withValues(alpha: 0.15)
                                  : Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? _primaryColor
                                    : _dividerColor,
                                width: isSelected ? 1.5 : 0.8,
                              ),
                            ),
                            child: Icon(
                              icon,
                              size: 21,
                              color: isSelected
                                  ? _primaryColor
                                  : _secondaryColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: _secondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Selected icon will appear on this category.',
                            style: TextStyle(
                              color: _secondaryColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: _secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
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
                    backgroundColor: _primaryColor,
                    foregroundColor: _isDark
                        ? AppColors.darkBackground
                        : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Update' : 'Add Category',
                    style: const TextStyle(fontWeight: FontWeight.w700),
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

    final categoryName = result.name.trim();
    final success = isEditing
        ? await _service.renameCategory(oldName, categoryName)
        : await _service.addCategory(categoryName);

    if (!mounted) return;

    if (success) {
      await _service.saveCategoryIcon(categoryName, result.iconKey);
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
          title: const Text('Delete Category?'),
          content: Text(
            'Delete "$category"? Its notes will be moved to Personal.',
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Rename Category'),
                  onTap: () => Navigator.pop(sheetContext, 'rename'),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  title: const Text('Delete Category'),
                  onTap: () => Navigator.pop(sheetContext, 'delete'),
                ),
              ],
            ),
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

  Future<void> _openCategory(String category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryNotesScreen(
          category: category,
        ),
      ),
    );

    await _loadData();
  }

  Widget _headerIllustration() {
    final illustrationBackground =
        _isDark ? AppColors.darkPink : AppColors.lightPink;

    final paperColor =
        _isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final folderColor =
        _isDark ? AppColors.darkPrimary : AppColors.primary;

    final folderIconColor =
        _isDark ? AppColors.darkBackground : Colors.white;

    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: illustrationBackground,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 14,
            right: 16,
            child: Transform.rotate(
              angle: 0.12,
              child: Container(
                width: 55,
                height: 62,
                decoration: BoxDecoration(
                  color: paperColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.notes_rounded,
                  color: folderColor.withValues(alpha: 0.45),
                  size: 27,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              width: 76,
              height: 55,
              decoration: BoxDecoration(
                color: folderColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: folderColor.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.folder_special_rounded,
                color: folderIconColor,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(String category) {
    final count = _countNotes(category);

    return Material(
      color: _cardColor,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: () => _openCategory(category),
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: dividerColorForCard(),
              width: 0.7,
            ),
            boxShadow: _isDark
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.055),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _isDark
                      ? AppColors.darkPink
                      : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _iconFor(category),
                  size: 22,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count ${count == 1 ? 'note' : 'notes'}',
                      style: TextStyle(
                        color: _secondaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showCategoryMenu(category),
                tooltip: 'Category options',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(
                  minWidth: 38,
                  minHeight: 38,
                ),
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: _secondaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color dividerColorForCard() =>
      _isDark
          ? AppColors.darkDivider
          : AppColors.lightDivider.withValues(alpha: 0.65);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(
                  color: _primaryColor,
                ),
              )
            : Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18, 5, 18, 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BACK BUTTON
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: _textColor,
                              size: 21,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        // TITLE + FIXED FOLDER ILLUSTRATION
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Categories',
                                    style: TextStyle(
                                      color: _textColor,
                                      fontSize: 27,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.7,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Organize your thoughts.',
                                    style: TextStyle(
                                      color: _secondaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: 52,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: _primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // FIXED POSITION
                            SizedBox(
                              width: 104,
                              height: 104,
                              child: _headerIllustration(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // CATEGORY LIST
                  Expanded(
                    child: _categories.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(25),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.folder_open_rounded,
                                    size: 48,
                                    color: _secondaryColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No categories yet',
                                    style: TextStyle(
                                      color: _textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Add a category to organize your notes.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _secondaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              18, 7, 18, 14,
                            ),
                            itemCount: _categories.length,
                            separatorBuilder: (_, index) =>
                                const SizedBox(height: 9),
                            itemBuilder: (context, index) {
                              return _categoryCard(_categories[index]);
                            },
                          ),
                  ),
                  // ADD CATEGORY BUTTON
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18, 9, 18, 14,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 49,
                      child: ElevatedButton.icon(
                        onPressed: () => _showCategoryDialog(),
                        icon: const Icon(
                          Icons.add_rounded,
                          size: 21,
                        ),
                        label: const Text(
                          'Add Category',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 1,
                          shadowColor:
                              _primaryColor.withValues(alpha: 0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
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
      _isDark ? AppColors.darkText : AppColors.lightText;

  Color get _secondaryColor =>
      _isDark
          ? AppColors.darkSecondaryText
          : AppColors.lightSecondaryText;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.category,
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Notes assigned to this category will appear here.',
                        textAlign: TextAlign.center,
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
                          width: 40,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Color(note.colorValue)
                                .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: AppColors.primary,
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
                          color: _secondaryColor,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
