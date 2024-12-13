class User {
  final String username;
  final String email;

  User({required this.username, required this.email});

  // Метод для создания пользователя из JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
    );
  }
}
