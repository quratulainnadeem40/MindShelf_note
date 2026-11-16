import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class NoteServices {
  static const String _storageKey = 'simplynote_saved_notes';
  static const String _categoryKey = 'simplynote_categories';
  static const String _categoryIconsKey = 'simplynote_category_icons';

  static const List<String> defaultCategories = [
    'Personal',
    'Work',
    'Study',
    'Ideas',
    'Important',
  ];

  // GET NOTES
  Future<List<NoteModel>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);

    if (data == null || data.isEmpty) return [];

    try {
      final decoded = jsonDecode(data) as List;
      return decoded.map((item) => NoteModel.fromJson(
        Map<String, dynamic>.from(item),
      )).toList();
    } catch (_) {
      return [];
    }
  }

  // SAVE NOTE
  Future<void> saveNote(NoteModel note) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);

    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.add(note);
    }

    await _saveAll(notes);
  }

  // SOFT DELETE NOTE
  Future<void> deleteNote(String id) async {
    final notes = await getNotes();

    final index = notes.indexWhere((note) => note.id == id);
    if (index == -1) return;

    notes[index].isDeleted = true;
    notes[index].updatedAt = DateTime.now();

    await _saveAll(notes);
  }

  // RESTORE NOTE
  Future<void> restoreNote(String id) async {
    final notes = await getNotes();

    final index = notes.indexWhere((note) => note.id == id);
    if (index == -1) return;

    notes[index].isDeleted = false;
    notes[index].updatedAt = DateTime.now();

    await _saveAll(notes);
  }

  // PERMANENT DELETE
  Future<void> permanentlyDeleteNote(String id) async {
    final notes = await getNotes();
    notes.removeWhere((note) => note.id == id);
    await _saveAll(notes);
  }

  // EMPTY TRASH
  Future<void> emptyTrash() async {
    final notes = await getNotes();
    notes.removeWhere((note) => note.isDeleted);
    await _saveAll(notes);
  }

  // PIN NOTE
  Future<void> togglePin(String id) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == id);
    if (index == -1) return;

    notes[index].isPinned = !notes[index].isPinned;
    notes[index].updatedAt = DateTime.now();
    await _saveAll(notes);
  }

  // FAVORITE NOTE
  Future<void> toggleFavorite(String id) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == id);
    if (index == -1) return;

    notes[index].isFavorite = !notes[index].isFavorite;
    notes[index].updatedAt = DateTime.now();
    await _saveAll(notes);
  }


  // GET ACTIVE NOTES
  Future<List<NoteModel>> getActiveNotes() async {
    final notes = await getNotes();

    return notes.where((note) => !note.isDeleted).toList();
  }

  // GET TRASH NOTES
  Future<List<NoteModel>> getDeletedNotes() async {
    final notes = await getNotes();

    return notes.where((note) => note.isDeleted).toList();
  }

  // GET PINNED NOTES
  Future<List<NoteModel>> getPinnedNotes() async {
    final notes = await getActiveNotes();

    return notes.where((note) => note.isPinned).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // GET FAVORITE NOTES
  Future<List<NoteModel>> getFavoriteNotes() async {
    final notes = await getActiveNotes();

    return notes.where((note) => note.isFavorite).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // SET PIN STATUS
  Future<void> setPinStatus(String id, bool value) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == id);

    if (index == -1) return;

    notes[index].isPinned = value;
    notes[index].updatedAt = DateTime.now();

    await _saveAll(notes);
  }

  // SET FAVORITE STATUS
  Future<void> setFavoriteStatus(String id, bool value) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == id);

    if (index == -1) return;

    notes[index].isFavorite = value;
    notes[index].updatedAt = DateTime.now();

    await _saveAll(notes);
  }

  // SAVE ALL
  Future<void> _saveAll(List<NoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(notes.map((n) => n.toJson()).toList()),
    );
  }

  // GET CATEGORIES
  Future<List<String>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_categoryKey);

    if (stored == null) {
      await prefs.setStringList(_categoryKey, defaultCategories);
      return List<String>.from(defaultCategories);
    }

    return List<String>.from(stored);
  }

  // GET SAVED CATEGORY ICON KEYS
  // Example: {"Reading": "study", "Travel": "travel"}
  Future<Map<String, String>> getCategoryIcons() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_categoryIconsKey);

    if (data == null || data.isEmpty) return {};

    try {
      final decoded = jsonDecode(data) as Map;
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return {};
    }
  }

  // SAVE OR UPDATE A CATEGORY ICON
  Future<void> saveCategoryIcon(String category, String iconKey) async {
    final prefs = await SharedPreferences.getInstance();
    final icons = await getCategoryIcons();
    icons[category] = iconKey;

    await prefs.setString(_categoryIconsKey, jsonEncode(icons));
  }

  // ADD CATEGORY
  Future<bool> addCategory(String name) async {
    final category = name.trim();
    if (category.isEmpty) return false;

    final categories = await getCategories();

    if (categories.any(
      (c) => c.toLowerCase() == category.toLowerCase(),
    )) {
      return false;
    }

    categories.add(category);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoryKey, categories);
    return true;
  }

  // RENAME CATEGORY
  Future<bool> renameCategory(
    String oldName,
    String newName,
  ) async {
    final updatedName = newName.trim();

    if (updatedName.isEmpty || oldName == 'Personal') {
      return false;
    }

    final categories = await getCategories();

    if (categories.any(
      (c) =>
          c.toLowerCase() == updatedName.toLowerCase() &&
          c != oldName,
    )) {
      return false;
    }

    final index = categories.indexOf(oldName);
    if (index == -1) return false;

    categories[index] = updatedName;

    final notes = await getNotes();

    for (final note in notes) {
      if (note.category == oldName) {
        note.category = updatedName;
        note.updatedAt = DateTime.now();
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoryKey, categories);
    await _saveAll(notes);

    // Keep the category's selected icon when its name changes.
    final icons = await getCategoryIcons();
    final oldIconKey = icons.remove(oldName);
    if (oldIconKey != null) {
      icons[updatedName] = oldIconKey;
      await prefs.setString(_categoryIconsKey, jsonEncode(icons));
    }

    return true;
  }

  // DELETE CATEGORY
  Future<bool> deleteCategory(String name) async {
    if (name == 'Personal') return false;

    final categories = await getCategories();
    if (!categories.contains(name)) return false;

    categories.remove(name);

    if (!categories.contains('Personal')) {
      categories.insert(0, 'Personal');
    }

    final notes = await getNotes();

    for (final note in notes) {
      if (note.category == name) {
        note.category = 'Personal';
        note.updatedAt = DateTime.now();
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoryKey, categories);
    await _saveAll(notes);

    // Remove the deleted category's saved icon.
    final icons = await getCategoryIcons();
    if (icons.remove(name) != null) {
      await prefs.setString(_categoryIconsKey, jsonEncode(icons));
    }

    return true;
  }

  // CATEGORY COUNT
  Future<int> getCategoryCount(String category) async {
    final notes = await getNotes();
    return notes.where((n) => n.category == category).length;
  }
}