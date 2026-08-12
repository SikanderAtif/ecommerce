import 'package:ecommerce/models/category.dart';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/services/favorites_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class CategoryFilterNotifier extends Notifier<Category?> {
  @override
  Category? build() => null;

  void updateFilter(Category? newValue) {
    state = newValue;
  }
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, Category?>(() {
      return CategoryFilterNotifier();
    });

class CheckoutCartNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() => [];

  void addProduct(Product item) {
    state = [...state, item];
  }

  void removeProduct(Product item) {
    int index = state.indexWhere((product) => product.id == item.id);

    if (index != -1) {
      final List<Product> temp = [...state];
      temp.removeAt(index);
      state = temp;
    }
  }

  void removeProductAll(Product item) {
    state = state.where((p) => p.id != item.id).toList();
  }

  int getProductCount(Product item) {
    return state.where((product) => product.id == item.id).length;
  }

  int getCartCount() {
    return state.length;
  }

  double getTotal() {
    double total = 0;
    for (Product item in state) {
      total += item.price;
    }

    return total;
  }
}

final checkoutCartProvider =
    NotifierProvider<CheckoutCartNotifier, List<Product>>(() {
      return CheckoutCartNotifier();
    });

class WishlistNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() {
    _init();

    return [];
  }

  void _init() async {
    final result = await FavoritesHelper.read();
    final List<Product> newList = [];

    for (Map<String, dynamic> item in result) {
      final double amt = item['Price'] is int
          ? double.parse(item['Price'].toString())
          : item['Price'];
      final Category cat = Category.values.firstWhere(
        (c) => c.label == item['Category'],
      );

      final Product temp = Product(
        id: item['ID'],
        name: item['Name'],
        description: item['Description'],
        price: amt,
        category: cat,
        imageURL: item['URL'],
      );
      newList.add(temp);
    }

    state = newList;
  }

  void addProduct(Product item) async {
    if (!state.any((p) => p.id == item.id)) {
      await FavoritesHelper.insert(item);
      state = [...state, item];
    }
  }

  void removeProduct(Product item) async {
    await FavoritesHelper.remove(item.id);
    state = state.where((p) => p.id != item.id).toList();
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, List<Product>>(() {
  return WishlistNotifier();
});

final onboardingIndexProvider = StateProvider<int>((ref) => 0);
final homeTabKeyProvider = StateProvider<int>((ref) => 0);
final shopTabKeyProvider = StateProvider<int>((ref) => 0);
final wishlistTabKeyProvider = StateProvider<int>((ref) => 0);
