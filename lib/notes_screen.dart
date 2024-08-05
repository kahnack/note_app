import 'package:flutter/material.dart';
import 'package:note_app/googe_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'providers/notes_provider.dart';
import 'note_edit_screen.dart';
import 'models/note.dart';


class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _searchQuery = '';
  final GoogleSignInService googleSignInService = GoogleSignInService();

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
    });
  }

  void _showNoteMenu(Note note, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteEditScreen(index: index),
                    ),
                  );
                  //Navigator.pop(context); // Close the bottom sheet
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  final notesProvider =
                      Provider.of<NotesProvider>(context, listen: false);
                  notesProvider.delete(index);
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Duplicate'),
                onTap: () {
                  final notesProvider =
                      Provider.of<NotesProvider>(context, listen: false);
                  final newNote = Note(
                    title: '${note.title} (Copy)',
                    content: note.content,
                    lastUpdated: DateTime.now(),
                  );
                  notesProvider.add(newNote);
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortingOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sort by Date Descending'),
                onTap: () {
                  Provider.of<NotesProvider>(context, listen: false)
                      .setSorting('dateDescending');
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
              ListTile(
                title: const Text('Sort by Date Ascending'),
                onTap: () {
                  Provider.of<NotesProvider>(context, listen: false)
                      .setSorting('dateAscending');
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);

    final filteredNotes = notesProvider.notes.where((note) {
      final titleLower = note.title.toLowerCase();
      final contentLower = note.content.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return titleLower.contains(queryLower) ||
          contentLower.contains(queryLower);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'YourCustomFont',
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.cloud),
          onPressed: () async {
            final account = await googleSignInService.signIn();
            if (account != null) {
              // Successfully signed in
              // Here you could integrate cloud saving logic
              print('Signed in with Google: ${account.email}');
            } else {
              // Sign-in failed
              print('Failed to sign in with Google');
            }
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'sort') {
                _showSortingOptions();
              } else if (value == 'settings') {
                _showSortingOptions();
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => SettingsPage()),
                // );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'sort',
                  child: Text('Sort'),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('Settings'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search notes',
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              controller: TextEditingController(text: _searchQuery),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return ListTile(
                  title: Text(
                    note.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('d MMMM yyyy').format(note.lastUpdated),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                          Text(
                            DateFormat('HH:mm').format(note.lastUpdated),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onLongPress: () => _showNoteMenu(note, index),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteEditScreen(index: index),
                      ),
                    );
                    // Navigator.pop(context); // Close the bottom sheet
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NoteEditScreen()),
        ),
        tooltip: 'Add Note',
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add), // Customize as needed
      ),
    );
  }
}
