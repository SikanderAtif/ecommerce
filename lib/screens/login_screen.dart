import 'package:ecommerce/services/auth_service.dart';
import 'package:ecommerce/widgets/auth_provider_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscureText = true;
  String? _errorMessage1, _errorMessage2;

  @override
  void dispose() {
    _passController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _login() async {
    final String email = _emailController.text.trim();
    final String pass = _passController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage1 = 'This Field is Empty';
      });
      return;
    } else {
      _errorMessage1 = null;
    }
    if (pass.isEmpty) {
      setState(() {
        _errorMessage2 = 'This Field is Empty';
      });
      return;
    }
    _errorMessage2 = null;

    _showLoadingDialog('Logging in...');
    final auth = AuthService();
    final user = await auth.loginUser(email, pass);

    if (user == null) {
      _errorMessage2 = 'Email or Password is incorrect';
      return;
    }
    if (mounted) {
      context.goNamed('home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            SizedBox(height: 12),

            Container(
              padding: EdgeInsets.only(left: 6, right: 6, bottom: 0, top: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.secondary.withValues(alpha: 0.2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      style: TextStyle(color: color.primary),
                      decoration: InputDecoration(
                        hint: Text(
                          'Email',
                          style: TextStyle(color: color.secondary),
                        ),
                        errorText: _errorMessage1,
                        prefixIcon: Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            Container(
              padding: EdgeInsets.only(left: 6, right: 6, bottom: 0, top: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.secondary.withValues(alpha: 0.2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _passController,
                      obscureText: _obscureText,
                      style: TextStyle(color: color.primary),
                      decoration: InputDecoration(
                        hint: Text(
                          'Password',
                          style: TextStyle(color: color.secondary),
                        ),
                        errorText: _errorMessage2,
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Forgot Password?'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 36),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _login,
                    child: Text('Login', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ],
            ),

            SizedBox(height: 36),
            Center(
              child: Text(
                '- OR Continue with -',
                style: TextStyle(color: color.secondary),
              ),
            ),
            SizedBox(height: 18),
            Center(
              child: AuthProviderButton(
                assetPath: 'assets/images/google.png',
                isLogin: true,
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Create An Account',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () {
                    context.goNamed('signup');
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
