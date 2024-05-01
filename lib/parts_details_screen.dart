import 'package:app_trp/AddressScreen.dart';
import 'package:app_trp/cart_screen.dart';
import 'package:app_trp/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartsDetailsScreen extends StatelessWidget {
  final String brand;
  final String modelName;
  final Map<String, dynamic> parts;

  const PartsDetailsScreen({
    Key? key,
    required this.brand,
    required this.modelName,
    required this.parts,
    required CartProvider cartProvider,
  }) : super(key: key);

  // Mapping of part names to icons
  static const Map<String, IconData> partIcons = {
    'LCD': Icons.phone_android,
    'Battery': Icons.battery_full,
    'Back Panel': Icons.phone_android_sharp,
    'Ringer': Icons.speaker,
    // Add more part names and corresponding icons as needed
  };

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Clear the cart when user presses back button
        Provider.of<CartProvider>(context, listen: false).clearCart();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${brand} ${modelName} Parts'),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: parts.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final partName = parts.keys.toList()[index];
                  final partPriceString = parts[partName] ?? '';
                  final partPrice = double.tryParse(partPriceString) ?? 0.0;
                  final formattedPrice = formatCurrency(partPrice, 'INR');

                  // Retrieve the icon for the part based on its name
                  final iconData = partIcons[partName] ?? Icons.extension;

                  return Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      final isPartInCart = cartProvider.cartItems.any(
                        (item) =>
                            item.brand == brand &&
                            item.modelName == modelName &&
                            item.partName == partName,
                      );

                      return Card(
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                            ),
                            child: Icon(
                              iconData,
                              color: Colors.grey[600],
                            ),
                          ),
                          title: Text(partName),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Price:'),
                              Text(
                                formattedPrice,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: partPrice.isNegative
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              final cartItem = CartItem(
                                brand: brand,
                                modelName: modelName,
                                partName: partName,
                                price: partPrice,
                              );
                              if (isPartInCart) {
                                cartProvider.removeFromCart(cartItem);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('$partName removed from cart'),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              } else {
                                cartProvider.addToCart(cartItem);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$partName added to cart'),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: Colors.grey[200],
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            child: Text(
                              isPartInCart ? 'Remove' : 'Add',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return cartProvider.cartItems.isNotEmpty
                    ? Container(
                        color: Colors.grey.shade200,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total: ${formatCurrency(cartProvider.totalAmount, 'INR')}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text('Proceed to checkout'),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddressScreen(
                                      cartItems: cartProvider.cartItems,
                                      totalPrice: cartProvider.totalAmount,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                'Proceed',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
