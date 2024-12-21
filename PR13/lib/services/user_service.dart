import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class UserService {
  static const String _apiBaseUrl = 'http://localhost:8080'; // Ваш API сервер
  static const String _userIdKey = 'userId';
  static const String _emailKey = 'email';
  static const String _usernameKey = 'username';
  static const String _isAuthenticatedKey = 'isAuthenticated';

  /// Получение текущего ID пользователя
  static Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);

    if (userId == null || !(await isAuthenticated())) {
      throw Exception('Пользователь не авторизован');
    }

    return userId;
  }

  /// Получение данных пользователя из SharedPreferences
  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!(await isAuthenticated())) {
      throw Exception('Пользователь не авторизован');
    }

    String? userId = prefs.getString(_userIdKey);
    String? email = prefs.getString(_emailKey);
    String? username = prefs.getString(_usernameKey);

    if (userId == null || email == null || username == null) {
      throw Exception('Пользователь не найден в SharedPreferences');
    }

    return {'user_id': userId, 'email': email, 'username': username};
  }

  /// Загрузка данных пользователя с сервера
  static Future<Map<String, String>> fetchUserData(String userId) async {
    if (!(await isAuthenticated())) {
      throw Exception('Пользователь не авторизован');
    }

    final response = await http.get(Uri.parse('$_apiBaseUrl/user/$userId'));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // Сохраняем данные локально
      await saveUserData(responseData['user_id'].toString(),
          responseData['email'], responseData['username']);

      return {
        'user_id': responseData['user_id'].toString(),
        'email': responseData['email'],
        'username': responseData['username'],
      };
    } else {
      throw Exception('Ошибка загрузки д��нных пользователя: ${response.body}');
    }
  }

  /// Добавление товара в корзину
  static Future<void> addToCart(String userId, Product product) async {
    try {
      if (!(await isAuthenticated())) {
        throw Exception('Необходима авторизация');
      }

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/cart/$userId'),
        body: json.encode({
          'product_id': product.id,
          'quantity': 1,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка добавления товара в корзину');
      }
    } catch (e) {
      print('Ошибка при добавлении товара в корзину: $e');
      throw Exception('Ошибка при добавлении товара в корзину');
    }
  }

  /// Удаление товара из корзины
  static Future<void> removeFromCart(String userId, Product product) async {
    try {
      if (!(await isAuthenticated())) {
        throw Exception('Необходима авторизация');
      }

      // Сначала получаем все товары в корзине чтобы найти cartId
      final cartResponse = await http.get(
        Uri.parse('$_apiBaseUrl/cart/$userId'),
      );

      if (cartResponse.statusCode == 200) {
        final List<dynamic> cartItems = json.decode(cartResponse.body);
        // Ищем cart_id для данного product_id
        final cartItem = cartItems.firstWhere(
          (item) => item['product_id'] == product.id,
          orElse: () => {},
        );

        if (cartItem.containsKey('cart_id')) {
          print(
              'Удаление товара из корзины: userId=$userId, cartId=${cartItem['cart_id']}');
          final response = await http.delete(
            Uri.parse('$_apiBaseUrl/cart/$userId/${cartItem['cart_id']}'),
          );

          if (response.statusCode != 200) {
            throw Exception('Ошибка удаления товара из корзины');
          }
          // Обновляем состояние в кэше
          await _updateProductInCartStatus(userId, product.id!, false);
        } else {
          print('Товар не найден в корзине');
        }
      } else {
        throw Exception('Ошибка получения данных корзины');
      }
    } catch (e) {
      print('Ошибка при удалении товара из корзины: $e');
      throw Exception('Ошибка при удалении товара из корзины');
    }
  }

  /// Добавление товара в избранное
  static Future<void> addToFavorites(String userId, Product product) async {
    try {
      if (!(await isAuthenticated())) {
        throw Exception('Необходима авторизация');
      }

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/favorites/$userId'),
        body: json.encode({
          'product_id': product.id,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Ошибка добавления товара в избранное');
      }
    } catch (e) {
      print('Ошибка при добавлении товара в избранное: $e');
      throw Exception('Ошибка при добавлении товара в избранное');
    }
  }

  /// Удаление товара из избранного
  static Future<void> removeFromFavorites(
      String userId, Product product) async {
    try {
      if (!(await isAuthenticated())) {
        throw Exception('Необхо��има авторизация');
      }

      print(
          'Удаление товара из избранного: userId=$userId, productId=${product.id}');
      final response = await http.delete(
        Uri.parse('$_apiBaseUrl/favorites/$userId/${product.id}'),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка удаления товара из избранного');
      }
      // Обновляем состояние в кэше
      await _updateProductInFavoritesStatus(userId, product.id!, false);
    } catch (e) {
      print('Ошибка при удалении товара из избранного: $e');
      throw Exception('Ошибка при удалении товара из избранного');
    }
  }

  /// Проверка, есть ли товар в корзине
  static Future<bool> isProductInCart(String userId, int productId) async {
    try {
      if (!(await isAuthenticated())) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final key = 'cart_${userId}_$productId';
      final cachedStatus = prefs.getBool(key);

      if (cachedStatus != null) {
        return cachedStatus;
      }

      // Если нет в кэше, проверяем на сервере
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/cart/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> cartItems = json.decode(response.body);
        final isInCart =
            cartItems.any((item) => item['product_id'] == productId);
        await _updateProductInCartStatus(userId, productId, isInCart);
        return isInCart;
      }
      return false;
    } catch (e) {
      print('Ошибка при проверке товара в корзине: $e');
      return false;
    }
  }

  /// Проверка, есть ли товар в избранном
  static Future<bool> isProductInFavorites(String userId, int productId) async {
    try {
      if (!(await isAuthenticated())) {
        return false;
      }

      // Сначала получаем все избранные товары
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/favorites/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> favoriteItems = json.decode(response.body);
        // Проверяем, есть ли товар с таким ID в избранном
        return favoriteItems.any((item) => item['product_id'] == productId);
      }
      return false;
    } catch (e) {
      print('Ошибка при проверке товара в избранном: $e');
      return false;
    }
  }

  /// Обновление данных пользователя после авторизации
  static Future<void> saveUserData(
      String userId, String email, String username) async {
    final prefs = await SharedPreferences.getInstance();

    // Сначала очщаем старые данные
    await clearUserData();

    // Сохраняем новые данные
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_usernameKey, username);
    await prefs.setBool(_isAuthenticatedKey, true);

    // Проверяем, что все данные сохранились корректно
    final savedUserId = prefs.getString(_userIdKey);
    final savedEmail = prefs.getString(_emailKey);
    final savedUsername = prefs.getString(_usernameKey);
    final isAuth = prefs.getBool(_isAuthenticatedKey);

    print('Проверка сохраненных данных:');
    print('userId: $savedUserId');
    print('email: $savedEmail');
    print('username: $savedUsername');
    print('isAuthenticated: $isAuth');

    if (savedUserId == null ||
        savedEmail == null ||
        savedUsername == null ||
        !isAuth!) {
      throw Exception('Ошибка сохранения данных пользователя');
    }
  }

  /// Очистка данных пользователя
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_isAuthenticatedKey);
  }

  /// Проверка авторизации пользователя
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAuthenticatedKey) ?? false;
  }

  // Вспомогательные методы для обновления состояния
  static Future<void> _updateProductInCartStatus(
      String userId, int productId, bool isInCart) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'cart_${userId}_$productId';
    await prefs.setBool(key, isInCart);
  }

  static Future<void> _updateProductInFavoritesStatus(
      String userId, int productId, bool isInFavorites) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'favorites_${userId}_$productId';
    await prefs.setBool(key, isInFavorites);
  }
}
