import 'package:uuid/uuid.dart';

class Note {
  final String id; // Unique ID added
  final String title;
  final String content;
  final DateTime date;
  final List<String> imagePaths;

  Note({
    String? id,  // Allow automatic generation if not provided
    required this.title,
    required this.content,
    required this.date,
    required this.imagePaths,
  }) : id = id ?? const Uuid().v4(); // Generate a new ID if not provided

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'imagePaths': imagePaths,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']),
      imagePaths: List<String>.from(map['imagePaths']),
    );
  }
}
