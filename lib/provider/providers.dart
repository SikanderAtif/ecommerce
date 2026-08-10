import 'package:ecommerce/models/category.dart';
import 'package:ecommerce/models/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class CategoryFilterNotifier extends Notifier<Category?> {
  @override
  Category? build() => null;

  void updateFilter(Category? newValue) {
    state = newValue;
  }
}

final categoryFilterProvider = NotifierProvider<CategoryFilterNotifier, Category?>(() {
  return CategoryFilterNotifier();
});

class CheckoutCartNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() => [];

  double getTotal() {
    double total = 0;
    for (Product item in state) {
      total += item.price;
    }

    return total;
  }
}

final checkoutCartProvider = NotifierProvider<CheckoutCartNotifier, List<Product>>(() {
  return CheckoutCartNotifier();
});

final onboardingIndexProvider = StateProvider<int>((ref) => 0);
final homeTabKeyProvider = StateProvider<int>((ref) => 0);
final shopTabKeyProvider = StateProvider<int>((ref) => 0);
final wishlistTabKeyProvider = StateProvider<int>((ref) => 0);