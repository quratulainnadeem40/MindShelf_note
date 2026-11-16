
import 'package:flutter/material.dart';
import 'package:mindshelf_note/services/local_storage_service.dart';
import 'package:mindshelf_note/services/note_service.dart';
import 'package:mindshelf_note/theme/color_app.dart';

import '../models/note_model.dart';
import 'note_editor_screen.dart';

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

  final List<Color> _colors = [
    const Color(0xFFF5DCE3),
    const Color(0xFFF1D7CA),
    const Color(0xFFE9DCEB),
    const Color(0xFFF6E1CE),
    const Color(0xFFF2DCE4),
    const Color(0xFFDCE9DF),
    const Color(0xFFDCE9F0),
  ];

  final List<IconData> _icons = [
    Icons.person_outline_rounded,
    Icons.work_outline_rounded,
    Icons.menu_book_rounded,
    Icons.lightbulb_outline_rounded,
    Icons.star_outline_rounded,
    Icons.favorite_border_rounded,
    Icons.folder_outlined,
  ];

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await _service.getCategories();
    final notes = await _service.getNotes();

    if (!mounted) return;

    setState(() {
      _categories = categories;
      _notes = notes;
      _loading = false;
    });
  }

  int _countNotes(String category) {
    return _notes.where(
      (note) => note.category == category,
    ).length;
  }

  IconData _iconFor(String category) {
    switch (category.toLowerCase()) {
      case 'personal':
        return Icons.person_outline_rounded;
      case 'work':
        return Icons.work_outline_rounded;
      case 'study':
        return Icons.menu_book_rounded;
      case 'ideas':
        return Icons.lightbulb_outline_rounded;
      case 'important':
        return Icons.star_outline_rounded;
      default:
        return Icons.folder_outlined;
    }
  }

  Color _colorFor(int index) {
    return _colors[index % _colors.length];
  }

  Future<void> _showCategoryDialog({
    String? oldName,
  }) async {
    final controller = TextEditingController(
      text: oldName ?? '',
    );

    final isEditing = oldName != null;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isEditing ? 'Rename Category' : 'Add Category',
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 25,
            decoration: InputDecoration(
              hintText: 'Category name',
              counterText: '',
              filled: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.trim().isEmpty) return;

    final success = isEditing
        ? await _service.renameCategory(oldName!, result)
        : await _service.addCategory(result);

    if (!mounted) return;

    if (success) {
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

  Widget _categoryCard(String category, int index) {
    final count = _countNotes(category);
    final color = _colorFor(index);

    return Material(
      color: _cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openCategory(category),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dividerColorForCard(),
              width: 0.7,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconFor(category),
                  color: const Color(0xFF98536A),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$count ${count == 1 ? 'note' : 'notes'}',
                      style: TextStyle(
                        color: _secondaryColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showCategoryMenu(category),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 36,
                ),
                icon: Icon(
                  Icons.more_vert,
                  color: _secondaryColor,
                  size: 19,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 12, 17, 17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          icon: Icon(
                            Icons.arrow_back,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Organize your thoughts.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _categories.isEmpty
                        ? Center(
                            child: Text(
                              'No categories yet.',
                              style: TextStyle(
                                color: _secondaryColor,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              17, 0, 17, 12,
                            ),
                            itemCount: _categories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 9),
                            itemBuilder: (context, index) {
                              return _categoryCard(
                                _categories[index],
                                index,
                              );
                            },
                          ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 8, 17, 13),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
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
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
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
  final NoteService _service = NoteService();

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
