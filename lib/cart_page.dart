import 'package:app_trp/cart_screen.dart';
import 'package:app_trp/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
// Assume other imports are correctly placed

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: cartProvider.cartItems.isEmpty
          ? const Center(
              child: Text('Your cart is empty'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: cartProvider.cartItems.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final cartItem = cartProvider.cartItems[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(cartItem.partName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${cartItem.brand} ${cartItem.modelName}'),
                              Text(
                                '${formatCurrency(cartItem.price, 'INR')} x ${cartItem.quantity} = ${formatCurrency(cartItem.price * cartItem.quantity, 'INR')}',
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () =>
                                    cartProvider.decreaseQuantity(cartItem),
                              ),
                              Text('${cartItem.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () =>
                                    cartProvider.increaseQuantity(cartItem),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_shopping_cart),
                                onPressed: () =>
                                    cartProvider.removeFromCart(cartItem),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (cartProvider.cartItems.isNotEmpty)
                  _buildBottomSection(cartProvider, context),
              ],
            ),
    );
  }

  Widget _buildBottomSection(CartProvider cartProvider, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formatCurrency(cartProvider.totalAmount, 'INR'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Add some spacing
            SizedBox(
              width:
                  double.infinity, // Make the button expand to fill the width
              child: SlideAction(
                text: 'Slide to Order',
                outerColor: Colors.deepPurple,
                innerColor: Colors.white,
                onSubmit: () {
                  saveOrderToFirestore(context, cartProvider);
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep the saveOrderToFirestore function as is.
Future<void> saveOrderToFirestore(
    BuildContext context, CartProvider cartProvider) async {
  try {
    final orderDoc = await FirebaseFirestore.instance.collection('orders').add({
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'orderItems': cartProvider.cartItems
          .map((item) => {
                'partName': item.partName,
                'brand': item.brand,
                'modelName': item.modelName,
                'quantity': item.quantity,
                'price': item.price,
              })
          .toList(),
      'totalAmount': cartProvider.totalAmount,
      'orderDate': Timestamp.now(),
    });

    cartProvider.clearCart();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order placed successfully. Order ID: ${orderDoc.id}'),
      ),
    );
  } catch (e) {
    print('Error saving order to Firestore: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error placing order. Please try again.'),
      ),
    );
  }
}
