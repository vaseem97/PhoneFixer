import 'package:app_trp/home_page.dart';
import 'package:app_trp/order_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _getCurrentUserPhoneNumber();
  }

  void _getCurrentUserPhoneNumber() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _phoneNumber = user.phoneNumber;
    }
    setState(() {});
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to the login screen or perform any additional actions
    } catch (e) {
      // Handle logout error
      print('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to the ModelListScreen when the back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ModelListScreen()),
        );
        return false; // Return false to prevent the default behavior of closing the app
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Information Section
                const Text(
                  'My account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  _phoneNumber ?? 'Please Login ',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(icon: Icons.wallet, label: 'Wallet'),
                    _buildActionButton(icon: Icons.chat, label: 'Support'),
                    _buildActionButton(
                        icon: Icons.credit_card, label: 'Payments'),
                  ],
                ),
                const SizedBox(height: 30),

                // Your Information Section
                const Text(
                  'YOUR INFORMATION',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildListTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Your orders',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OrdersScreen()),
                    );
                  },
                ),
                _buildListTile(
                  icon: Icons.home_outlined,
                  title: 'Address book',
                  onTap: () {},
                ),

                _buildListTile(
                  icon: Icons.power_settings_new_outlined,
                  title: 'Log out',
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label}) {
    return Column(
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(icon, size: 30),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
