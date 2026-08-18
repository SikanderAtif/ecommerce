import 'dart:async';
import 'package:ecommerce/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _auth = AuthService();
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // Check if user is already verified initially
    isEmailVerified = _auth.currentUser()?.emailVerified ?? false;

    if (!isEmailVerified) {
      _sendVerificationEmail();

      // Check status automatically every 3 seconds
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // Always cancel timers to avoid memory leaks
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

  void _sendVerificationEmail() async {
    await _auth.sendVerificationEmail();
  }

  void _checkEmailVerified() async {
    await _auth.checkEmailVerified();

    if (mounted) {
      setState(() {
        isEmailVerified =
            FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      });
    }

    if (isEmailVerified && mounted) {
      timer?.cancel();
      // Navigate to your main application dashboard
      context.go('home');
    }
  }

  Future<String?> passwordDialog() async {
    final TextEditingController passController = TextEditingController();

    return await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter your password.\n(Note: This will cancel your account creation)',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: passController,
                  decoration: InputDecoration(hintText: 'Password'),
                ),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, passController.text.trim());
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith((_) {
                            return Colors.red[700];
                          }),
                        ),
                        child: Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _cancelSignUp() async {
    String? pass = await passwordDialog();
    if (pass == null || pass.isEmpty) return;

    _showLoadingDialog('Canceling Account...');
    try {
      timer?.cancel();
      await _auth.delete(pass);

      if (mounted) {
        Navigator.pop(context);
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed('signup');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) async {
        await _cancelSignUp();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Verify Email')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'A verification link has been sent to your email.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _sendVerificationEmail,
                  icon: const Icon(Icons.email),
                  label: const Text('Resend Email'),
                ),
                TextButton(
                  onPressed: _cancelSignUp,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
