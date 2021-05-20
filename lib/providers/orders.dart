import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  final String tableNumber;
  final bool isReady;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
    this.extraComment,
    @required this.tableNumber,
    @required this.isReady,
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

  final fbm = FirebaseMessaging();

  Future<void> fetchAndSetOrders([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://flutter-update-fb73c.firebaseio.com/orders.json?auth=$authToken&$filterString';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      _orders = [];
      notifyListeners();
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
          isReady: orderData['isReady'],
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
      List<CartItem> cartProducts, double total, String tableNumber) async {
    final url =
        'https://flutter-update-fb73c.firebaseio.com/orders.json?auth=$authToken';
    final tokenId = await fbm.getToken();
    //print(tokenId);
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
        'token': tokenId,
        'isReady': false,
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
        isReady: json.decode(response.body)['isReady'],
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
    notifyListeners();
  }

  Future<void> updateOrder(String ordId, [bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://flutter-update-fb73c.firebaseio.com/orders/$ordId.json?auth=$authToken&$filterString';

    final existingOrderIndex = _orders.indexWhere((ord) => ord.id == ordId);
    var existingOrder = _orders[existingOrderIndex];
    //_orders.removeAt(existingOrderIndex);
    //notifyListeners();
    final response = await http.patch(url,
        body: json.encode({
          'isReady': true,
        }));
    if (response.statusCode >= 400) {
      print('Udało się isReady na true');
      _orders.insert(existingOrderIndex, existingOrder);
      notifyListeners();
      throw HttpException('Nie można usunąć zamówienia.');
    }
    existingOrder = null;
  }
}
