import 'package:flutter/material.dart';
import 'package:app_trp/add_adress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressListScreen extends StatelessWidget {
  final Function(Map<String, dynamic>) onAddressSelected;

  const AddressListScreen({
    Key? key,
    required this.onAddressSelected,
    required List<Map<String, dynamic>> addresses,
  }) : super(key: key);

  Future<void> _editAddress(
      BuildContext context, Map<String, dynamic> address, String userId) async {
    final updatedAddress = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressInputScreen(
          address: address,
          onSave: (updatedAddress) {
            // If the address has an id, update it in Firebase
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('addresses')
                .doc(address['id'])
                .update(updatedAddress);
          },
        ),
      ),
    );

    if (updatedAddress != null) {
      updatedAddress['id'] = address['id']; // Make sure to keep the id
      onAddressSelected(updatedAddress);
      Navigator.pop(context);
    }
  }

  Future<void> _addAddress(BuildContext context, String userId) async {
    // Check if the user has reached the address limit
    final addressesCount = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .get()
        .then((snapshot) => snapshot.docs.length);

    if (addressesCount >= 3) {
      // Show a warning dialog if the address limit is reached
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Address Limit Reached'),
          content: const Text(
              'You have reached the maximum number of allowed addresses (3).'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final newAddress = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressInputScreen(
          onSave: (newAddress) async {
            final docRef = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('addresses')
                .add(newAddress);
            newAddress['id'] = docRef.id; // Add the generated id
            return newAddress;
          },
        ),
      ),
    );

    if (newAddress != null) {
      onAddressSelected(newAddress);
      Navigator.pop(context);
    }
  }

  Future<void> _deleteAddress(
      BuildContext context, String userId, String addressId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('addresses')
                  .doc(addressId)
                  .delete();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data!;
        final userId = user.uid;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('addresses')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final addresses = snapshot.data?.docs.map((doc) {
                  return {...doc.data() as Map<String, dynamic>, 'id': doc.id};
                }).toList() ??
                [];

            return Scaffold(
              appBar: AppBar(
                title: const Text('Select Address'),
                backgroundColor: Colors.deepPurple,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addAddress(context, userId),
                  ),
                ],
              ),
              body: addresses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No addresses found.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _addAddress(context, userId),
                            child: const Text('Add New Address'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return GestureDetector(
                          onTap: () {
                            onAddressSelected(address);
                            Navigator.pop(context);
                          },
                          child: Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: Colors.deepPurple,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        address['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _editAddress(
                                            context, address, userId),
                                        color: Colors.deepPurple,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _deleteAddress(
                                            context, userId, address['id']),
                                        color: Colors.deepPurple,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        color: Colors.deepPurple,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Mobile: ${address['phoneNumber'] ?? ''}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.deepPurple,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              address['address1'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                            if (address['address2'] != null &&
                                                address['address2']!.isNotEmpty)
                                              Text(
                                                address['address2'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.deepPurple,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.local_post_office,
                                        color: Colors.deepPurple,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${address['postalCode']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }
}
