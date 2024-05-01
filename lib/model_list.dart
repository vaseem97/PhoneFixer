import 'package:app_trp/cart_screen.dart';
import 'package:app_trp/constants.dart';
import 'package:app_trp/parts_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0.0,
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
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              final modelName = model['modelName'] ?? '';
              final parts = model['parts'] ?? {};
              final lcdPrice =
                  double.tryParse(parts['LCD']?.toString() ?? '0.0') ?? 0.0;
              final batteryPrice =
                  double.tryParse(parts['Battery']?.toString() ?? '0.0') ?? 0.0;
              final backPanelPrice =
                  double.tryParse(parts['Back Panel']?.toString() ?? '0.0') ??
                      0.0;

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
                  elevation: 6,
                  margin: const EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            modelName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'LCD: ${formatCurrency(lcdPrice, 'INR')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Battery: ${formatCurrency(batteryPrice, 'INR')}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Back Panel: ${formatCurrency(backPanelPrice, 'INR')}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
