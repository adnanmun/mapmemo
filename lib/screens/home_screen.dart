import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../screens/note_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<NoteProvider>(context, listen: false)
                  .deleteNote(index);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('PicNotes')),
      body: noteProvider.notes.isEmpty
          ? const Center(child: Text('No notes yet, add some!'))
          : ListView.builder(
              itemCount: noteProvider.notes.length,
              itemBuilder: (context, index) {
                final note = noteProvider.notes[index];
                // Format the date to show up to minutes
                final formattedDate = 
                    "${note.date.toLocal().toString().split(' ')[0]} ${note.date.toLocal().hour}:${note.date.toLocal().minute.toString().padLeft(2, '0')}";

                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(formattedDate),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoteDetailScreen(noteIndex: index),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(context, index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoteDetailScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
