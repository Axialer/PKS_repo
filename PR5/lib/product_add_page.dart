import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'product_data.dart';

class AddProductPage extends StatefulWidget {
  final Function(Product) onAdd;

  AddProductPage({required this.onAdd});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  double _price = 0.0;
  List<String> _images = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _images.add(pickedFile.path);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _name,
        description: _description,
        price: _price,
        images: _images,
        reviews: [],
      );
      widget.onAdd(newProduct);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Product Name'),
                onSaved: (value) => _name = value!,
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Product Description'),
                onSaved: (value) => _description = value!,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Product Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _price = double.parse(value!),
                validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Image.file(File(_images[index]), width: 50, height: 50),
                      title: Text('Image ${index + 1}'),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
