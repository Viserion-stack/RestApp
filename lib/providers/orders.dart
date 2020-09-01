import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:restauranttt/models/http_exception.dart';

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  final String extraComment;
  final int tableNumber;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
    this.extraComment,
    @required this.tableNumber,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://flutter-update-fb73c.firebaseio.com/orders.json?auth=$authToken&$filterString';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          extraComment: orderData['extraComment'],
          tableNumber: orderData['tableNumber'],
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                  extraComment: item['extraComment'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(
      List<CartItem> cartProducts, double total, int tableNumber) async {
    final url =
        'https://flutter-update-fb73c.firebaseio.com/orders.json?auth=$authToken';
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'tableNumber': tableNumber,
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                  'extraComment': cp.extraComment,
                })
            .toList(),
        'creatorId': userId,
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        tableNumber: tableNumber,
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
        extraComment: json.decode(response.body)['extraComment'],
      ),
    );
    notifyListeners();
  }

  Future<void> deleteOrder(String userId, String ordId,
      [bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://flutter-update-fb73c.firebaseio.com/orders/$ordId.json?auth=$authToken&$filterString';

    final existingOrderIndex = _orders.indexWhere((ord) => ord.id == ordId);
    var existingOrder = _orders[existingOrderIndex];
    _orders.removeAt(existingOrderIndex);
    //notifyListeners();
    final response = await http.delete(url);
    print(json.decode(response.body));
    if (response.statusCode >= 400) {
      _orders.insert(existingOrderIndex, existingOrder);
      notifyListeners();
      throw HttpException('Nie można usunąć zamówienia.');
    }
    existingOrder = null;
  }
}
