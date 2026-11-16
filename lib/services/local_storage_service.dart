
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_model.dart';

class NoteService {
  static const String _storageKey = 'simplynote_saved_notes';

  Future<List<NoteModel>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final String? storedData = prefs.getString(_storageKey);

    if (storedData == null || storedData.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(storedData);

      return decoded
          .map((item) => NoteModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNote(NoteModel note) async {
    final notes = await getNotes();

    final index = notes.indexWhere(
      (item) => item.id == note.id,
    );

    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.add(note);
    }

    await _saveAll(notes);
  }

  Future<void> deleteNote(String id) async {
    final notes = await getNotes();

    notes.removeWhere((note) => note.id == id);

    await _saveAll(notes);
  }

  Future<void> togglePin(String id) async {
    final notes = await getNotes();

    final index = notes.indexWhere((note) => note.id == id);

    if (index == -1) return;

    notes[index].isPinned = !notes[index].isPinned;
    notes[index].updatedAt = DateTime.now();

    await _saveAll(notes);
  }

  Future<void> toggleFavorite(String id) async {
    final notes = await getNotes();

    final index = notes.indexWhere((note) => note.id == id);

    if (index == -1) return;

    notes[index].isFavorite = !notes[index].isFavorite;
    notes[index].updatedAt = DateTime.now();

    await _saveAll(notes);
  }

  Future<void> _saveAll(List<NoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      notes.map((note) => note.toJson()).toList(),
    );

    await prefs.setString(_storageKey, encoded);
  }
}
