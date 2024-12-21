import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import '../widgets/product_card.dart';
import 'add_product_page.dart'; // Страница добавления нового продукта
import 'product_details_page.dart'; // Страница деталей товара
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late Future<List<Product>> _products;
  final Set<int> _favorites = {};
  final Set<int> _cart = {};

  // Добавляем контроллер для поискового поля
  final TextEditingController _searchController = TextEditingController();

  // Состояния для фильтрации и сортировки
  String _searchQuery = '';
  String _sortBy = 'name'; // 'name' или 'price'
  bool _sortAscending = true;
  double _minPrice = 0;
  double _maxPrice = double.infinity;

  @override
  void initState() {
    super.initState();
    _fetchProducts();

    // Добавляем слушатель изменений текста поиска
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchProducts() {
    setState(() {
      _products = ApiService.fetchProducts();
    });
  }

  // Фильтрация и сортировка продуктов
  List<Product> _filterAndSortProducts(List<Product> products) {
    return products.where((product) {
      // Фильтрация по поиску
      final matchesSearch =
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      // Фильтрация по цене
      final matchesPrice =
          product.price >= _minPrice && product.price <= _maxPrice;
      return matchesSearch && matchesPrice;
    }).toList()
      ..sort((a, b) {
        int comparison;
        if (_sortBy == 'name') {
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        } else {
          comparison = a.price.compareTo(b.price);
        }
        return _sortAscending ? comparison : -comparison;
      });
  }

  void _handleProductTap(int productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(productId: productId),
      ),
    );
  }

  // Добавление товара в корзину
  void _addToCart(Product product) async {
    final userId = await UserService.getCurrentUserId();
    final url = Uri.parse('http://localhost:8080/cart/$userId');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'product_id': product.id,
          'quantity': 1,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _cart.add(product.id!);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} добавлен в корзину!')),
        );
      } else {
        throw Exception('Ошибка при добавлении товара в корзину');
      }
    } catch (e) {
      print('Ошибка при добавлении товара в корзину: $e');
    }
  }

  Future<void> _removeFromCart(Product product) async {
    final userId = await UserService.getCurrentUserId();
    setState(() {
      _cart.remove(product.id!);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} удалён из корзины!')),
    );
    UserService.removeFromCart(userId, product);
  }

  Future<void> _addToFavorites(Product product) async {
    final userId = await UserService.getCurrentUserId();
    setState(() {
      _favorites.add(product.id!);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} добавлен в избранное!')),
    );
    UserService.addToFavorites(userId, product);
  }

  Future<void> _removeFromFavorites(Product product) async {
    final userId = await UserService.getCurrentUserId();
    setState(() {
      _favorites.remove(product.id!);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} удалён из избранного!')),
    );
    UserService.removeFromFavorites(userId, product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Товары'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final bool? isProductAdded = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductPage()),
              );
              if (isProductAdded == true) {
                _fetchProducts();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск товаров...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _sortBy,
                  items: [
                    DropdownMenuItem(value: 'name', child: Text('По имени')),
                    DropdownMenuItem(value: 'price', child: Text('По цене')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(_sortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward),
                  onPressed: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                    });
                  },
                ),
                Expanded(
                  child: RangeSlider(
                    values: RangeValues(_minPrice,
                        _maxPrice == double.infinity ? 1000 : _maxPrice),
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      _minPrice.round().toString(),
                      _maxPrice == double.infinity
                          ? "∞"
                          : _maxPrice.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _minPrice = values.start;
                        _maxPrice = values.end;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Товары не найдены.'));
                }

                final filteredProducts = _filterAndSortProducts(snapshot.data!);

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isFavorite = _favorites.contains(product.id);
                    final isInCart = _cart.contains(product.id);

                    return GestureDetector(
                      onTap: () => _handleProductTap(product.id!),
                      child: ProductCard(
                        product: product,
                        onAddToCart: isInCart ? _removeFromCart : _addToCart,
                        onAddToFavorites:
                            isFavorite ? _removeFromFavorites : _addToFavorites,
                        isFavorite: isFavorite,
                        isInCart: isInCart,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
