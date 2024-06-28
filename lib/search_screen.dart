import 'package:app_trp/cart_screen.dart';
import 'package:app_trp/constants.dart';
import 'package:app_trp/parts_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key, required String query}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<String> brands = brandNames;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  Future<void> searchModels(String query) async {
    if (query.isNotEmpty) {
      final searchResults = <Map<String, dynamic>>[];

      for (final brand in brands) {
        final brandCollection =
            FirebaseFirestore.instance.collection(brand.toLowerCase());
        final modelSnapshot = await brandCollection
            .where('modelName', isGreaterThanOrEqualTo: query.toLowerCase())
            .where('modelName', isLessThan: '${query.toLowerCase()}\uf8ff')
            .get();

        final models = modelSnapshot.docs.map((doc) {
          final parts = doc['parts'] as Map<String, dynamic>?;
          return {
            'brand': brand,
            'modelName': doc['modelName'],
            'parts': parts,
          };
        }).toList();

        searchResults.addAll(models);
      }

      setState(() {
        this.searchResults = searchResults;
      });
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search models...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onChanged: searchModels,
            ),
          ),
          Expanded(
            child: searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final result = searchResults[index];
                      final brand = result['brand'] as String;
                      final modelName = result['modelName'] as String;
                      final parts = result['parts'] as Map<String, dynamic>?;
                      return ListTile(
                        title: Text('$brand $modelName'),
                        subtitle: parts != null
                            ? Text(
                                'Parts: ${parts.entries.map((entry) => '${entry.key} (${formatCurrency(double.tryParse(entry.value) ?? 0.0, 'INR')})').join(', ')}')
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PartsDetailsScreen(
                                brand: brand,
                                modelName: modelName,
                                parts: parts ?? {},
                                cartProvider: cartProvider,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : const Center(
                    child: Text('No search results'),
                  ),
          ),
        ],
      ),
    );
  }
}
