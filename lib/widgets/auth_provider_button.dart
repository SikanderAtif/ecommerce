import 'package:ecommerce/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthProviderButton extends StatelessWidget {
  final String assetPath;
  final bool isLogin;

  const AuthProviderButton({
    super.key,
    required this.assetPath,
    required this.isLogin,
  });

  void _loginWithProvider(BuildContext context) async {
    if (assetPath.contains('google')) {
      //Login with Google
      final auth = AuthService();
      await auth.loginWithGoogle();

      if (auth.currentUser() == null) return;

      if (context.mounted) {
        context.goNamed('home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme color = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        _loginWithProvider(context);
      },
      child: Container(
        width: 50,
        height: 50,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.onSurface.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.onSurface),
        ),
        child: Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }
}
