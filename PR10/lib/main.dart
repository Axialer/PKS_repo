import 'package:flutter/material.dart';
import 'pages/main_page.dart';
import 'services/user_service.dart'; // Импорт UserService

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Убедитесь, что все асинхронные операции инициализации завершены
  await UserService.getCurrentUserId(); // Создаём или получаем текущего пользователя при запуске приложения
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Shopping App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
    );
  }
}
