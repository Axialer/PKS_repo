import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/cart_model.dart';

class CartPage extends StatelessWidget {
  final CartModel cartModel;

  CartPage({required this.cartModel});

  // Функция для отображения окна подтверждения удаления
  void _showDeleteConfirmationDialog(BuildContext context, CartItem cartItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove Item"),
          content: Text("Are you sure you want to remove this item from the cart?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Remove", style: TextStyle(color: Colors.red)),
              onPressed: () {
                cartModel.decreaseQuantity(cartItem.product);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: cartModel.items.isEmpty
          ? Center(child: Text('Your cart is empty.'))
          : ListView.builder(
        itemCount: cartModel.items.length,
        itemBuilder: (context, index) {
          final cartItem = cartModel.items[index];
          return Slidable(
            endActionPane: ActionPane(
              motion: DrawerMotion(),
              extentRatio: 0.35,
              children: [
                SlidableAction(
                  onPressed: (context) {
                    _showDeleteConfirmationDialog(context, cartItem);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Remove',
                  borderRadius: BorderRadius.circular(10.0), // Закругленные углы
                ),
              ],
            ),
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: cartItem.product.images.isNotEmpty
                          ? Image.file(
                        File(cartItem.product.images[0]),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                          : Icon(Icons.image, size: 60),
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cartItem.product.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Price per unit: \$${cartItem.product.price.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            'Total: \$${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () {
                            cartModel.addProduct(cartItem.product);
                          },
                        ),
                        Text(
                          '${cartItem.quantity}',
                          style: TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            cartModel.decreaseQuantity(cartItem.product);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Total: \$${cartModel.totalPrice.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
