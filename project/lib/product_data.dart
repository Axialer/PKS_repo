import 'dart:convert';
import 'package:flutter/services.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final List<String> reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.reviews,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['image'],
      reviews: List<String>.from(json['reviews']),
    );
  }
}

class ProductRepository {
  static Future<List<Product>> loadProducts() async {
    final data = await rootBundle.loadString('asettes/products.json');
    final List<dynamic> productsJson = jsonDecode(data);
    return productsJson.map((json) => Product.fromJson(json)).toList();
  }
}
