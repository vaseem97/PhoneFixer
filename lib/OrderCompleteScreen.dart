import 'package:flutter/material.dart';
import 'package:app_trp/cart_screen.dart';

class OrderCompleteScreen extends StatelessWidget {
  final String orderNumber;
  final double totalAmount;
  final List<CartItem> cartItems;

  const OrderCompleteScreen({
    Key? key,
    required this.orderNumber,
    required this.totalAmount,
    required this.cartItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Complete'),
        backgroundColor: Colors.deepPurple,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Number: $orderNumber',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Amount: ${formatCurrency(totalAmount, 'INR')}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ordered Parts:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...cartItems.map((item) => ListTile(
                  title: Text(item.partName),
                  subtitle:
                      Text('Brand: ${item.brand}, Model: ${item.modelName}'),
                  trailing: Text('${item.price.toStringAsFixed(2)} INR'),
                )),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/orders'));
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Go to Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatCurrency(double amount, String currency) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }
}
