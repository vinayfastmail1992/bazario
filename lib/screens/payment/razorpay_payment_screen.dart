// screens/payment/razorpay_payment_screen.dart
await FirebaseFirestore.instance.collection('orders').add({
  'userId' = user?.uid,
  'timestamp' = DateTime.now().toIso8601String(),
  'items' = cart.items.values.map((e) => {
    'name': e.name,
    'price': e.price,
    'image': e.image
  }).toList(),
  'total' = cart.total,
  'paymentId' = response.paymentId, // ✅ Add this line
  'status' = 'Paid'
});
