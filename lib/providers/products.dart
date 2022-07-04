import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';
import '../models/http_exception.dart';

// ChangeNotifier: related to inherited widgets
class Products with ChangeNotifier {
  List<Product> _items = [];

  final String? authToken;
  final String? userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // we get copy of the item because if we edit items in any another place we cant notify all another places that items changed
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) {
      // print(item.isFavorite ? item.title : null);
      return item.isFavorite;
    }).toList();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    print(authToken);
    try {
      var filterString =
          filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
      var url = Uri.parse(
        'https://flutter-shopping-app-27d25-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString',
      );

      final response = await http.get(url);
      // print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      url = Uri.parse(
        'https://flutter-shopping-app-27d25-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken',
      );
      final favoriteResponse = await http.get(url);
      final favoriteData = jsonDecode(favoriteResponse.body);
      List<Product> fetchedProducts = [];
      extractedData.forEach((prodId, prodData) {
        fetchedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      _items = fetchedProducts;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  Future<void> addProduct(Product product) async {
    try {
      final url = Uri.parse(
        'https://flutter-shopping-app-27d25-default-rtdb.firebaseio.com/products.json?auth=$authToken',
      );

      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
          'creatorId': userId,
        }),
      );
      final newProduct =
          product.copyWith(id: json.decode(response.body)['name']);
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    var prodIndex = _items.indexWhere((product) => product.id == id);

    if (prodIndex < 0) return;
    final url = Uri.parse(
      'https://flutter-shopping-app-27d25-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken',
    );
    await http.patch(url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
        }));
    _items[prodIndex] = product;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
      'https://flutter-shopping-app-27d25-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken',
    );
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }
}
