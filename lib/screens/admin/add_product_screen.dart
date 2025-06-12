import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  File? _pickedImage;
  bool _uploading = false;

  Future<void> pickAndUploadImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _uploading = true);
      final file = File(picked.path);
      final filename = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child("products/$filename.jpg");
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      setState(() {
        _pickedImage = file;
        imageUrlController.text = url;
        _uploading = false;
      });
    }
  }

  Future<void> addProduct() async {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0.0;
    final image = imageUrlController.text.trim();

    if (name.isEmpty || image.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")));
      return;
    }

    await FirebaseFirestore.instance.collection('products').add({
      'name': name,
      'price': price,
      'image': image,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Product Uploaded")));

    nameController.clear();
    priceController.clear();
    imageUrlController.clear();
    setState(() => _pickedImage = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin: Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _pickedImage != null
                ? Image.file(_pickedImage!, height: 120)
                : const Placeholder(fallbackHeight: 120),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _uploading ? null : pickAndUploadImage,
              child: Text(_uploading ? "Uploading..." : "Upload Image"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addProduct,
              child: const Text("Save Product"),
            ),
          ],
        ),
      ),
    );
  }
}
