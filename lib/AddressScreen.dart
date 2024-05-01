import 'package:flutter/material.dart';
import 'package:app_trp/add_adress.dart';
import 'package:app_trp/cart_screen.dart';
import 'package:app_trp/date_time_slot_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

class AddressScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;

  const AddressScreen({
    Key? key,
    required this.cartItems,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<Map<String, dynamic>> _savedAddresses = [];
  Map<String, dynamic>? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _fetchSavedAddresses();
  }

  Future<void> _fetchSavedAddresses() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        if (userData != null && userData.containsKey('addresses')) {
          setState(() {
            _savedAddresses =
                List<Map<String, dynamic>>.from(userData['addresses']);
          });
        }
      }
    }
  }

  void _proceedToDateTimeSlotScreen() {
    if (_selectedAddress != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DateTimeSlotScreen(
            selectedAddress: _selectedAddress!,
            cartItems: widget.cartItems,
            totalPrice: widget.totalPrice,
          ),
        ),
      );
    }
  }

  void _editAddress(Map<String, dynamic> address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressInputScreen(
          address: address,
          onSave: _saveAddress,
        ),
      ),
    );
  }

  Future<void> _saveAddress(Map<String, dynamic> address) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Check if the address already exists in the saved addresses list
        final List<dynamic> savedAddresses =
            userSnapshot.data()?['addresses'] ?? [];
        final existingIndex = savedAddresses
            .indexWhere((item) => item['name'] == address['name']);

        if (existingIndex != -1) {
          savedAddresses[existingIndex] = address; // Update existing address
          await userDoc.update({'addresses': savedAddresses});
        } else {
          await userDoc.update({
            'addresses': FieldValue.arrayUnion([address])
          });
        }
      } else {
        await userDoc.set({
          'addresses': [address]
        });
      }

      _fetchSavedAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Address"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _savedAddresses.isEmpty
                  ? "No saved addresses found."
                  : "Saved Addresses",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // Display saved addresses
            ..._savedAddresses.map((address) => Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                address['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                address['address1'] ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                              if (address['address2'] != null &&
                                  address['address2']!.isNotEmpty)
                                Text(
                                  address['address2'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                '${address['postalCode']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              if (address['phoneNumber'] !=
                                  null) // Check if phoneNumber is not null
                                Text(
                                  'Phone: ${address['phoneNumber']}', // Display phone number
                                  style: const TextStyle(fontSize: 16),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () => _editAddress(address),
                              icon: const Icon(Icons.edit_note_rounded),
                            ),
                            Radio<Map<String, dynamic>>(
                              value: address,
                              groupValue: _selectedAddress,
                              onChanged: (value) {
                                setState(() {
                                  _selectedAddress = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 20),
            // Add Address Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressInputScreen(
                      onSave: _saveAddress,
                    ),
                  ),
                );
              },
              child: const Text("Add Address"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Proceed Button
            ElevatedButton(
              onPressed: _selectedAddress == null
                  ? null
                  : _proceedToDateTimeSlotScreen,
              child: const Text("Proceed"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
