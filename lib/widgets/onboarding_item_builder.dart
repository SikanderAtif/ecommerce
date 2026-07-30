import 'package:ecommerce/models/onboarding_item.dart';
import 'package:ecommerce/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingItemBuilder extends ConsumerWidget {
  final OnboardingItem item;

  const OnboardingItemBuilder({super.key, required this.item});

  void _setOnboarded() async {
    final sp = SharedPreferencesAsync();
    await sp.setBool("onboarded", true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(onboardingIndexProvider);
    final bool initialPage = index == 0;
    final bool lastPage = index == 2;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Image.asset(item.imagePath, height: 250, width: 250),
            SizedBox(height: 24),
            Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 10),
            Text(item.description ?? '', style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 36),

            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                initialPage
                    ? SizedBox(width: 8)
                    : TextButton(
                        onPressed: () {
                          ref.read(onboardingIndexProvider.notifier).state--;
                        },
                        child: Text('Prev'),
                      ),

                Row(
                  children: List.generate(
                    3,
                    (currentIndex) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 8,
                      width: index == currentIndex ? 28 : 8,
                      decoration: BoxDecoration(
                        color: index == currentIndex
                            ? Colors.black
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: lastPage
                      ? () {
                          _setOnboarded();
                          context.go('signup'); // Open Sign Up Screen
                        }
                      : () {
                          ref.read(onboardingIndexProvider.notifier).state++;
                        },
                  child: lastPage ? Text('Get Started') : Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
