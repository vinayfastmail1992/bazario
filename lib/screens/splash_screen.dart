// screens/splash_screen.dart
import 'login_screen.dart';
import 'product_list.dart';
import 'admin_orders_pdf.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), checkLogin);
  }

  void checkLogin() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc['role'] == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminOrdersPDFScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProductList()));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Text("Bazario", style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
