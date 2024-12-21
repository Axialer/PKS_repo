import 'package:flutter/material.dart';
import 'pages/main_page.dart';
import 'pages/auth_page.dart';
import 'models/user_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          // Получаем пользователя из аргументов, если они есть
          final user = settings.arguments as UserModel?;
          return MaterialPageRoute(
            builder: (context) => MainPage(initialUser: user),
          );
        }
        if (settings.name == '/auth') {
          return MaterialPageRoute(
            builder: (context) => AuthPage(),
          );
        }
        return null;
      },
    );
  }
}
