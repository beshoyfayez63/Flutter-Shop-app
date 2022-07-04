import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/screens/edit_product_screen.dart';

import '../providers/products.dart';
import '../widgets/user_product.dart';
import '../widgets/app_drawer.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';
  const UserProductsScreen({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productData = Provider.of<Products>(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return RefreshIndicator(
              color: Theme.of(context).primaryColor,
              onRefresh: () => _refreshProducts(context),
              child: Consumer<Products>(
                builder: (context, products, _) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                    itemCount: products.items.length,
                    itemBuilder: (ctx, i) => Column(
                      children: [
                        UserProduct(
                          title: products.items[i].title,
                          imageUrl: products.items[i].imageUrl,
                          id: products.items[i].id,
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
