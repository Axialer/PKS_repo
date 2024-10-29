import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onRemove;
  final ValueChanged<int> onUpdateQuantity;

  CartItemWidget({
    required this.cartItem,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      // Удаляем параметр actionPane, так как он больше не нужен
      key: ValueKey(cartItem.product.id),
      // Заменяем устаревшие методы и параметры на новые
      endActionPane: ActionPane(
        motion: const DrawerMotion(), // Используем DrawerMotion вместо SlidableDrawerActionPane
        extentRatio: 0.3, // Заменяем actionExtentRatio на extentRatio
        children: [
          SlidableAction(
            onPressed: (context) => onRemove(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete', // Заменяем IconSlideAction на SlidableAction
          ),
        ],
      ),
      child: ListTile(
        title: Text(cartItem.product.name),
        subtitle: Text('Quantity: ${cartItem.quantity}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (cartItem.quantity > 1) {
                  onUpdateQuantity(cartItem.quantity - 1);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                onUpdateQuantity(cartItem.quantity + 1);
              },
            ),
          ],
        ),
      ),
    );
  }
}
