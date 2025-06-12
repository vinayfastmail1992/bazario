import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// screens/admin/admin_orders_pdf.dart

class AdminOrdersPDFScreen extends StatelessWidget {
  const AdminOrdersPDFScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin - All Orders")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) return const Center(child: Text("No orders found."));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (_, index) {
                    final order = orders[index].data();
                    final items = List.from(order['items']);
                    final date = DateFormat('dd MMM yyyy, hh:mm a')
                        .format(DateTime.tryParse(order['timestamp']) ?? DateTime.now());

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("📅 $date", style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 6),
                            Text("🧾 Payment ID: ${order['paymentId'] ?? 'N/A'}"),
                            const SizedBox(height: 4),
                            Text("🛍️ Items:", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ...items.map((e) => Text("- ${e['name']} (₹${e['price']})")),
                            const SizedBox(height: 6),
                            Text("💰 Total: ₹${order['total']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton.icon(
                  onPressed: () => generatePDF(orders),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Download All Orders PDF"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void generatePDF(List<QueryDocumentSnapshot<Map<String, dynamic>>> orders) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Text("Bazario - All Orders", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            ...orders.map((orderDoc) {
              final order = orderDoc.data();
              final items = List.from(order['items']);
              final date = DateFormat('dd MMM yyyy, hh:mm a')
                  .format(DateTime.tryParse(order['timestamp']) ?? DateTime.now());

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("📅 $date", style: const pw.TextStyle(fontSize: 12)),
                  pw.Text("🧾 Payment ID: ${order['paymentId'] ?? 'N/A'}", style: const pw.TextStyle(fontSize: 12)),
                  pw.Text("🛍️ Items:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ...items.map<pw.Widget>((item) =>
                      pw.Text("- ${item['name']} (₹${item['price']})", style: const pw.TextStyle(fontSize: 11))),
                  pw.Text("💰 Total: ₹${order['total']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Divider(),
                  pw.SizedBox(height: 10),
                ],
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
