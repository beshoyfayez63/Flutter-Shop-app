import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          leading: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
              onPressed: () {
                product.toggleFavoriteStatus(authData.token, authData.userId);
              },
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_outline),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              // Scaffold.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 2),
                    content: const Text('Added item to cart'),
                    action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          cart.removeSingleItem(product.id);
                        }),
                  ),
                );
            },
            icon: const Icon(Icons.shopping_cart),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
