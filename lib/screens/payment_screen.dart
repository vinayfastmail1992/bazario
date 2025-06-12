// screens/payment_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final int amount;
  final List<Map<String, dynamic>> cartItems; // List of products

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.cartItems,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    createOrder();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void createOrder() async {
    const cloudFunctionUrl = "https://us-central1-bazario-2b759.cloudfunctions.net/createOrder";

    try {
      var response = await http.post(
        Uri.parse(cloudFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "amount": widget.amount * 100,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        openCheckout(data['id']);
      } else {
        throw Exception("Failed to create Razorpay order");
      }
    } catch (e) {
      print("Order Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Error: $e")),
      );
    }
  }

  void openCheckout(String orderId) {
    var options = {
      'key': 'rzp_test_6fRiuUhQ6ksrm8',
      'amount': widget.amount * 100,
      'name': 'Bazario',
      'description': 'Order Payment',
      'order_id': orderId,
      'prefill': {
        'contact': '9123456789',
        'email': 'test@example.com'
      },
      'external': {'wallets': ['paytm']},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance.collection("orders").add({
          "userId": user.uid,
          "amount": widget.amount,
          "paymentId": response.paymentId,
          "timestamp": Timestamp.now(),
          "items": widget.cartItems,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order Placed Successfully!")),
        );

        Navigator.pop(context); // Back to home or cart screen
      }
    } catch (e) {
      print("Firestore Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save order: $e")),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
    Navigator.pop(context);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
