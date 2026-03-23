class Note {
  final String id;
  final String title;
  final String content;
  final String? slug;
  final String? createdAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.slug,
    this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id:        json['_id'] as String,
      title:     json['title'] as String,
      content:   json['content'] as String,
      slug:      json['slug'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id':       id,
    'title':     title,
    'content':   content,
    'slug':      slug,
    'createdAt': createdAt,
  };

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? slug,
    String? createdAt,
  }) {
    return Note(
      id:        id        ?? this.id,
      title:     title     ?? this.title,
      content:   content   ?? this.content,
      slug:      slug      ?? this.slug,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}