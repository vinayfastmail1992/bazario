import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController addressController = TextEditingController();

  void saveAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'address': addressController.text.trim(),
    }, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Address Saved")));
  }

  void loadAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && doc['address'] != null) {
      addressController.text = doc['address'];
    }
  }

  @override
  void initState() {
    super.initState();
    loadAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Address")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Enter Address"),
              maxLines: 4,
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: saveAddress, child: const Text("Save Address")),
          ],
        ),
      ),
    );
  }
}
