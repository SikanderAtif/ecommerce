import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/provider/providers.dart';
import 'package:ecommerce/services/api_service.dart';
import 'package:ecommerce/widgets/categories_filter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Future<List<Product>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Product>> _fetchProducts() async {
    return await APIService.fetchProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _productsFuture = _fetchProducts();
    });
  }

  void _openUserProductDetails(Product item) async {
    await context.pushNamed('user-product-details', extra: item);
    _refreshProducts();
  }

  void _searchBarFilter() async {
    _refreshProducts();
    String search = _searchController.text.trim().toLowerCase();
    if (search.isEmpty) return;

    final List<Product> list = [];

    for (Product item in await _productsFuture) {
      if (item.name.toLowerCase().contains(search)) {
        list.add(item);
      }
    }

    setState(() {
      _productsFuture = Future.value(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(checkoutCartProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);
    final ColorScheme color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.onSurface,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: color.surface,
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: color.primary),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search keywords...',
                      hintStyle: TextStyle(color: color.secondary),
                    ),
                    onSubmitted: (_) {
                      _searchBarFilter();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 12),
            CategoriesFilterList(),
            SizedBox(height: 24),
            Text(
              'Featured Products',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('An error occured: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('No products found. Start by uploading one!'),
                    );
                  }

                  final products = snapshot.data!;
                  bool filter = selectedCategory != null;
                  final finalProducts = [];
                  if (filter) {
                    for (Product item in products) {
                      if (item.category == selectedCategory) {
                        finalProducts.add(item);
                      }
                    }
                  }

                  if ((!filter && products.isEmpty) ||
                      (filter && finalProducts.isEmpty)) {
                    return Center(child: Text('No Items Yet'));
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filter ? finalProducts.length : products.length,
                    itemBuilder: (context, index) {
                      final item = filter
                          ? finalProducts[index]
                          : products[index];

                      return InkWell(
                        onTap: () {
                          _openUserProductDetails(item);
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: item.imageURL.isNotEmpty
                                    ? Image.network(
                                        item.imageURL,
                                        width: double.infinity,
                                        height: 350,
                                        fit: BoxFit.contain,
                                        errorBuilder: (ctx, err, stack) =>
                                            Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 40,
                                              ),
                                            ),
                                      )
                                    : Container(color: color.secondary),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      item.description,
                                      style: TextStyle(
                                        color: color.secondary.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'PKR${item.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: color.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
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
