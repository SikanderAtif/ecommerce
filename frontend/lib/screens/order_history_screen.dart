import 'package:ecommerce/models/order.dart';
import 'package:ecommerce/services/api_service.dart';
import 'package:ecommerce/services/auth_service.dart';
import 'package:ecommerce/widgets/order_card.dart';
import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _auth = AuthService();
  late final Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _getOrderHistory();
  }

  Future<List<Order>> _getOrderHistory() async {
    final user = _auth.currentUser();

    if (user != null) {
      String uid = user.uid;
      return await APIService.fetchOrders(uid);
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('An error occured: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final Order order = snapshot.data![index];

              return Padding(
                padding: EdgeInsets.all(12),
                child: OrderCard(order: order),
              );
            },
          );
        },
      ),
    );
  }
}
