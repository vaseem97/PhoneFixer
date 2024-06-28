import 'package:app_trp/tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:app_trp/profile_screen.dart'; // Import ProfileScreen

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Order> orders = [];
  bool _isLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .get();

        List<Order> fetchedOrders = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          DateFormat dateFormat = DateFormat('dd-MM-yyyy');

          String scheduledDate = data['selectedDate'] != null
              ? dateFormat.format((data['selectedDate'] as Timestamp).toDate())
              : 'Unknown';
          String scheduledTime = data['selectedTimeSlot'] ?? 'Unknown';

          List<Part> parts = [];
          if (data['cartItems'] != null) {
            parts = (data['cartItems'] as List<dynamic>).map((item) {
              return Part(
                name: item['partName'] ?? 'Unknown',
                price: item['price'].toString() ?? 'Unknown',
              );
            }).toList();
          }

          String brand = 'Unknown';
          String model = 'Unknown';
          if (data['cartItems'] != null &&
              data['cartItems'] is List &&
              (data['cartItems'] as List).isNotEmpty) {
            brand = data['cartItems'][0]['brand']?.toString() ?? 'Unknown';
            model = data['cartItems'][0]['modelName']?.toString() ?? 'Unknown';
          }

          Map<String, dynamic> addressData =
              data['deliveryAddress'] as Map<String, dynamic>;
          Address address = Address(
            name: addressData['name'] ?? 'Unknown',
            phone: addressData['phoneNumber'] ?? 'Unknown',
            address:
                '${addressData['address1'] ?? ''} ${addressData['address2'] ?? ''}',
            pincode: addressData['postalCode'] ?? 'Unknown',
          );

          return Order(
            id: doc.id,
            orderNumber: data['orderNumber']?.toString() ?? 'Unknown',
            orderStatus: data['orderStatus']?.toString() ?? 'Unknown',
            brand: brand,
            model: model,
            scheduledDate: scheduledDate,
            scheduledTime: scheduledTime,
            parts: parts,
            deliveryAddress: address,
            totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
            discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
            finalTotal: (data['finalTotal'] as num?)?.toDouble() ?? 0.0,
            orderDate: (data['orderDate'] is Timestamp)
                ? (data['orderDate'] as Timestamp).toDate()
                : DateTime.now(),
          );
        }).toList();

        if (!_isDisposed) {
          setState(() {
            orders = fetchedOrders;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching orders: $e');
      if (!_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Perform any additional cleanup if needed
        return true; // Allow back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          title: const Text(
            'My Orders',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.teal,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No Orders Yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(context, orders[index]);
                        },
                      ),
              ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${order.brand} ${order.model}',
                style: const TextStyle(fontSize: 16, color: Colors.teal),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Status: ',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  // Visual cues for different order statuses
                  getStatusIndicator(order.orderStatus),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Scheduled: ${order.scheduledDate}, ${order.scheduledTime}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ₹${order.finalTotal.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to get the status indicator based on the order status
  Widget getStatusIndicator(String status) {
    switch (status) {
      case 'Pending':
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case 'Shipped':
        return const Icon(Icons.delivery_dining, color: Colors.blue);
      case 'Delivered':
        return const Icon(Icons.check_circle, color: Colors.green);
      default:
        return Text(status, style: const TextStyle(fontSize: 14));
    }
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String orderStatus;
  final String brand;
  final String model;
  final String scheduledDate;
  final String scheduledTime;
  final List<Part> parts;
  final Address deliveryAddress;
  final double totalPrice;
  final double discount;
  final double finalTotal;
  final DateTime orderDate;

  Order({
    required this.id,
    required this.orderNumber,
    required this.orderStatus,
    required this.brand,
    required this.model,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.parts,
    required this.deliveryAddress,
    required this.totalPrice,
    required this.discount,
    required this.finalTotal,
    required this.orderDate,
  });
}

class Part {
  final String name;
  final String price;

  Part({required this.name, required this.price});
}

class Address {
  final String name;
  final String phone;
  final String address;
  final String pincode;

  Address({
    required this.name,
    required this.phone,
    required this.address,
    required this.pincode,
  });
}
