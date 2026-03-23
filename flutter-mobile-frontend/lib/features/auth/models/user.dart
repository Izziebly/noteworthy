class User {
  final String id;
  final String username;

  const User({
    required this.id,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:       json['_id'] as String,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id':      id,
    'username': username,
  };

  User copyWith({
    String? id,
    String? username,
  }) {
    return User(
      id:       id       ?? this.id,
      username: username ?? this.username,
    );
  }
}