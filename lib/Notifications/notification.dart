import 'package:flutter/foundation.dart';

class NotificationItem {
  final int id;
  final String title;

  NotificationItem({
    @required this.id,
    @required this.title,
  });
}

class Notification with ChangeNotifier {
  Map<String, NotificationItem> _items = {};

  Map<String, NotificationItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  void changeQuantity(int productId, int quantity) {
    _items.update(
      productId.toString(),
          (existingCartItem) => NotificationItem(
        id: existingCartItem.id,
        title: existingCartItem.title,
      ),
    );
    notifyListeners();
  }

  void addItem(int productId, String title) {
    if (_items.containsKey(productId.toString())) {
      // change quantity...
      _items.update(
        productId.toString(),
            (existingCartItem) => NotificationItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId.toString(),
            () => NotificationItem(
          id: productId,
          title: title,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
