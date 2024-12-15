import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class UserService {
  static const String _apiBaseUrl = 'http://localhost:8080'; // Ваш API сервер
  static const String _userIdKey = 'user_id';

  /// Получение текущего ID пользователя или его создание
  static Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);

    if (userId == null) {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/user'),
        body: json.encode({
          'username': 'User${Random().nextInt(1000000)}',
          'email': '${Random().nextInt(1000000)}@example.com',
          'password_hash': 'randomhash',
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        userId = responseData['user_id'].toString(); // Преобразуем в строку
        await prefs.setString(_userIdKey, userId); // Сохраняем как строку
      } else {
        throw Exception('Ошибка создания пользователя: ${response.body}');
      }
    }

    print('Текущий userId: $userId');
    return userId!;
  }

  // Добавление товара в корзину
  static Future<void> addToCart(String userId, Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/cart/$userId'),
        body: json.encode({
          'product_id': product.id,
          'quantity': 1,  // Например, добавляем один товар
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

  // Удаление товара из корзины
  static Future<void> removeFromCart(String userId, Product product) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiBaseUrl/cart/$userId/${product.id}'),
      );
      if (response.statusCode != 200) {
        throw Exception('Ошибка удаления товара из корзины');
      }
    } catch (e) {
      print('Ошибка при удалении товара из корзины: $e');
      throw Exception('Ошибка при удалении товара из корзины');
    }
  }

  // Добавление товара в избранное
  static Future<void> addToFavorites(String userId, Product product) async {
    try {
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

  // Удаление товара из избранного
  static Future<void> removeFromFavorites(String userId, Product product) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiBaseUrl/favorites/$userId/${product.id}'),
      );
      if (response.statusCode != 200) {
        throw Exception('Ошибка удаления товара из избранного');
      }
    } catch (e) {
      print('Ошибка при удалении товара из избранного: $e');
      throw Exception('Ошибка при удалении товара из избранного');
    }
  }
}
