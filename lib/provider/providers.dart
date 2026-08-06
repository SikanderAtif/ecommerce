import 'package:ecommerce/models/category.dart';
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
final onboardingIndexProvider = StateProvider<int>((ref) => 0);
final homeTabKeyProvider = StateProvider<int>((ref) => 0);
final shopTabKeyProvider = StateProvider<int>((ref) => 0);
final wishlistTabKeyProvider = StateProvider<int>((ref) => 0);