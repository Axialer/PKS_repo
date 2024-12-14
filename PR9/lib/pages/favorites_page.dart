// lib/pages/favorites_page.dart
import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Избранное'),
      ),
      body: Center(
        child: Text('Здесь будут ваши избранные товары'),
      ),
    );
  }
}
