
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:mindshelf_note/services/local_storage_service.dart';
import 'package:mindshelf_note/services/note_service.dart' hide NoteServices;
import 'package:mindshelf_note/theme/color_app.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final NoteServices _noteService = NoteServices();

  late final TextEditingController _titleController;
  late final quill.QuillController _quillController;

  List<String> _categories = [
    'Personal',
    'Work',
    'Study',
    'Ideas',
    'Important',
  ];

  // Same colors used in Settings Screen.
  final List<Color> _noteColors = [
    AppColors.notePink,
    AppColors.noteYellow,
    AppColors.notePurple,
    AppColors.noteGreen,
    AppColors.noteBlue,
    AppColors.notePeach,
  ];

  late String _selectedCategory;
  late Color _selectedColor;

  late bool _isPinned;
  late bool _isFavorite;

  bool _isSaving = false;

  final ImagePicker _imagePicker = ImagePicker();

  String? _imagePath;
  bool _isPickingImage = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();

    final note = widget.note;
    _imagePath = note?.imagePath;

    _titleController = TextEditingController(
      text: note?.title ?? '',
    );

    quill.Document document;
    final savedDelta = note?.contentDelta;
    final plainContent = note?.content ?? '';

    try {
      if (savedDelta != null && savedDelta.isNotEmpty) {
        document = quill.Document.fromJson(
          jsonDecode(savedDelta) as List,
        );
      } else {
        document = quill.Document();
        if (plainContent.isNotEmpty) {
          document.insert(0, plainContent);
        }
      }
    } catch (_) {
      document = quill.Document();
      if (plainContent.isNotEmpty) {
        document.insert(0, plainContent);
      }
    }

    _quillController = quill.QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _selectedCategory = note?.category ?? 'Ideas';

    _selectedColor = Color(
      note?.colorValue ?? AppColors.notePink.toARGB32(),
    );

    _isPinned = note?.isPinned ?? false;
    _isFavorite = note?.isFavorite ?? false;

    _loadEditorPreferences();
  }

  // Load categories and default preferences from Settings.
  Future<void> _loadEditorPreferences() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final savedCategories = await _noteService.getCategories();

      final defaultCategory =
          preferences.getString('default_category') ?? 'Personal';

      final defaultColorIndex =
          preferences.getInt('default_note_color') ?? 0;

      final categories = List<String>.from(savedCategories);

      if (categories.isEmpty) {
        categories.addAll([
          'Personal',
          'Work',
          'Study',
          'Ideas',
          'Important',
        ]);
      }

      // Keep an existing note's category available while editing.
      if (_isEditing &&
          !categories.contains(widget.note!.category)) {
        categories.add(widget.note!.category);
      }

      String category;

      if (_isEditing) {
        // Do not change the category of an existing note.
        category = widget.note!.category;
      } else if (categories.contains(defaultCategory)) {
        // Apply Settings default category for new notes.
        category = defaultCategory;
      } else {
        category = categories.first;
      }

      // Apply Settings default color only for new notes.
      final Color selectedColor;

      if (_isEditing) {
        selectedColor = Color(widget.note!.colorValue);
      } else {
        final safeIndex = defaultColorIndex >= 0 &&
                defaultColorIndex < _noteColors.length
            ? defaultColorIndex
            : 0;

        selectedColor = _noteColors[safeIndex];
      }

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _selectedCategory = category;
        _selectedColor = selectedColor;
      });
    } catch (e) {
      debugPrint('Unable to load editor preferences: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
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

  // Save note and rich-text Delta.
  Future<void> _saveNote() async {
    final title = _titleController.text.trim();

    final content =
        _quillController.document.toPlainText().trim();

    final contentDelta = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please write a title or note first.',
          ),
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
        contentDelta: contentDelta,
        category: _selectedCategory,
        colorValue: _selectedColor.toARGB32(),
        isPinned: _isPinned,
        isFavorite: _isFavorite,
        imagePath: _imagePath,
        createdAt: oldNote?.createdAt ?? now,
        updatedAt: now,
      );

      await _noteService.saveNote(note);

      if (!mounted) return;

      Navigator.pop(context, note);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save note: $e'),
        ),
      );

      setState(() => _isSaving = false);
    }
  }

  // More options.
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
                  setState(
                    () => _isPinned = !_isPinned,
                  );
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
                  setState(
                    () => _isFavorite = !_isFavorite,
                  );
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

  // Delete note.
  Future<void> _deleteNote() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Note?'),
          content: const Text(
            'Are you sure you want to delete this note?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
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

    await _noteService.deleteNote(widget.note!.id);

    if (mounted) {
      Navigator.pop(context, 'deleted');
    }
  }

  Widget _richTextToolbar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isDark
              ? AppColors.darkDivider
              : AppColors.lightDivider,
        ),
      ),
      child: quill.QuillSimpleToolbar(
        controller: _quillController,
        config: const quill.QuillSimpleToolbarConfig(
          multiRowsDisplay: true,
          showFontFamily: false,
          showFontSize: false,
          showBoldButton: true,
          showItalicButton: true,
          showUnderLineButton: true,
          showStrikeThrough: true,
          showColorButton: true,
          showBackgroundColorButton: true,
          showClearFormat: true,
          showAlignmentButtons: true,
          showListNumbers: true,
          showListBullets: true,
          showUndo: true,
          showRedo: true,
          showQuote: true,
          showLink: true,
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

  // Pick image.
  Future<void> _pickImage() async {
    try {
      setState(() => _isPickingImage = true);

      final XFile? pickedFile =
          await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (pickedFile == null || !mounted) return;

      final directory =
          await getApplicationDocumentsDirectory();

      final extension = pickedFile.path.contains('.')
          ? pickedFile.path.split('.').last
          : 'jpg';

      final fileName =
          'note_${DateTime.now().microsecondsSinceEpoch}.$extension';

      final savedFile = await File(pickedFile.path).copy(
        '${directory.path}/$fileName',
      );

      if (!mounted) return;

      setState(() {
        _imagePath = savedFile.path;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to select image: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
    });
  }

  // Image section.
  Widget _imageSection() {
    final isDark = _isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Note Image'),
        const SizedBox(height: 10),

        if (_imagePath != null &&
            File(_imagePath!).existsSync())
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Image.file(
                  File(_imagePath!),
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: _removeImage,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          InkWell(
            onTap: _isPickingImage ? null : _pickImage,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: double.infinity,
              height: 115,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCard
                    : const Color(0xFFFFF0F2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.primary.withValues(
                    alpha: 0.3,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isPickingImage)
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                    )
                  else
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  const SizedBox(height: 7),
                  Text(
                    _isPickingImage
                        ? 'Loading image...'
                        : 'Add Image from Gallery',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12, 5, 12, 8,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: _textColor,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed:
                        _isSaving ? null : _saveNote,
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
                padding: const EdgeInsets.fromLTRB(
                  20, 5, 20, 25,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                        contentPadding:
                            const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: _isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                          ),
                        ),
                        enabledBorder:
                            UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: _isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                          ),
                        ),
                        focusedBorder:
                            const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // FORMATTING TOOLBAR
                    _richTextToolbar(),

                    const SizedBox(height: 15),

                    // RICH TEXT CONTENT
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        minHeight: 280,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 8,
                      ),
                      child: quill.QuillEditor.basic(
                        controller: _quillController,
                        config: const quill.QuillEditorConfig(
                          padding: EdgeInsets.zero,
                          scrollable: false,
                          autoFocus: false,
                          expands: false,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // NOTE IMAGE
                    _imageSection(),

                    const SizedBox(height: 25),

                    // CATEGORY
                    Row(
                      children: [
                        Expanded(
                          child: _sectionLabel(
                            'Category:',
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _isDark
                                ? AppColors.darkCard
                                : AppColors.lightCard,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child:
                              DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _categories.contains(
                                      _selectedCategory)
                                  ? _selectedCategory
                                  : _categories.first,
                              borderRadius:
                                  BorderRadius.circular(14),
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: _textColor,
                              ),
                              style: TextStyle(
                                color: _textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              items: _categories.map(
                                (category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  );
                                },
                              ).toList(),
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
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
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
                            duration: const Duration(
                              milliseconds: 180,
                            ),
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
    final hour =
        date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute =
        date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, ${date.year} • $hour:$minute $period';
  }

  String _monthName(int month) {
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

    return months[month - 1];
  }
}
