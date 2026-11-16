
class NoteModel {
  final String id;
  String title;
  String content;
  String category;
  int colorValue;

  bool isPinned;
  bool isFavorite;
  bool isDeleted;

  DateTime createdAt;
  DateTime updatedAt;

  String? contentDelta;
  String? imagePath;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.colorValue,
    this.isPinned = false,
    this.isFavorite = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.contentDelta,
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
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.tryParse(
            json['createdAt'] ?? '',
          ) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
            json['updatedAt'] ?? '',
          ) ??
          DateTime.now(),
      contentDelta: json['contentDelta'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'contentDelta': contentDelta,
      'category': category,
      'colorValue': colorValue,
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imagePath': imagePath,
    };
  }
}
