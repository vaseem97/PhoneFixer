import 'package:app_trp/cart_page.dart';
import 'package:app_trp/cart_screen.dart';
import 'package:app_trp/constants.dart';
import 'package:app_trp/main.dart';
import 'package:app_trp/model_list.dart';
import 'package:app_trp/order_screen.dart';

import 'package:app_trp/search_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:app_trp/main.dart' as myApp;
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBar.dart'; // Assuming this import exists

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ModelListScreen(),
    CartScreen(),
    const OrdersScreen(),
  ];

  // Tab labels for MotionTabBar
  final List<String> _tabLabels = ["Models", "Cart", "Orders"];

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<myApp.AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: MotionTabBar(
        initialSelectedTab: _tabLabels[_selectedIndex],
        labels: _tabLabels,
        icons: const [Icons.home, Icons.shopping_cart, Icons.list_alt],
        tabSize: 50,
        tabBarHeight: 55,
        textStyle: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        onTabItemSelected: (int value) {
          setState(() {
            _selectedIndex = value;
          });
        },
      ),
    );
  }
}

class ModelListScreen extends StatefulWidget {
  const ModelListScreen({Key? key}) : super(key: key);

  @override
  State<ModelListScreen> createState() => _ModelListScreenState();
}

class _ModelListScreenState extends State<ModelListScreen> {
  final List<String> brands = brandNames;
  String? selectedBrand;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  final List<String> productOffers = [
    'assets/offers/offer1.jpg',
    'assets/offers/offer2.jpg',
    'assets/offers/offer3.jpg',
  ];

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedBrand = brands.first;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<myApp.AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              } catch (e) {
                print('Error signing out: $e');
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product offer slider
          Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 10),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    aspectRatio: 16 / 9,
                    viewportFraction: 1.0,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: false,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    scrollDirection: Axis.horizontal,
                  ),
                  items: productOffers.map((offer) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Brands',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBrand = brand;
                      _searchController.clear();
                      searchResults.clear();
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModelDetailsScreen(brand: brand),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: selectedBrand == brand
                          ? Colors.deepPurple
                          : Colors.grey,
                      child: Text(
                        brand,
                        style: TextStyle(
                          color: selectedBrand == brand
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
