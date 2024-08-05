import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:note_app/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/note.dart';
import 'notes_screen.dart';
import 'providers/notes_provider.dart';
//import 'package:google_fonts/google_fonts.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  await HiveService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotesProvider()..loadNotes(),
      child: MaterialApp(
        title: 'Notes App',
        themeMode: ThemeMode.dark, // or [ThemeMode.dark]
        theme: NordTheme.dark(),
        darkTheme: NordTheme.dark(),
        home: const NotesScreen(),
      ),
    );
  }
}
