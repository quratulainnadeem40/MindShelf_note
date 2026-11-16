
class NoteModel {
  final String id;
  String title;
  String content;
  String category;
  int colorValue;
  bool isPinned;
  bool isFavorite;
  DateTime createdAt;
  DateTime updatedAt;

  // Optional image attached to the note
  String? imagePath;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.colorValue,
    this.isPinned = false,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'Personal',
      colorValue: json['colorValue'] ?? 0xFFF6E0DF,
      isPinned: json['isPinned'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.now(),
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'colorValue': colorValue,
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imagePath': imagePath,
    };
  }
}
