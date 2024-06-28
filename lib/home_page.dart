import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:app_trp/profile_screen.dart';
import 'package:app_trp/search_screen.dart';
import 'package:app_trp/model_list.dart';
import 'package:app_trp/constants.dart';
import 'package:app_trp/services_class.dart';

class ModelListScreen extends StatefulWidget {
  const ModelListScreen({Key? key}) : super(key: key);

  @override
  State<ModelListScreen> createState() => _ModelListScreenState();
}

class _ModelListScreenState extends State<ModelListScreen> {
  final List<String> brands = brandNames;
  String? selectedBrand;
  int _currentOfferIndex = 0;
  bool _isDarkMode = false;

  final List<Map<String, dynamic>> offers = [
    {
      'title': 'Summer Sale!',
      'description': 'Get 20% off on all screen repairs this week!',
      'icon': Icons.percent
    },
    {
      'title': 'Refer a Friend',
      'description': 'Get \$10 off your next repair when you refer a friend!',
      'icon': Icons.person
    },
    {
      'title': 'Battery Boost',
      'description': '15% discount on all battery replacements',
      'icon': Icons.battery_full
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedBrand = brands.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200), // Adjust height as needed
        child: AppBar(
          backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.blue[700],
          automaticallyImplyLeading: false, // Disable default back button
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isDarkMode
                      ? [Colors.grey[800]!, Colors.grey[900]!]
                      : [Colors.blue[700]!, Colors.blue[900]!],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, top: 40, bottom: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'QuickFix Mobile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                  _isDarkMode
                                      ? Icons.light_mode
                                      : Icons.dark_mode,
                                  color: _isDarkMode
                                      ? Colors.white
                                      : Colors.white),
                              onPressed: () =>
                                  setState(() => _isDarkMode = !_isDarkMode),
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_none,
                                  color: Colors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'John Doe',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: _isDarkMode
                                      ? Colors.white
                                      : Colors.white),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'New York, NY',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: _isDarkMode
                                      ? Colors.white70
                                      : Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for services...',
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              25), // Maintain your rounded corners
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor:
                            _isDarkMode ? Colors.grey[800] : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8), // Adjust vertical padding
                      ),
                      onSubmitted: (query) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchScreen(query: query),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rest of your UI elements

              _buildSpecialOffers(),
              const SizedBox(height: 24),
              _buildBrandsGrid(),
              const SizedBox(height: 24),
              _buildServicesGrid(),
              const SizedBox(height: 24),
              _buildWhyChooseUs(),
              const SizedBox(height: 24),
              _buildCustomerReviews(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentDeviceCard() {
    return Card(
      color: _isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Current Device',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Samsung Galaxy S21',
                      style: TextStyle(
                          fontSize: 16,
                          color: _isDarkMode ? Colors.white70 : Colors.black87),
                    ),
                    Text(
                      'Last serviced: 3 months ago',
                      style: TextStyle(
                          fontSize: 14,
                          color: _isDarkMode ? Colors.white60 : Colors.black54),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement book repair functionality
                  },
                  child: const Text('Book Repair'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Offers',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 16),
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            autoPlay: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentOfferIndex = index;
              });
            },
          ),
          items: offers.map((offer) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? Colors.grey[700] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(offer['icon'], size: 50, color: Colors.blue),
                        const SizedBox(height: 16),
                        Text(
                          offer['title'],
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _isDarkMode ? Colors.white : Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          offer['description'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14,
                              color: _isDarkMode
                                  ? Colors.white70
                                  : Colors.black87),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBrandsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brands We Service',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: brands.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedBrand = brands[index];
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ModelDetailsScreen(brand: brands[index]),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selectedBrand == brands[index]
                        ? Colors.blue
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/brands/${brands[index].toLowerCase()}.png',
                    width: 55,
                    height: 55,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServicesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Services',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: repairServices.length,
          itemBuilder: (context, index) {
            final service = repairServices[index];
            return Card(
              color: _isDarkMode ? Colors.grey[800] : Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(service.icon, size: 40, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    service.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        color: _isDarkMode ? Colors.white : Colors.black),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWhyChooseUs() {
    final reasons = [
      {
        'icon': Icons.schedule,
        'title': 'Quick Turnaround',
        'description': 'Most repairs completed in 2 hours'
      },
      {
        'icon': Icons.location_on,
        'title': 'Doorstep Service',
        'description': 'We come to you for convenient repairs'
      },
      {
        'icon': Icons.engineering,
        'title': 'Expert Technicians',
        'description': 'Skilled professionals for quality repairs'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Choose Us?',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 16),
        ...reasons.map((reason) => ListTile(
              leading: Icon(reason['icon'] as IconData, color: Colors.blue),
              title: Text(reason['title'] as String,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isDarkMode ? Colors.white : Colors.black)),
              subtitle: Text(reason['description'] as String,
                  style: TextStyle(
                      color: _isDarkMode ? Colors.white70 : Colors.black87)),
            )),
      ],
    );
  }

  Widget _buildCustomerReviews() {
    return Card(
      color: _isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Reviews',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(
                  5,
                  (index) =>
                      Icon(Icons.star, color: Colors.yellow[700], size: 24)),
            ),
            const SizedBox(height: 8),
            Text(
              '4.8 out of 5',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black),
            ),
            Text(
              'Based on 1,234 reviews',
              style: TextStyle(
                  fontSize: 14,
                  color: _isDarkMode ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement read reviews functionality
              },
              child: const Text('Read Reviews'),
            ),
          ],
        ),
      ),
    );
  }
}
