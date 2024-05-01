import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // If the user is not logged in, display a message or redirect to the login screen
      return Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
          elevation: 0.0,
        ),
        body: const Center(
          child: Text('Please log in to view your orders'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('orders')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching orders'),
            );
          }
          final orders = snapshot.data!.docs;
          if (orders.isEmpty) {
            return const Center(
              child: Text('No orders found'),
            );
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderData = order.data() as Map<String, dynamic>;
              final orderItems = orderData['cartItems'] as List<dynamic>;
              final orderId =
                  '${orderData['orderDate'].toDate().day}${orderData['orderDate'].toDate().month}${orderData['orderDate'].toDate().year}-${orderData['orderDate'].toDate().hour}${orderData['orderDate'].toDate().minute}${orderData['orderDate'].toDate().second}';

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #$orderId',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Text(
                              orderData['orderDate'].toDate().toString(),
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        for (var item in orderItems)
                          ListTile(
                            leading: Icon(Icons.shopping_cart),
                            title: Text(
                              '${item['partName']} - ${item['brand']} ${item['modelName']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('₹${item['price']}'),
                          ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Price:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              Text(
                                '₹${orderData['totalPrice']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text(
                            'Delivery Address',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          subtitle:
                              Text(orderData['deliveryAddress'].toString()),
                        ),
                        ListTile(
                          leading: Icon(Icons.info),
                          title: Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          trailing: Text(
                            orderData['orderStatus'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: orderData['orderStatus'] == 'Delivered'
                                  ? Colors.green
                                  : Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
