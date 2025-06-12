// services/secure_checkout_helper.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
// services/secure_checkout_helped.:c
// lib/services/secure_checkout_helper.dart


class SecureRazorpayCheckout {
  final Razorpay _razorpay = Razorpay();

  SecureRazorpayCheckout() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() => _razorpay.clear();

  Future<void> openSecureCheckout(double amount, BuildContext context) async {
    final int amountInPaise = (amount * 100).toInt();

    final response = await http.post(
      Uri.parse('https://<YOUR_PROJECT>.cloudfunctions.net/createOrder'), // ✅ यहां अपना Firebase Function URL डालें
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amountInPaise}),
    );

    if (response.statusCode == 200) {
      final order = jsonDecode(response.body);

      var options = {
        'key': 'rzp_live_YourLiveKeyID', // ✅ यहां Live Key ID लगाएँ
        'amount': order['amount'],
        'order_id': order['id'],
        'name': 'Bazario',
        'description': 'Secure Order Payment',
        'prefill': {
          'contact': '9999999999',
          'email': FirebaseAuth.instance.currentUser?.email ?? 'test@example.com',
        },
      };

      _razorpay.open(options);
    } else {
      debugPrint('Server error: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Server Error!")));
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint("✅ Payment Success: ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("❌ Payment Failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("💳 Wallet: ${response.walletName}");
  }
}
