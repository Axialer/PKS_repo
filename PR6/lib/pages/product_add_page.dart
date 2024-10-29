import 'package:flutter/material.dart';
import '../models/product_data.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductAddPage extends StatelessWidget {
  final Function(Product) onAdd;

  ProductAddPage({required this.onAdd});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<String> images = [];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      images.add(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Product Name')),
            TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
            TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
            ElevatedButton(onPressed: _pickImage, child: Text('Add Image')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newProduct = Product(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: nameController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  images: images,
                  description: descriptionController.text,
                  reviews: [],
                );
                onAdd(newProduct);
                Navigator.pop(context);
              },
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
