import 'package:ecommerce/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WishlistPage extends ConsumerStatefulWidget {
  const WishlistPage({super.key});

  @override
  ConsumerState<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends ConsumerState<WishlistPage> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme color = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Wishlist', style: TextStyle(color: color.surface)),
      ),
      body: wishlist.isEmpty
          ? const Center(child: Text('Your wishlist is empty'))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                itemCount: wishlist.length,
                itemBuilder: (context, index) {
                  final img = wishlist[index].imageURL;
                  final name = wishlist[index].name;
                  final cat = wishlist[index].category.label;

                  return InkWell(
                    onTap: () {
                      context.pushNamed('user-product-details', extra: wishlist[index]);
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
                              child: wishlist[index].imageURL.isNotEmpty
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
                                Text(name, style: text.titleMedium),
                                Text(cat),
                              ],
                            ),

                            IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: color.onSurface,
                              ),
                              onPressed: () {
                                ref.read(wishlistProvider.notifier).removeProduct(wishlist[index]);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
