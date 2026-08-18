import 'package:ecommerce/services/auth_service.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _controller = TextEditingController();

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

  void _resetPassword() async {
    final String email = _controller.text.trim();

    if (email.isEmpty) return;

    _showLoadingDialog('Sending Link');
    final auth = AuthService();
    String message = 'Password reset link sent Successfully';

    try {
      await auth.resetPassword(email);
    } on String catch (e) {
      message = e;
    } finally {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme color = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Forgot Password',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              SizedBox(height: 12),

              Text(
                'Enter the email associated with your account and we will send a link to reset your password',
                style: text.bodyMedium,
              ),

              Container(
                padding: EdgeInsets.only(left: 6, right: 6, bottom: 0, top: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color.secondary.withValues(alpha: 0.2),
                ),
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: color.primary),
                  decoration: InputDecoration(
                    hint: Text(
                      'Email',
                      style: TextStyle(color: color.secondary),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),

              SizedBox(height: 36),
              ElevatedButton(
                onPressed: _resetPassword,
                child: Text('Send Link', style: TextStyle(fontSize: 24)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
