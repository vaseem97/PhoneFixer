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

  // Part use case descriptions and warranty information
  static const Map<String, String> partDescriptions = {
    'LCD': 'Use case: Fix unresponsive or cracked screens. Warranty: 6 months.',
    'Battery':
        'Use case: Resolve battery drainage or swelling issues. Warranty: 1 year.',
    'Back Panel':
        'Use case: Replace damaged or scratched back panels. Warranty: 6 months.',
    'Ringer': 'Use case: Fix sound issues with ringer. Warranty: 6 months.',
    'Frame': 'Use case: Fix sound issues with ringer. Warranty: 6 months.',
    'Glass': 'Use case: Fix sound issues with ringer. Warranty: 6 months.',
    'Sub PCB': 'Use case: Fix sound issues with ringer. Warranty: 6 months.',
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
          title: Text('$brand $modelName Parts'),
          backgroundColor: Theme.of(context).colorScheme.primary,
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
                  final partDescription =
                      partDescriptions[partName] ?? 'No description available';

                  return Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      final isPartInCart = cartProvider.cartItems.any(
                        (item) =>
                            item.brand == brand &&
                            item.modelName == modelName &&
                            item.partName == partName,
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Icon(
                              iconData,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  partName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                color: Theme.of(context).colorScheme.primary,
                                tooltip: 'Part Use Case & Warranty Info',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        title: Row(
                                          children: [
                                            Icon(Icons.info_outline,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                            const SizedBox(width: 8),
                                            Expanded(child: Text(partName)),
                                          ],
                                        ),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              Text(
                                                'Use Case:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                              Text(partDescription
                                                  .split(' Warranty: ')[0]),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Warranty:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                              Text(partDescription
                                                  .split(' Warranty: ')[1]),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            child: const Text('Got it'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          subtitle: Text(
                            formattedPrice,
                            style: TextStyle(
                              color: partPrice.isNegative
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
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
                              backgroundColor: isPartInCart
                                  ? Theme.of(context).colorScheme.errorContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: Text(
                              isPartInCart ? 'Remove' : 'Add',
                              style: TextStyle(
                                color: isPartInCart
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer
                                    : Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
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
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow,
                              spreadRadius: 1,
                              blurRadius: 10,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        margin: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total: ${formatCurrency(cartProvider.totalAmount, 'INR')}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Proceed to checkout',
                                  style: TextStyle(color: Colors.grey),
                                ),
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
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
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
