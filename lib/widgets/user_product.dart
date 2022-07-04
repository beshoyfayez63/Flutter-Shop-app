import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../screens/edit_product_screen.dart';

class UserProduct extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  const UserProduct({
    required this.title,
    required this.imageUrl,
    required this.id,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(children: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditProductScreen.routeName, arguments: id);
            },
            icon: const Icon(Icons.edit),
            color: Theme.of(context).primaryColor,
          ),
          IconButton(
            onPressed: () async {
              try {
                await Provider.of<Products>(context, listen: false)
                    .deleteProduct(id);
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Deleting failed!'),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.delete,
            ),
            color: Theme.of(context).errorColor,
          ),
        ]),
      ),
    );
  }
}
