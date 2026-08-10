import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserProductDetails extends ConsumerStatefulWidget {
  final Product item;
  const UserProductDetails({super.key, required this.item});

  @override
  ConsumerState<UserProductDetails> createState() => _UserProductDetailsState();
}

class _UserProductDetailsState extends ConsumerState<UserProductDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme color = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final cart = ref.watch(checkoutCartProvider);

    return Scaffold(
      appBar: AppBar(scrolledUnderElevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.item.imageURL.isNotEmpty
                    ? Image.network(
                        widget.item.imageURL,
                        width: double.infinity,
                        height: 400,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, stack) => const Center(
                          child: Icon(Icons.broken_image, size: 40),
                        ),
                      )
                    : Container(color: color.secondary),
              ),
            ),
            const SizedBox(height: 16),

            Text(widget.item.name, style: text.headlineMedium),
            const SizedBox(height: 12),

            Text(
              'Category: ${widget.item.category.label}',
              style: text.titleMedium,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Text('Quantity: '),
                SizedBox(width: 12),
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    if (cart
                        .where((product) => product.id == widget.item.id)
                        .isNotEmpty) {
                      int index = cart.indexWhere(
                        (product) => product.id == widget.item.id,
                      );

                      if (index != -1) {
                        setState(() {
                          cart.removeAt(index);
                        });
                      }
                    }
                  },
                ),
                Text(
                  '${cart.where((product) => product.id == widget.item.id).length}',
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () {
                    setState(() {
                      cart.add(widget.item);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 12),

            Text('PKR${widget.item.price}', style: text.headlineMedium),
            const SizedBox(height: 24),

            Text('Description', style: text.headlineMedium),
            Text(widget.item.description, style: text.titleMedium),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.pushNamed('cart-screen');
          setState(() {});
        },
        label: Text(
          '(${cart.length})          PKR ${ref.read(checkoutCartProvider.notifier).getTotal()}',
          style: TextStyle(color: color.surface),
        ),
        icon: Icon(Icons.shopping_cart, color: color.surface),
      ),
    );
  }
}
