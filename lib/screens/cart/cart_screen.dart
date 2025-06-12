import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../order/order_summary.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: cart.items.isEmpty
          ? const Center(child: Text("Cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: cart.items.values.map((product) {
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text("₹ ${product.price}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => cart.removeFromCart(product.id),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("Total: ₹ ${cart.total.toStringAsFixed(2)}"),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderSummary()));
                        },
                        child: const Text("Checkout"),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
