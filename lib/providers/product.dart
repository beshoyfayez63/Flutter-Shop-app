import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;
  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  void _setFavoriteValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  void toggleFavoriteStatus(String? authToken, String? userId) async {
    final oldStatus = isFavorite;

    _setFavoriteValue(!isFavorite);
    final url = Uri.parse(
      'https://flutter-shopping-app-27d25-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken',
    );
    try {
      final response = await http.put(url, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        throw HttpException('Something went wrong');
      }
    } catch (e) {
      _setFavoriteValue(oldStatus);
      rethrow;
    }
  }
}
