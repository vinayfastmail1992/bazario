import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Status")),
      body: const Center(
        child: Text("✅ Payment Success!\nYour order is placed.", textAlign: TextAlign.center),
      ),
    );
  }
}
