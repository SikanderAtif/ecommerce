class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageURL;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageURL,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] ?? 0),
      imageURL: json['image_url'] ?? '',
    );
  }
}
