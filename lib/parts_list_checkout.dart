import 'package:app_trp/cart_screen.dart';
import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final CartItem item;
  final String currency;
  const CardWidget({
    Key? key,
    required this.item,
    required this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[200],
          ),
        ),
        title: Text(
          item.partName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Brand: ${item.brand}\nModel: ${item.modelName}',
        ),
        trailing: Text(
          formatCurrency(item.price, currency),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String formatCurrency(double amount, String currency) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }
}
