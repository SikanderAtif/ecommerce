import 'package:ecommerce/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = AuthService();
  double _logoSize = 0.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _logoSize = 200.0;
        });
      }
    });
  }

  void _checkOnboarded() async {
    final sp = SharedPreferencesAsync();
    bool onboarded = await sp.getBool('onboarded') ?? false;
    final user = _auth.currentUser();
    final bool isEmailVerified = user?.emailVerified ?? false;

    if (mounted) {
      if (onboarded) {
        if (user == null) {
          context.goNamed('login');
          return;
        }
        if (isEmailVerified) {
          context.goNamed('home');
          return;
        } else {
          context.goNamed('verify-email');
          return;
        }
      } else {
        context.goNamed('onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        width: _logoSize,
        height: _logoSize,
        child: Image.asset('assets/images/logo.png'),
        onEnd: () {
          Future.delayed(Duration(seconds: 3), _checkOnboarded);
        },
      ),
    );
  }
}
