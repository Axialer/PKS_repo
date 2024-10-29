// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import 'product_list_page.dart';
import 'favorites_page.dart';
import 'cart_page.dart';
import '../models/product_data.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Product> _products = [];

  void _addProduct(Product product) {
    setState(() {
      _products.add(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);

    final pages = [
      ProductListPage(
        products: _products,
        onAddProduct: _addProduct,
        onToggleFavorite: (product) => setState(() {
          product.isFavorite = !product.isFavorite;
        }),
        onDeleteProduct: (product) => setState(() {
          _products.remove(product);
        }),
        cartModel: cartModel, // Обязательно передаем cartModel
      ),
      FavoritesPage(
        favoriteProducts: _products.where((product) => product.isFavorite).toList(),
        onToggleFavorite: (product) => setState(() {
          product.isFavorite = !product.isFavorite;
        }),
      ),
      CartPage(cartModel: cartModel),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
      ),
    );
  }
}
