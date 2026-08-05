import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminAllProducts extends StatefulWidget {
  const AdminAllProducts({super.key});

  @override
  State<AdminAllProducts> createState() => _AdminAllProductsState();
}

class _AdminAllProductsState extends State<AdminAllProducts> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    return await APIService.fetchProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _productsFuture = _fetchProducts();
    });
  }

  void _openProductDetails(Product item) async {
    await context.pushNamed('admin-product-details', extra: item);
    _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('All Products'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshProducts),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('An error occured: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text('No products found. Start by uploading one!'),
              );
            }

            final products = snapshot.data!;

            return GridView.builder(
              padding: EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];

                return InkWell(
                  onTap: () {
                    _openProductDetails(item);
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
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Center(
                                    child: Icon(Icons.broken_image, size: 40),
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
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                item.description,
                                style: TextStyle(
                                  color: color.secondary.withValues(alpha: 0.8),
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
    );
  }
}
