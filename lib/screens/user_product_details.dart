import 'package:ecommerce/models/product.dart';
import 'package:flutter/material.dart';

class UserProductDetails extends StatefulWidget {
  final Product item;
  const UserProductDetails({super.key, required this.item});

  @override
  State<UserProductDetails> createState() => _UserProductDetailsState();
}

class _UserProductDetailsState extends State<UserProductDetails> {

  @override
  Widget build(BuildContext context) {
    final ColorScheme color = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: widget.item.imageURL.isNotEmpty
                          ? Image.network(
                              widget.item.imageURL,
                              width: double.infinity,
                              fit: BoxFit.cover,
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

                  Text('Category: ${widget.item.category.label}', style: text.titleMedium),
                  const SizedBox(height: 24),

                  Text('PKR${widget.item.price}', style: text.headlineMedium),
                  const SizedBox(height: 24),

                  Text('Description', style: text.headlineMedium),
                  Text(widget.item.description, style: text.titleMedium),
                  const SizedBox(height: 24),

                ],
              ),
            ),
    );
  }
}
