import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/note_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteProvider()..loadNotes()),
      ],
      child: const NotesApp(),
    ),
  );
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PicNotes',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,  // <-- Added this line to remove the debug banner
      home: const HomeScreen(),
    );
  }
}
