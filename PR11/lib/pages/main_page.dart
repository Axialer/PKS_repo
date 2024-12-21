import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import 'cart_page.dart';
import 'favorites_page.dart';
import 'user_page.dart';
import 'products_page.dart';
import '../services/user_service.dart';

class MainPage extends StatefulWidget {
  final UserModel? initialUser;

  const MainPage({Key? key, this.initialUser}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.initialUser;
  }

  Future<void> _login() async {
    final user = await Navigator.pushNamed(context, '/auth') as UserModel?;
    if (user != null && mounted) {
      try {
        // Очищаем старые данные и сохраняем новые
        await UserService.clearUserData(); // Явно очищаем старые данные
        await UserService.saveUserData(
          user.userId.toString(),
          user.email,
          user.username,
        );

        // Проверяем, что данные сохранились
        final isAuth = await UserService.isAuthenticated();
        print('Пользователь авторизован: $isAuth');

        if (!isAuth) {
          throw Exception('Ошибка авторизации');
        }

        // Проверяем сохраненные данные
        final savedData = await UserService.getUserData();
        print('Сохраненные данные: $savedData');

        if (mounted) {
          setState(() {
            _currentUser = user;
          });
        }
      } catch (e) {
        print('Ошибка при сохранении данных пользователя: $e');
        // Очищаем данные в случае ошибки
        await UserService.clearUserData();
        if (mounted) {
          setState(() {
            _currentUser = null;
          });
        }
      }
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const ProductsPage();
      case 1:
        return _currentUser == null
            ? _buildLoginPrompt()
            : CartPage(user: _currentUser!);
      case 2:
        return _currentUser == null
            ? _buildLoginPrompt()
            : FavoritesPage(user: _currentUser!);
      case 3:
        return _currentUser == null
            ? _buildLoginPrompt()
            : UserPage(user: _currentUser!);
      default:
        return const Center(child: Text('Страница не найдена'));
    }
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Для доступа необходимо войти'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _login,
            child: const Text('Войти'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Избранное',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
