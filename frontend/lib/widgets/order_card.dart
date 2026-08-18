import 'package:ecommerce/models/order.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final ColorScheme color = Theme.of(context).colorScheme;
    double total = 0;
    for (double item in order.price) {
      total += item;
    }

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Order Date: ${order.date.year}-${order.date.month}-${order.date.day}"),
          SizedBox(height: 6),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: order.name.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${order.qty[index]}x ', style: TextStyle(color: color.primary)),
                    Text(order.name[index], style: TextStyle(color: color.onSurface)),
                    Text('${order.price[index]}', style: TextStyle(color: color.primary)),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 12),
          Text('Total: PKR $total', style: TextStyle(color: color.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
