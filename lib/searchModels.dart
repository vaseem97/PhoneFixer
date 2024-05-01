import 'package:cloud_firestore/cloud_firestore.dart';

class SearchFunctions {
  static Future<List<Map<String, dynamic>>> searchModels(
      String query, List<String> brands) async {
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

      return searchResults;
    } else {
      return [];
    }
  }
}
