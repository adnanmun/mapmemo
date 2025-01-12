import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/note.dart';
import '../providers/note_provider.dart';

class NoteDetailScreen extends StatefulWidget {
  final int? noteIndex;

  const NoteDetailScreen({super.key, this.noteIndex});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    if (widget.noteIndex != null) {
      final note = noteProvider.notes[widget.noteIndex!];
      _titleController = TextEditingController(text: note.title);
      _contentController = TextEditingController(text: note.content);
      _imagePaths = List.from(note.imagePaths);
    } else {
      _titleController = TextEditingController();
      _contentController = TextEditingController();
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _imagePaths.addAll(pickedFiles.map((file) => file.path));
      });
    }
  }

  void _saveNote() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    if (_titleController.text.isNotEmpty) {
      final newNote = Note(
        id: widget.noteIndex != null ? noteProvider.notes[widget.noteIndex!].id : null,
        title: _titleController.text,
        content: _contentController.text,
        date: DateTime.now(),
        imagePaths: _imagePaths,
      );


      if (widget.noteIndex == null) {
        noteProvider.addNote(newNote);
      } else {
        noteProvider.updateNote(newNote);
      }
      Navigator.of(context).pop();
    }
  }

  void _openImageViewer() {
    if (_imagePaths.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewer(
            imagePaths: _imagePaths,
            onImageDeleted: (index) {
              setState(() {
                _imagePaths.removeAt(index);
              });
            },
          ),
        ),
      );
    }
  }

  Widget _buildImageGrid() {
    int imageCount = _imagePaths.length;
    List<Widget> gridItems = _imagePaths
        .take(4)
        .map((path) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(path), fit: BoxFit.cover),
            ))
        .toList();

    if (imageCount > 4) {
      gridItems[3] = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(_imagePaths[3]), fit: BoxFit.cover),
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Text(
                '+${imageCount - 4}',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _openImageViewer,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        children: gridItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Note')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildImageGrid(),
            ElevatedButton(
              onPressed: _pickImages,
              child: const Text('Pick Images'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveNote,
              child: const Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageViewer extends StatefulWidget {
  final List<String> imagePaths;
  final Function(int index) onImageDeleted;

  const ImageViewer({
    super.key,
    required this.imagePaths,
    required this.onImageDeleted,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  int _currentIndex = 0;

  void _navigateImages(int change) {
    setState(() {
      _currentIndex = (_currentIndex + change) % widget.imagePaths.length;
      if (_currentIndex < 0) _currentIndex = widget.imagePaths.length - 1;
    });
  }

  void _deleteImage() {
    if (widget.imagePaths.isNotEmpty) {
      widget.onImageDeleted(_currentIndex);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Viewer')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                children: [
                  Image.file(File(widget.imagePaths[_currentIndex])),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: _deleteImage,
                    ),
                  )
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () => _navigateImages(-1),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: () => _navigateImages(1),
              ),
            ],
          ),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.imagePaths.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: _currentIndex == index
                              ? Colors.blue
                              : Colors.transparent),
                    ),
                    child: Image.file(File(widget.imagePaths[index]),
                        width: 60, height: 60, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
