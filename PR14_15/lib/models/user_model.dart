class UserModel {
  final int userId;
  final String username;
  final String email;
  final DateTime createdAt;
  final String? passwordHash;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.createdAt,
    this.passwordHash,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      passwordHash: json['password_hash'],
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'username': username,
        'email': email,
        'created_at': createdAt.toIso8601String(),
        if (passwordHash != null) 'password_hash': passwordHash,
      };
}
