// screens/order/order_history.dart
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;
          if (orders.isEmpty) return const Center(child: Text("No orders yet."));

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final data = orders[i].data();
              final items = List.from(data['items']);
              final paymentId = data['paymentId'] ?? 'N/A';
              final total = data['total'] ?? 0;
              final timestamp = DateTime.tryParse(data['timestamp']) ?? DateTime.now();
              final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.shopping_bag, color: Colors.deepPurple),
                          Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 12))
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("🧾 Payment ID: $paymentId", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text("🛍️ Items:", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ...items.map((item) => Text("- ${item['name']} (₹${item['price']})")),
                      const SizedBox(height: 6),
                      Text("💰 Total: ₹$total", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => generatePdfReceipt(data, context, saveToFile: false),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text("View Receipt"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () => generatePdfReceipt(data, context, saveToFile: true),
                            icon: const Icon(Icons.download),
                            label: const Text("Save PDF"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> generatePdfReceipt(Map<String, dynamic> order, BuildContext context, {bool saveToFile = false}) async {
    final pdf = pw.Document();
    final date = DateFormat('dd MMM yyyy, hh:mm a')
        .format(DateTime.tryParse(order['timestamp']) ?? DateTime.now());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("🧾 Bazario Receipt", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text("Date: $date"),
              pw.Text("Payment ID: ${order['paymentId'] ?? 'N/A'}"),
              pw.SizedBox(height: 16),
              pw.Text("Items:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...List.from(order['items']).map<pw.Widget>((item) {
                return pw.Text("- ${item['name']} (₹${item['price']})");
              }),
              pw.SizedBox(height: 12),
              pw.Text("Total Amount: ₹${order['total']}", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      ),
    );

    if (saveToFile) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Storage permission denied.")));
        return;
      }

      final directory = await getExternalStorageDirectory();
      final filePath = "${directory!.path}/bazario_receipt_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PDF Saved to $filePath")));
    } else {
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    }
  }
}
