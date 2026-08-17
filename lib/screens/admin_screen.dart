import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Portal',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              context.goNamed('login');
            },
            child: Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              'Add New Product',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.pushNamed('admin-new-product');
                },
                child: Text('New Product'),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'All Products',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.pushNamed('admin-all-products');
                },
                child: Text('All Products'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
