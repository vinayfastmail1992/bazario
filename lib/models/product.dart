class Product {
  final String id;
  final String name;
  final double price;
  final String image;

  Product({required this.id, required this.name, required this.price, required this.image});

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
    );
  }
}
