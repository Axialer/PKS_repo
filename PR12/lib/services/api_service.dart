import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  // Получение всех продуктов
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      final List<dynamic> productList = jsonDecode(response.body);
      print('Данные из API: $productList'); // Логируем данные
      return productList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products: ${response.reasonPhrase}');
    }
  }

  // Получение продукта по ID
  static Future<Product> fetchProductById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode == 200) {
      final product = Product.fromJson(jsonDecode(response.body));
      print('Данные товара: ${product.toJson()}'); // Логируем данные
      return product;
    } else {
      throw Exception('Failed to load product: ${response.reasonPhrase}');
    }
  }

  // Добавление нового продукта
  static Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add product: ${response.reasonPhrase}');
    }
  }

  // Обновление продукта (оставляем один метод)
  static Future<void> updateProduct(int id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'), // Убедитесь, что ID передается в URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()), // Передаем данные в теле запроса
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update product: ${response.reasonPhrase}');
    }
  }

  // Удаление продукта
  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Не удалось удалить продукт');
    }
  }
}
