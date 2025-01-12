import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/note.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => List.unmodifiable(_notes);

  Future<void> addNote(Note note) async {
    _notes.add(note);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> updateNote(Note updatedNote) async {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id); 
    if (index != -1) {
      _notes[index] = updatedNote;
      await _saveNotes();
      notifyListeners();
    }
  }


  Future<void> deleteNote(int index) async {
    _notes.removeAt(index);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes');
    if (notesString != null) {
      final List<dynamic> decoded = jsonDecode(notesString);
      _notes = decoded.map((note) => Note.fromMap(note)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = jsonEncode(_notes.map((note) => note.toMap()).toList());
    prefs.setString('notes', notesString);
  }
}