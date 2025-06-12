// screens/auth/login_screen.dart
import 'otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bazario Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [
          const Text("📱 Phone Login", style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone (+91...)')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.verifyPhoneNumber(
                phoneNumber: phoneController.text.trim(),
                verificationCompleted: (PhoneAuthCredential credential) {},
                verificationFailed: (FirebaseAuthException e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
                },
                codeSent: (String verificationId, int? resendToken) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => OTPScreen(verificationId: verificationId)));
                },
                codeAutoRetrievalTimeout: (String verificationId) {},
              );
            },
            child: const Text("Send OTP"),
          ),

          const Divider(),

          const Text("📧 Email Login", style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logged in successfully")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Login with Email"),
          ),
        ]),
      ),
    );
  }
}
