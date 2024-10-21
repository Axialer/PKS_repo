import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: LoginPage(),
    debugShowCheckedModeBanner: false, // Убираем надпись debug
    theme: ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Color(0xFF2C2C2C), // Темно-серый фон
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF424242), // Темно-серый для полей ввода
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
      ),
    ),
  ));
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 50),
            Center(
              child: Text(
                'Авторизация', // Заменяем изображение на текст
                style: TextStyle(
                  color: Colors.white, // Белый цвет текста
                  fontSize: 32, // Размер шрифта
                  fontWeight: FontWeight.bold, // Жирный текст
                ),
              ),
            ),
            SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _loginController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Логин',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите логин';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите пароль';
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                      Text(
                        'Запомнить меня',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Обработка входа
                        print('Логин: ${_loginController.text}, Пароль: ${_passwordController.text}');
                      }
                    },
                    child: Text('Войти'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Обработка перехода на страницу регистрации
                    },
                    child: Text('Регистрация', style: TextStyle(color: Colors.blueAccent)),
                  ),
                  TextButton(
                    onPressed: () {
                      // Обработка восстановления пароля
                    },
                    child: Text('Восстановить пароль', style: TextStyle(color: Colors.blueAccent)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
