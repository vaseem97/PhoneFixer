import 'package:intl/intl.dart';

const List<String> brandNames = [
  'Apple',
  'OnePlus',
  'Samsung',
  'Xiaomi',
  'Oppo',
  'Vivo',
  'Realme',
  'Motorola',
];

const cartsCollectionName = 'carts';
const cartItemsCollectionName = 'items';

String formatCurrency(double price, String currencyCode) {
  final currencyFormatter = NumberFormat.simpleCurrency(
    locale: 'en_IN', // Set locale for Indian Rupee
    name: currencyCode, // Pass the currency code
  );
  return currencyFormatter.format(price);
}
