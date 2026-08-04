import 'package:ecommerce/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EmptyShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const EmptyShellScreen ({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onTap(int index) {
      if (index == 0) {
        ref.read(homeTabKeyProvider.notifier).state++;
      } else if (index == 1) {
        ref.read(shopTabKeyProvider.notifier).state++;
      } else if (index == 2) {
        ref.read(wishlistTabKeyProvider.notifier).state++;
      } 
      

      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTap,
        currentIndex: navigationShell.currentIndex,
        items: [
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.home_outlined),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.shopping_cart_outlined),
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.favorite_outline),
            icon: Icon(Icons.favorite_outline),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.settings_outlined),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}