import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final double price;

  final String restaurantId;
  final String restaurantName;

  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.restaurantId,
    required this.restaurantName,
    this.quantity = 1,
  });
}

class FoodService extends ChangeNotifier {
  // 🛒 Cart Logic
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get totalItems =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.values.fold(
    0,
        (sum, item) => sum + (item.price * item.quantity),
  );

  // ➕ Add Item
  void addToCart(
      String id,
      String name,
      double price,
      String restaurantId,
      String restaurantName,
      ) {
    if (_items.containsKey(id)) {
      _items.update(
        id,
            (existing) => CartItem(
          id: id,
          name: name,
          price: price,
          restaurantId: existing.restaurantId,
          restaurantName: existing.restaurantName,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        id,
            () => CartItem(
          id: id,
          name: name,
          price: price,
          restaurantId: restaurantId,
          restaurantName: restaurantName,
        ),
      );
    }

    notifyListeners();
  }

  // ➖ Decrease Quantity
  void decrementQuantity(String id) {
    if (!_items.containsKey(id)) return;

    if (_items[id]!.quantity > 1) {
      _items.update(
        id,
            (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          restaurantId: existing.restaurantId,
          restaurantName: existing.restaurantName,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(id); // ❌ Remove item completely if quantity becomes 0
    }

    notifyListeners(); // 🚀 Refresh UI
  }

  // 🗑 Clear Cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}