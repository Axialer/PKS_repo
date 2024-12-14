import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Профиль')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/user.png')),
            Text('Имя пользователя'),
            Text('Email: user@example.com'),
          ],
        ),
      ),
    );
  }
}
