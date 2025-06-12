// screens/auth/otp_screen.dart
import '../product_list.dart';
import '../admin_orders_pdf.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  const OTPScreen({super.key, required this.verificationId});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: otpController, decoration: const InputDecoration(labelText: '6-digit OTP')),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              try {
                final credential = PhoneAuthProvider.credential(
                  verificationId: widget.verificationId,
                  smsCode: otpController.text.trim(),
                );
                await FirebaseAuth.instance.signInWithCredential(credential);

                final user = FirebaseAuth.instance.currentUser;
                final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

                if (doc.exists && doc['role'] == 'admin') {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminOrdersPDFScreen()));
                } else {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductList()));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Verify & Login"),
          )
        ]),
      ),
    );
  }
}
