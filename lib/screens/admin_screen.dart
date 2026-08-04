import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen ({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Portal', style: Theme.of(context).textTheme.displayMedium),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              context.goNamed('login');
            },
            child: Text('Sign Out'),
          ),
        ]
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text('Add New Product', style: Theme.of(context).textTheme.headlineMedium),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.pushNamed('admin-new-product');
                },
                child: Text('New Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}