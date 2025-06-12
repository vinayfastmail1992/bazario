import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Order Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...cart.items.values.map((p) => ListTile(
                  title: Text(p.name),
                  trailing: Text("₹ ${p.price}"),
                )),
            const Divider(),
            Text("Total Amount: ₹ ${cart.total.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                cart.items.clear();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Placed!")));
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Place Order"),
            )
          ],
        ),
      ),
    );
  }
}
