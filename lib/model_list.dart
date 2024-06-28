// lib/model_details_screen.dart
import 'package:app_trp/cart_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'parts_details_screen.dart';

class ModelDetailsScreen extends StatefulWidget {
  final String brand;

  const ModelDetailsScreen({Key? key, required this.brand}) : super(key: key);

  @override
  _ModelDetailsScreenState createState() => _ModelDetailsScreenState();
}

class _ModelDetailsScreenState extends State<ModelDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.brand} Models'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        scrolledUnderElevation: 4.0, // Add elevation when scrolled under
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(widget.brand.toLowerCase())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching data: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final models = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              final modelName = model['modelName'] ?? '';
              final parts = model['parts'] ?? {};

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PartsDetailsScreen(
                        brand: widget.brand,
                        modelName: modelName,
                        parts: parts,
                        cartProvider: cartProvider,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: const DecorationImage(
                              image: AssetImage(
                                  'assets/images/demo.png'), // Fixed image path
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                modelName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        // Use TextTheme

                                        ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to view parts',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium, // Use TextTheme
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
