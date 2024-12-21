import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(AdminChatApp());
}

class AdminChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Начальная страница — страница входа
    );
  }
}
