import 'package:ecommerce/models/onboarding_item.dart';
import 'package:ecommerce/provider/providers.dart';
import 'package:ecommerce/widgets/onboarding_item_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _controller;
  late final _pages = [
    OnboardingItemBuilder(
      item: OnboardingItem(
        imagePath: 'assets/images/choose_products.jpg',
        title: 'Choose Products',
        description: null,
      ),
    ),
    OnboardingItemBuilder(
      item: OnboardingItem(
        imagePath: 'assets/images/make_payment.jpg',
        title: 'Make Payment',
        description: null,
      ),
    ),
    OnboardingItemBuilder(
      item: OnboardingItem(
        imagePath: 'assets/images/get_order.png',
        title: 'Get Your Order',
        description: null,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final currentIndex = ref.read(onboardingIndexProvider);
    _controller = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setOnboarded() async {
    final sp = SharedPreferencesAsync();
    await sp.setBool("onboarded", true);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(onboardingIndexProvider, (previous, next) {
      if (_controller.hasClients && _controller.page?.round() != next) {
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    final ColorScheme color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: Text('     ${ref.watch(onboardingIndexProvider) + 1}/3'),
        actions: [
          TextButton(
            onPressed: () {
              _setOnboarded();
              context.go('signup'); // Open Sign Up Screen
            },
            child: Text('Skip', style: TextStyle(color: color.primary)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: PageView(
          controller: _controller,
          onPageChanged: (int index) {
            ref.read(onboardingIndexProvider.notifier).state = index;
          },
          children: _pages,
        ),
      ),
    );
  }
}
