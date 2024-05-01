import 'package:app_trp/home_page.dart';
import 'package:app_trp/cart_screen.dart';
import 'package:app_trp/payment_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DateTimeSlotScreen extends StatefulWidget {
  final Map<String, dynamic> selectedAddress;
  final List<CartItem> cartItems;
  final double totalPrice;

  const DateTimeSlotScreen({
    Key? key,
    required this.selectedAddress,
    required this.cartItems,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<DateTimeSlotScreen> createState() => _DateTimeSlotScreenState();
}

class _DateTimeSlotScreenState extends State<DateTimeSlotScreen> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  final _couponController = TextEditingController();
  double _discount = 0.0;

  void _applyCoupon(String couponCode) {
    // You can implement your coupon code validation logic here
    // For example, check if the coupon code exists in your database or a list of valid codes
    // If the coupon code is valid, apply a discount to the total price

    if (couponCode == 'WELCOME10') {
      _discount = widget.totalPrice * 0.1; // 10% discount
    } else if (couponCode == 'FLAT50') {
      _discount = 50.0; // Flat ₹50 discount
    }

    setState(() {});
  }

  Future<void> _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null && _selectedDate != null && _selectedTimeSlot != null) {
      final orderData = {
        'cartItems': widget.cartItems
            .map((item) => {
                  'partName': item.partName,
                  'brand': item.brand,
                  'modelName': item.modelName,
                  'price': item.price,
                })
            .toList(),
        'totalPrice': widget.totalPrice - _discount,
        'couponCode': _couponController.text,
        'discount': _discount,
        'selectedDate': _selectedDate,
        'selectedTimeSlot': _selectedTimeSlot,
        'deliveryAddress': widget.selectedAddress,
        'orderStatus': 'Placed',
        'orderDate': DateTime.now(),
      };

      final userOrderCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orders');
      await userOrderCollection.add(orderData);

      // Clear the cart
      // ignore: use_build_context_synchronously
      Provider.of<CartProvider>(context, listen: false).clearCart();

      // Show a success message
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order Placed Successfully'),
          content: const Text('Your order has been placed successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Navigate back to the previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date, time slot, and address'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    final endDate = startDate.add(const Duration(days: 4));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Date and Time Slot'),
        backgroundColor:
            Colors.deepPurple, // Set the background color of the app bar
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            const Text(
              'Select Date:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 8.0),
                itemBuilder: (context, index) {
                  final date = startDate.add(Duration(days: index));
                  final formattedDate = DateFormat('EEE, MMM d').format(date);
                  final isSelected = _selectedDate == date;
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = date;
                        _selectedTimeSlot = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.green : null,
                    ),
                    child: Text(formattedDate),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Select Time Slot:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: _selectedDate == null
                      ? null
                      : () {
                          setState(() {
                            _selectedTimeSlot = '12:00 PM - 3:00 PM';
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedTimeSlot == '12:00 PM - 3:00 PM'
                        ? Colors.green
                        : null,
                  ),
                  child: const Text('12:00 PM - 3:00 PM'),
                ),
                ElevatedButton(
                  onPressed: _selectedDate == null
                      ? null
                      : () {
                          setState(() {
                            _selectedTimeSlot = '3:00 PM - 6:00 PM';
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedTimeSlot == '3:00 PM - 6:00 PM'
                        ? Colors.green
                        : null,
                  ),
                  child: const Text('3:00 PM - 6:00 PM'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Details:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ...widget.cartItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.partName} (${item.brand} ${item.modelName})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Price: ₹${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: TextFormField(
                        controller: _couponController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Coupon Code (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (value) {
                          _applyCoupon(value);
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          _discount > 0
                              ? '₹${(widget.totalPrice - _discount).toStringAsFixed(2)}'
                              : '₹${widget.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    if (_discount > 0) const SizedBox(height: 8.0),
                    if (_discount > 0)
                      Text(
                        'Coupon discount applied: ₹${_discount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Delivery Address:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(widget.selectedAddress['name']),
                    Text(widget.selectedAddress['address1']),
                    if (widget.selectedAddress['address2']!.isNotEmpty)
                      Text(widget.selectedAddress['address2']),
                    Text(
                      '${widget.selectedAddress['city']}, ${widget.selectedAddress['state']} ${widget.selectedAddress['postalCode']}',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: _selectedDate == null || _selectedTimeSlot == null
                    ? null
                    : _placeOrder,
                child: const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
