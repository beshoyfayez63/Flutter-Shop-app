import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String? id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'products': products,
        'dateTime': dateTime.toIso8601String(),
      };
}

class Order with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? authToken;
  final String? userId;

  Order(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
      'https://flutter-shopping-app-27d25-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken',
    );

    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;
    if (extractedData == null) {
      _orders = [];
      notifyListeners();
      return;
    }

    extractedData.forEach((orderId, orderValue) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderValue['amount'],
          products: (orderValue['products'] as List<dynamic>)
              .map((product) => CartItem.fromJson(product))
              .toList(),
          dateTime: DateTime.parse(orderValue['dateTime']),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timeStamp = DateTime.now();
    final url = Uri.parse(
      'https://flutter-shopping-app-27d25-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken',
    );

    final order = OrderItem(
      amount: total,
      products: cartProducts,
      dateTime: timeStamp,
    );

    final response = await http.post(url, body: json.encode(order));

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }
}
