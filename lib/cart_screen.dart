import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartItem {
  final String brand;
  final String modelName;
  final String partName;
  final double price;
  int quantity;

  CartItem({
    required this.brand,
    required this.modelName,
    required this.partName,
    required this.price,
    this.quantity = 1,
  });

  get brandName => null;

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'modelName': modelName,
      'partName': partName,
      'price': price,
      'quantity': quantity,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  static CartItem fromMap(Map<String, dynamic> map) {
    return CartItem(
      brand: map['brand'],
      modelName: map['modelName'],
      partName: map['partName'],
      price: map['price'].toDouble(),
      quantity: map['quantity'],
    );
  }
}

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<CartItem> _cartItems = [];

  CartProvider() {
    loadCartItems();
  }

  List<CartItem> get cartItems => _cartItems;

  Future<void> loadCartItems() async {
    if (_auth.currentUser == null) {
      print("No user logged in for loading cart.");
      return;
    }
    var userCartRef =
        _firestore.collection('userCarts').doc(_auth.currentUser!.uid);
    var cartSnapshot = await userCartRef.get();

    if (cartSnapshot.exists) {
      List<dynamic> cartData = cartSnapshot.data()?['cartItems'];
      _cartItems = cartData
          .map((item) => CartItem.fromMap(Map<String, dynamic>.from(item)))
          .toList();
      print("Cart items loaded from Firestore.");
    } else {
      _cartItems = [];
      print("No cart items found in Firestore.");
    }
    notifyListeners();
  }

  Future<void> saveCartItems() async {
    if (_auth.currentUser == null) {
      print("No user logged in.");
      return;
    }
    var userCartRef =
        _firestore.collection('userCarts').doc(_auth.currentUser!.uid);

    List<Map<String, dynamic>> cartData =
        _cartItems.map((item) => item.toMap()).toList();

    await userCartRef.set({'cartItems': cartData}).then((_) {
      print("Cart items saved to Firestore.");
    }).catchError((error) {
      print("Failed to save cart items: $error");
    });

    notifyListeners();
  }

  void addToCart(CartItem item) {
    final existingItem = _cartItems.firstWhereOrNull(
      (cartItem) =>
          cartItem.brand == item.brand &&
          cartItem.modelName == item.modelName &&
          cartItem.partName == item.partName,
    );

    if (existingItem != null) {
      existingItem.quantity++;
    } else {
      _cartItems.add(item);
    }
    saveCartItems();
    notifyListeners(); // Call notifyListeners() to update the UI
  }

  void removeFromCart(CartItem item) {
    _cartItems.removeWhere((cartItem) =>
        cartItem.brand == item.brand &&
        cartItem.modelName == item.modelName &&
        cartItem.partName == item.partName);
    saveCartItems();
    notifyListeners();
  }

  void increaseQuantity(CartItem item) {
    final existingItem = _cartItems.firstWhere(
      (cartItem) =>
          cartItem.brand == item.brand &&
          cartItem.modelName == item.modelName &&
          cartItem.partName == item.partName,
    );
    existingItem.quantity++;
    saveCartItems();
    notifyListeners(); // Call notifyListeners() to update the UI
  }

  void decreaseQuantity(CartItem item) {
    final existingItem = _cartItems.firstWhere(
      (cartItem) =>
          cartItem.brand == item.brand &&
          cartItem.modelName == item.modelName &&
          cartItem.partName == item.partName,
    );
    if (existingItem.quantity > 1) {
      existingItem.quantity--;
    } else {
      _cartItems.remove(existingItem);
    }
    saveCartItems();
    notifyListeners(); // Call notifyListeners() to update the UI
  }

  double get totalAmount {
    return _cartItems.fold(
        0, (total, current) => total + current.price * current.quantity);
  }

  void clearCart() {
    _cartItems.clear();
    saveCartItems();
  }
}
