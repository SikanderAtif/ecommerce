import 'dart:convert';

class Order {
  final DateTime date;
  final List<String> name;
  final List<double> price;
  final List<int> qty;

  Order({
    required this.date,
    required this.name,
    required this.price,
    required this.qty,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final details = json['details'];
    List<dynamic> products = jsonDecode(details).values.toList();
    List<String> nameList = [];
    List<double> priceList = [];
    List<int> qtyList = [];

    for (dynamic item in products) {
      nameList.add(item['name']);
      priceList.add(item['price']);
      qtyList.add(item['quantity']);
    }

    return Order(
      date: DateTime.parse(json['created_at']),
      name: nameList,
      price: priceList,
      qty: qtyList,
    );
  }
}
