import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Импортируйте для использования SVG
import 'pages/cart_page.dart';
import 'pages/profile_page.dart';
import 'pages/catalog_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static final List<Widget> _pages = <Widget>[
    CatalogPage(),
    CartPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF1A6FEE), // Цвет текста выделенного блока
        unselectedItemColor: Colors.grey, // Цвет текста невыделенных блоков
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _selectedIndex == 0 ? 'assets/icons/Home_select.svg' : 'assets/icons/Home.svg',
              width: 32,
              height: 32,
            ),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _selectedIndex == 1 ? 'assets/icons/Cart_select.svg' : 'assets/icons/Cart.svg',
              width: 32,
              height: 32,
            ),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _selectedIndex == 2 ? 'assets/icons/user_select.svg' : 'assets/icons/user.svg',
              width: 32,
              height: 32,
            ),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
