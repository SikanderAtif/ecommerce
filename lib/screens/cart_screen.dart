import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {

  List<Product> createCartList(List<Product> cart) {
    final seendIds = <int>{};
    return cart.where((product) => seendIds.add(product.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme color = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final cart = ref.watch(checkoutCartProvider);
    final cartList = createCartList(cart);

    return Scaffold(
      backgroundColor: color.surface.withValues(alpha: 0.9),
      appBar: AppBar(centerTitle: true, title: const Text('Shopping Cart')),
      body: cartList.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(12),
              itemCount: cartList.length,
              itemBuilder: (context, index) {
                final int amount = cart
                    .where((product) => product.id == cartList[index].id)
                    .length;
                final double price = cartList[index].price * amount;
                final String name = cartList[index].name;
                final String cat = cartList[index].category.label;
                final img = cartList[index].imageURL;

                return Dismissible(
                  key: ValueKey<int>(cartList[index].id),
                  direction: DismissDirection.endToStart,
                  background: Card(
                    color: Colors.red,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [Icon(Icons.delete, color: color.surface)],
                      ),
                    ),
                  ),
                  onDismissed: (_) {
                    ref
                        .read(checkoutCartProvider.notifier)
                        .removeProductAll(cartList[index]);
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: cartList[index].imageURL.isNotEmpty
                                ? Image.network(
                                    img,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                    errorBuilder: (ctx, err, stack) =>
                                        const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 40,
                                          ),
                                        ),
                                  )
                                : Container(color: color.secondary),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PKR $price',
                                style: TextStyle(
                                  color: color.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                              Text(name, style: text.titleMedium),
                              Text(cat),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.green),
                                onPressed: () {
                                  ref
                                      .read(checkoutCartProvider.notifier)
                                      .addProduct(cartList[index]);
                                },
                              ),
                              Text('$amount'),
                              IconButton(
                                icon: Icon(Icons.remove, color: Colors.green),
                                onPressed: () {
                                  ref
                                      .read(checkoutCartProvider.notifier)
                                      .removeProduct(cartList[index]);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      persistentFooterButtons: [
        SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: text.headlineMedium),
                  Text(
                    'PKR${ref.read(checkoutCartProvider.notifier).getTotal()}',
                    style: text.titleMedium,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.pushNamed('payment-screen');
                      },
                      child: Text('Checkout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      persistentFooterDecoration: BoxDecoration(color: color.surface),
    );
  }
}
