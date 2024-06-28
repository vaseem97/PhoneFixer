import 'dart:math';

import 'package:app_trp/OrderCompleteScreen.dart';
import 'package:app_trp/parts_list_checkout.dart';
import 'package:flutter/material.dart';
import 'package:app_trp/cart_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic> selectedAddress;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final List<CartItem> cartItems;
  final double totalPrice;

  const CheckoutPage({
    Key? key,
    required this.selectedAddress,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.cartItems,
    required this.totalPrice,
  }) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _couponController = TextEditingController();
  double _discount = 0.0;
  bool _agreedToTerms = false;

  void _applyCoupon() {
    if (_couponController.text.isNotEmpty) {
      setState(() {
        _discount = 120.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Coupon applied!'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }

  Future<void> _saveOrderToFirebase(double finalTotal) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        int orderNumber = _generateOrderNumber();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .add({
          'orderDate': FieldValue.serverTimestamp(),
          'selectedAddress': widget.selectedAddress,
          'selectedDate': widget.selectedDate,
          'selectedTimeSlot': widget.selectedTimeSlot,
          'cartItems': widget.cartItems.map((item) => item.toJson()).toList(),
          'totalPrice': widget.totalPrice,
          'discount': _discount,
          'finalTotal': finalTotal,
          'orderNumber': orderNumber.toString(),
          'createdAt': FieldValue.serverTimestamp(),
          'orderStatus': 'Order Placed',
          'deliveryAddress':
              widget.selectedAddress, // Assuming this is a String
        });
        // Navigate to OrderCompleteScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderCompleteScreen(
              orderNumber: DateTime.now().millisecondsSinceEpoch.toString(),
              totalAmount: finalTotal,
              cartItems: widget.cartItems,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save order: $e'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _generateOrderNumber() {
    final Random random = Random();
    final int timestampComponent =
        DateTime.now().millisecondsSinceEpoch % 1000000;
    final int randomComponent = random.nextInt(100000);

    return (timestampComponent + randomComponent) % 1000000;
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            'All repair services come with a 90-day warranty for parts and labor. '
            'Please review the complete terms and conditions on our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double finalTotal = widget.totalPrice - _discount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Review',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...widget.cartItems.map((item) => CardWidget(
                    item: item,
                    currency: '₹',
                  )),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Promo Code',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _applyCoupon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSummaryRow(
                  'Subtotal', formatCurrency(widget.totalPrice, '₹')),
              if (_discount > 0)
                _buildSummaryRow('Discount', formatCurrency(_discount, '₹'),
                    isHighlighted: true),
              const Divider(),
              _buildSummaryRow('Order Total', formatCurrency(finalTotal, '₹'),
                  isBold: true),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment, color: Colors.black87, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Pay After Repair',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: Colors.grey[200],
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warranty Information:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'All repair services come with a 90-day warranty for parts and labor.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoSection(
                'Shipping Address',
                () {
                  // Implement address change logic
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _agreedToTerms = value!;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: _showTermsAndConditions,
                    child: const Text(
                      'I agree to the terms and conditions',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _agreedToTerms
                    ? () async {
                        await _saveOrderToFirebase(finalTotal);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Service Confirm',
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
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value,
      {bool isBold = false, bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isHighlighted ? Colors.green : Colors.grey,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isHighlighted ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.green : Colors.black,
              fontSize: isHighlighted ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, VoidCallback onTap) {
    final String? name = widget.selectedAddress['name'];
    final String? phone = widget.selectedAddress['phoneNumber'];
    final String? address1 = widget.selectedAddress['address1'];
    final String? address2 = widget.selectedAddress['address2'];
    final String? city = widget.selectedAddress['city'];
    final String? state = widget.selectedAddress['state'];
    final String? pin = widget.selectedAddress['postalCode'];

    String address = '';
    if (address1 != null) address += address1;
    if (address2 != null && address2.isNotEmpty) address += '\n$address2';
    if (city != null && state != null && pin != null) {
      address += '\n$city, $state - $pin';
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              if (name != null)
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (phone != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.phone,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              if (address.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatCurrency(double amount, String currency) {
  return '$currency ${amount.toStringAsFixed(2)}';
}
