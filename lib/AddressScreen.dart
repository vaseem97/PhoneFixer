import 'package:app_trp/date_time_slot_screen.dart';
import 'package:app_trp/edit_chose_address.dart';
import 'package:flutter/material.dart';
import 'package:app_trp/add_adress.dart';
import 'package:app_trp/cart_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:intl/intl.dart';

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
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isLoading = true;

  final List<String> _timeSlots = [
    "10:00 AM - 12:00 PM",
    "12:00 PM - 2:00 PM",
    "2:00 PM - 4:00 PM",
    "4:00 PM - 6:00 PM"
  ];

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
      final addressCollection = userDoc.collection('addresses');

      final snapshot = await addressCollection.get();

      setState(() {
        _savedAddresses =
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
        if (_savedAddresses.isNotEmpty) {
          _selectedAddress = _savedAddresses.first;
        }
        _isLoading = false;
      });
    }
  }

  void _proceedToPaymentScreen() {
    if (_selectedAddress != null &&
        _selectedDate != null &&
        _selectedTimeSlot != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            selectedAddress: _selectedAddress!,
            selectedDate: _selectedDate!,
            selectedTimeSlot: _selectedTimeSlot!,
            cartItems: widget.cartItems,
            totalPrice: widget.totalPrice,
          ),
        ),
      );
    }
  }

  Future<void> _saveAddress(Map<String, dynamic> address) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final addressCollection = userDoc.collection('addresses');

      // Fetch current addresses
      final snapshot = await addressCollection.get();
      final savedAddresses =
          snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();

      // Check if the address is already in the collection
      final existingIndex =
          savedAddresses.indexWhere((item) => item['id'] == address['id']);

      if (existingIndex != -1) {
        // Update existing address
        await addressCollection.doc(address['id']).update(address);
      } else if (savedAddresses.length < 3) {
        // Add new address if less than 3
        final docRef = await addressCollection.add(address);
        address['id'] = docRef.id;
        await docRef.update({'id': docRef.id});
      } else {
        // Handle the case where the user already has 3 addresses
        throw Exception("You can only save a maximum of 3 addresses.");
      }

      _fetchSavedAddresses();
    }
  }

  List<DateTime> _getUpcomingDates() {
    final List<DateTime> dates = [];
    final now = DateTime.now();
    for (int i = 0; i < 4; i++) {
      dates.add(now.add(Duration(days: i)));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Address"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Address Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _savedAddresses.isEmpty
                            ? Center(
                                child: Column(
                                  children: [
                                    const Text(
                                      "No addresses found.",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddressInputScreen(
                                              onSave: _saveAddress,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      child: const Text('Add New Address'),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  _buildAddressCard(_selectedAddress!),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddressListScreen(
                                            addresses: _savedAddresses,
                                            onAddressSelected:
                                                (selectedAddress) {
                                              setState(() {
                                                _selectedAddress =
                                                    selectedAddress;
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Choose Another Address',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 20),
                        const Divider(),
                        // Book Slot Section
                        Text(
                          'Select Date',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Date',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        _buildDateSelectionRow(),
                        const SizedBox(height: 20),
                        // Time Slot Selection
                        Text(
                          'Select Time',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTimeSlotSelectionRow(),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Proceed Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_selectedAddress == null ||
                                _selectedDate == null ||
                                _selectedTimeSlot == null)
                            ? null
                            : _proceedToPaymentScreen,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Proceed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDateSelectionRow() {
    final upcomingDates = _getUpcomingDates();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: upcomingDates.map((date) => _buildDateButton(date)).toList(),
    );
  }

  Widget _buildDateButton(DateTime date) {
    final isSelected = _selectedDate != null &&
        _selectedDate!.day == date.day &&
        _selectedDate!.month == date.month &&
        _selectedDate!.year == date.year;
    final formatter = DateFormat('E');
    final dayOfWeek = formatter.format(date);

    return GestureDetector(
      onTap: () {
        if (_selectedAddress != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: Container(
        width: 70,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:
              isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayOfWeek,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotSelectionRow() {
    return Column(
      children: [
        Divider(
          color: Colors.grey[300],
          thickness: 1,
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.spaceBetween,
          children:
              _timeSlots.map((slot) => _buildTimeSlotButton(slot)).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSlotButton(String timeSlot) {
    final isSelected = _selectedTimeSlot == timeSlot;

    return GestureDetector(
      onTap: () {
        if (_selectedDate != null) {
          setState(() {
            _selectedTimeSlot = timeSlot;
          });
        }
      },
      child: Container(
        width: (MediaQuery.of(context).size.width / 2) - 30,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:
              isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: Center(
          child: Text(
            timeSlot,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddress = address;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: _selectedAddress == address
                ? Theme.of(context).colorScheme.primary
                : Colors.white,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  address['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.phone,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Mobile: ${address['phoneNumber'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address['address1'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      if (address['address2'] != null &&
                          address['address2']!.isNotEmpty)
                        Text(
                          address['address2'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
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
                Icon(
                  Icons.local_post_office,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  '${address['postalCode']}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
