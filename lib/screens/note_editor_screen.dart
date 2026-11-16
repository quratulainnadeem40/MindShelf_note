
import 'package:flutter/material.dart';
import 'package:mindshelf_note/services/local_storage_service.dart';
import 'package:mindshelf_note/theme/color_app.dart';

import '../models/note_model.dart';


class NoteEditorScreen extends StatefulWidget {
  final NoteModel? note;

  const NoteEditorScreen({
    super.key,
    this.note,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final NoteService _noteService = NoteService();

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  final List<String> _categories = [
    'Personal',
    'Work',
    'Study',
    'Ideas',
    'Important',
  ];

  final List<Color> _noteColors = [
    const Color(0xFF712E3F),
    const Color(0xFFE7A6B4),
    const Color(0xFFF0C1B9),
    const Color(0xFFEBCB91),
    const Color(0xFFA8C5A1),
    const Color(0xFF83B6CC),
  ];

  late String _selectedCategory;
  late Color _selectedColor;

  late bool _isPinned;
  late bool _isFavorite;

  bool _isSaving = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();

    final note = widget.note;

    _titleController = TextEditingController(
      text: note?.title ?? '',
    );

    _contentController = TextEditingController(
      text: note?.content ?? '',
    );

    _selectedCategory = note?.category ?? 'Ideas';

    _selectedColor = Color(
      note?.colorValue ?? 0xFFE7A6B4,
    );

    _isPinned = note?.isPinned ?? false;
    _isFavorite = note?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _textColor =>
      _isDark ? AppColors.darkText : AppColors.lightText;

  Color get _secondaryColor =>
      _isDark
          ? AppColors.darkSecondaryText
          : AppColors.lightSecondaryText;

  Color get _surfaceColor =>
      _isDark ? AppColors.darkCard : AppColors.lightSurface;

  void _formatSelection(String marker) {
    final text = _contentController.text;
    final selection = _contentController.selection;

    if (!selection.isValid) return;

    final start = selection.start;
    final end = selection.end;

    final selectedText = text.substring(start, end);

    if (selectedText.isEmpty) {
      final value = text.substring(0, start) +
          marker +
          marker +
          text.substring(start);

      _contentController.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(
          offset: start + marker.length,
        ),
      );
      return;
    }

    final formatted = '$marker$selectedText$marker';

    final newText = text.replaceRange(
      start,
      end,
      formatted,
    );

    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: start + marker.length,
        extentOffset: start + marker.length + selectedText.length,
      ),
    );
  }

  void _insertList(bool numbered) {
    final selection = _contentController.selection;
    final text = _contentController.text;

    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;

    final selected = text.substring(start, end);

    final prefix = numbered ? '1. ' : '• ';

    final formatted = selected.isEmpty
        ? '\n$prefix'
        : selected
            .split('\n')
            .map((line) => '$prefix$line')
            .join('\n');

    final newText = text.replaceRange(start, end, formatted);

    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start + formatted.length,
      ),
    );
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a title or note first.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final oldNote = widget.note;

      final note = NoteModel(
        id: oldNote?.id ??
            now.microsecondsSinceEpoch.toString(),
        title: title.isEmpty ? 'Untitled Note' : title,
        content: content,
        category: _selectedCategory,
        colorValue: _selectedColor.toARGB32(),
        isPinned: _isPinned,
        isFavorite: _isFavorite,
        createdAt: oldNote?.createdAt ?? now,
        updatedAt: now,
      );

      await _noteService.saveNote(note);

      if (!mounted) return;

      Navigator.pop(context, note);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save note: $e')),
      );

      setState(() => _isSaving = false);
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  _isPinned
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                ),
                title: Text(
                  _isPinned ? 'Unpin Note' : 'Pin Note',
                ),
                onTap: () {
                  setState(() => _isPinned = !_isPinned);
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: Icon(
                  _isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                title: Text(
                  _isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                ),
                onTap: () {
                  setState(() => _isFavorite = !_isFavorite);
                  Navigator.pop(sheetContext);
                },
              ),
              if (_isEditing)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  title: const Text('Delete Note'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _deleteNote();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteNote() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text(
          'Are you sure you want to delete this note?',
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
      ),
    );

    if (confirm != true) return;

    await _noteService.deleteNote(widget.note!.id);

    if (mounted) {
      Navigator.pop(context, 'deleted');
    }
  }

  Widget _formatButton(
    IconData icon,
    VoidCallback onTap, {
    bool active = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: active
                ? _selectedColor.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 20,
            color: active ? _selectedColor : _textColor,
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: _textColor,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 5, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: _textColor,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _isSaving ? null : _saveNote,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                  IconButton(
                    onPressed: _showMoreOptions,
                    icon: Icon(
                      Icons.more_vert,
                      color: _textColor,
                    ),
                  ),
                ],
              ),
            ),

            // EDITOR BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Note Title',
                        hintStyle: TextStyle(
                          color: _secondaryColor,
                          fontSize: 23,
                        ),
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: _isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: _isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // FORMATTING TOOLBAR
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _formatButton(
                            Icons.format_bold,
                            () => _formatSelection('**'),
                          ),
                          _formatButton(
                            Icons.format_italic,
                            () => _formatSelection('*'),
                          ),
                          _formatButton(
                            Icons.format_underline,
                            () => _formatSelection('__'),
                          ),
                          _formatButton(
                            Icons.format_list_bulleted,
                            () => _insertList(false),
                          ),
                          _formatButton(
                            Icons.format_list_numbered,
                            () => _insertList(true),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // CONTENT
                    TextField(
                      controller: _contentController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 11,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 15,
                        height: 1.65,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write your ideas here...',
                        hintStyle: TextStyle(
                          color: _secondaryColor,
                          fontSize: 14,
                        ),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // CATEGORY
                    Row(
                      children: [
                        Expanded(
                          child: _sectionLabel('Category:'),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _isDark
                                ? AppColors.darkCard
                                : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              borderRadius: BorderRadius.circular(14),
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: _textColor,
                              ),
                              style: TextStyle(
                                color: _textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // NOTE COLORS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _noteColors.map((color) {
                        final selected =
                            _selectedColor.toARGB32() ==
                                color.toARGB32();

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: selected ? 25 : 21,
                            height: selected ? 25 : 21,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? _textColor
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: selected
                                ? const Icon(
                                    Icons.check,
                                    size: 13,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 26),

                    // LAST EDITED
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: _secondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Last edited: ${_formatDate(widget.note?.updatedAt ?? DateTime.now())}',
                          style: TextStyle(
                            fontSize: 11,
                            color: _secondaryColor,
                          ),
                        ),
                      ],
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _monthName(date.month);
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, ${date.year} • $hour:$minute $period';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return months[month - 1];
  }
}
