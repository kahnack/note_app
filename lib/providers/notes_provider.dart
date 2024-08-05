import 'package:flutter/material.dart';
import '../models/note.dart';
import 'package:hive/hive.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  String _sorting = 'dateDescending'; // Default sorting by date descending

  List<Note> get notes {
    // Return sorted notes based on the current sorting
    List<Note> sortedNotes = List.from(_notes);
    if (_sorting == 'dateDescending') {
      sortedNotes.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    } else if (_sorting == 'dateAscending') {
      sortedNotes.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
    }
    return sortedNotes;
  }

  Future<void> loadNotes() async {
    final box = Hive.box('notes');
    _notes = box.values.cast<Note>().toList();
    notifyListeners();
  }

  void add(Note note) {
    final box = Hive.box('notes');
    box.add(note);
    _notes.add(note);
    notifyListeners();
  }

  void update(int index, Note note) {
    final box = Hive.box('notes');
    box.putAt(index, note);
    _notes[index] = note;
    notifyListeners();
  }

  void delete(int index) {
    final box = Hive.box('notes');
    box.deleteAt(index);
    _notes.removeAt(index);
    notifyListeners();
  }

  void setSorting(String sorting) {
    _sorting = sorting;
    notifyListeners();
  }
}
