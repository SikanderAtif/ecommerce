import 'package:ecommerce/models/category.dart';
import 'package:ecommerce/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriesFilterList extends ConsumerWidget {
  const CategoriesFilterList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(categoryFilterProvider);

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: Category.values.length,
        itemBuilder: (BuildContext context, int index) {
          final category = Category.values[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: InkWell(
              onTap: () {
                selectedCategory == category
                    ? ref
                          .read(categoryFilterProvider.notifier)
                          .updateFilter(null)
                    : ref
                          .read(categoryFilterProvider.notifier)
                          .updateFilter(category);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      border: Border.all(
                        color: selectedCategory == category
                            ? category.color
                            : category.color.withValues(alpha: 0.1),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: category.icon,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(category.label, style: TextStyle(color: selectedCategory == category ? category.color : null)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
