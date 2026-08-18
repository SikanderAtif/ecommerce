import 'package:ecommerce/provider/providers.dart';
import 'package:ecommerce/services/api_service.dart';
import 'package:ecommerce/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _auth = AuthService();
  bool _isLoading = false;

  Future<void> _processPayment() async {
    final cart = ref.read(checkoutCartProvider.notifier);
    final formattedItems = cart.getFormattedCartItems();

    if (formattedItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Your cart is empty!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final paymentData = await APIService.createPaymentIntent(
        uid: _auth.currentUser()!.uid,
        items: formattedItems,
        currency: 'pkr',
      );

      final String clientSecret = paymentData['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Dukan',
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: Colors.green),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      cart.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Thank you for your order.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('home');
      }
    } on StripeException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.error.localizedMessage ?? 'Payment canceled'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(checkoutCartProvider);
    final total = ref.watch(checkoutCartProvider.notifier).getTotal();
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: _isLoading ? null : AppBar(),
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading || cart.isEmpty ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Pay Rs${total.toStringAsFixed(2)} with Stripe',
                    style: text.titleMedium,
                  ),
          ),
        ),
      ),
    );
  }
}
