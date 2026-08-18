import 'package:ecommerce/models/category.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final Category category;
  final String imageURL;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageURL,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String? cat = json['category'];

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] ?? 0),
      category: Category.values.firstWhere((category) => category.label == cat),
      imageURL: json['image_url'] ?? '',
    );
  }
}
