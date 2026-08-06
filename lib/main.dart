import 'package:ecommerce/firebase_options.dart';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/provider/providers.dart';
import 'package:ecommerce/screens/admin_all_products.dart';
import 'package:ecommerce/screens/admin_new_product.dart';
import 'package:ecommerce/screens/admin_product_details.dart';
import 'package:ecommerce/screens/admin_screen.dart';
import 'package:ecommerce/screens/empty_shell_screen.dart';
import 'package:ecommerce/screens/home_page_tab.dart';
import 'package:ecommerce/screens/login_screen.dart';
import 'package:ecommerce/screens/onboarding_screen.dart';
import 'package:ecommerce/screens/settings_page_tab.dart';
import 'package:ecommerce/screens/shop_page_tab.dart';
import 'package:ecommerce/screens/signup_screen.dart';
import 'package:ecommerce/screens/splash_screen.dart';
import 'package:ecommerce/screens/user_product_details.dart';
import 'package:ecommerce/screens/verify_email_screen.dart';
import 'package:ecommerce/screens/wishlist_page_tab.dart';
import 'package:ecommerce/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splashscreen',
  routes: [
    GoRoute(
      path: '/splashscreen',
      name: 'splashscreen',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/verify-email',
      name: 'verify-email',
      builder: (context, state) => const VerifyEmailScreen(),
    ),
    GoRoute(
      path: '/admin-screen',
      name: 'admin-screen',
      builder: (context, state) => const AdminScreen(),
    ),
    GoRoute(
      path: '/admin-new-product',
      name: 'admin-new-product',
      builder: (context, state) => const AdminNewProduct(),
    ),
    GoRoute(
      path: '/admin-all-products',
      name: 'admin-all-products',
      builder: (context, state) => const AdminAllProducts(),
    ),
    GoRoute(
      path: '/admin-product-details',
      name: 'admin-product-details',
      builder: (context, state) {
        final payload = state.extra as Product;

        return AdminProductDetails(item: payload);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return EmptyShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) {
                return Consumer(
                  builder: (context, ref, child) {
                    final keyVersion = ref.watch(homeTabKeyProvider);

                    return HomePage(key: ValueKey('home_$keyVersion'));
                  },
                );
              },
            ),
            GoRoute(
              path: '/home/user-product-details',
              name: 'user-product-details',
              builder: (context, state) {
                final payload = state.extra as Product;

                return UserProductDetails(item: payload);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shop',
              name: 'shop',
              builder: (context, state) {
                return Consumer(
                  builder: (context, ref, child) {
                    final keyVersion = ref.watch(shopTabKeyProvider);

                    return ShopPage(key: ValueKey('shop_$keyVersion'));
                  },
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/wishlist',
              name: 'wishlist',
              builder: (context, state) {
                return Consumer(
                  builder: (context, ref, child) {
                    final keyVersion = ref.watch(wishlistTabKeyProvider);

                    return WishlistPage(key: ValueKey('wishlist_$keyVersion'));
                  },
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeLight,
      routerConfig: _router,
    );
  }
}
