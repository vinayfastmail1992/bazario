// screens/products/product_list.dart
import '../cart/cart_screen.dart';
import '../../models/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bazario Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          final products = docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, i) {
              final p = products[i];
              return Card(
                child: ListTile(
                  leading: Image.network(p.image, width: 50, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                  title: Text(p.name),
                  subtitle: Text("₹ ${p.price.toStringAsFixed(2)}"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addToCart(p);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${p.name} added to cart")));
                    },
                    child: const Text("Add"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
