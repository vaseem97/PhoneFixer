import 'package:app_trp/cart_screen.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final double totalPrice;

  const PaymentScreen(
      {Key? key,
      required this.totalPrice,
      required DateTime selectedDate,
      required String selectedTimeSlot,
      required List<CartItem> cartItems,
      required String couponCode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Total Amount: ₹${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement payment logic here
                _handlePayment(context);
              },
              child: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePayment(BuildContext context) {
    // Implement payment logic here, such as integrating with payment gateways
    // Once payment is successful, you can navigate to the success screen or do further actions
    // For simplicity, let's navigate to a success screen after a delay of 2 seconds

    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Payment Processing'),
          content: Text('Please wait while we process your payment...'),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close the processing dialog
      // Navigate to the success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(),
        ),
      );
    });
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Success'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the previous screen
                Navigator.pop(context);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
