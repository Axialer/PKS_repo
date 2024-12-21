import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  final String baseUrl = 'http://localhost:8080';

  Future<UserModel> register(
      String username, String email, String password) async {
    try {
      print('Отправка запроса регистрации: $baseUrl/user/register');
      final response = await http.post(
        Uri.parse('$baseUrl/user/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password_hash': password,
        }),
      );

      print('Статус ответа: ${response.statusCode}');
      print('Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final registerData = jsonDecode(response.body);
        final userId = registerData['user_id'];

        // Получаем данные пользователя после успешной регистрации
        return await getUserInfo(userId);
      } else {
        final error =
            jsonDecode(response.body)['error'] ?? 'Неизвестная ошибка';
        throw Exception(error);
      }
    } catch (e) {
      print('Ошибка при регистрации: $e');
      rethrow;
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      print('Отправка запроса входа: $baseUrl/user/login');
      final response = await http.post(
        Uri.parse('$baseUrl/user/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Статус ответа: ${response.statusCode}');
      print('Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Создаем объект UserModel с полученными данными
        return UserModel(
          userId: data['user_id'],
          username: data['username'],
          email: data['email'],
          createdAt: DateTime.parse(data['created_at']),
          // Не передаем passwordHash, так как его нет в ответе
        );
      } else {
        final error =
            jsonDecode(response.body)['error'] ?? 'Неизвестная ошибка';
        throw Exception(error);
      }
    } catch (e) {
      print('Ошибка при входе: $e');
      rethrow;
    }
  }

  Future<UserModel> getUserInfo(int userId) async {
    try {
      print('Получение информации о пользователе: $baseUrl/user/$userId');
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Статус ответа getUserInfo: ${response.statusCode}');
      print('Тело ответа getUserInfo: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel(
          userId: data['user_id'],
          username: data['username'],
          email: data['email'],
          createdAt: DateTime.parse(data['created_at']),
          // Не передаем passwordHash, так как его нет в ответе
        );
      } else {
        final error =
            jsonDecode(response.body)['error'] ?? 'Неизвестная ошибка';
        throw Exception(error);
      }
    } catch (e) {
      print('Ошибка при получении данных пользователя: $e');
      rethrow;
    }
  }
}
