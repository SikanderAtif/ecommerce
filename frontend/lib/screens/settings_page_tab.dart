import 'package:ecommerce/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _auth = AuthService();

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

  Future<void> _signout() async {
    _showLoadingDialog('Logging out...');

    try {
      await _auth.logout();

      if (mounted) {
        if (context.canPop()) {
          context.pop();
        }
        context.goNamed('login');
      }
    } catch (e) {
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        }
      }
    }
  }

  void _openOrderHistoryScreen() {
    context.pushNamed('order-history-screen');
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.secondary.withValues(alpha: 0.1),
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _openOrderHistoryScreen,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((_) {
                        return color.surface;
                      }),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history, color: color.secondary),
                        SizedBox(width: 12),
                        Text(
                          'Order History',
                          style: TextStyle(color: color.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _signout,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((_) {
                        return Colors.red;
                      }),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 12),
                        Text('Sign Out'),
                      ],
                    ),
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
