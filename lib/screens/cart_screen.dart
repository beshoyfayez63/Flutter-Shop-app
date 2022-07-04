import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/providers/orders.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Consumer<Cart>(
        builder: (BuildContext context, cart, Widget? child) {
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(15),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 20),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                          '\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .titleMedium
                                  ?.color),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      OrderButton(cart: cart)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                  child: ListView.builder(
                itemBuilder: ((context, i) => CartItem(
                      id: cart.items.values.toList()[i].id,
                      // productId: cart.items.keys.toList()[i],
                      removeItem: () =>
                          cart.removeItem(cart.items.keys.toList()[i]),
                      price: cart.items.values.toList()[i].price,
                      quantity: cart.items.values.toList()[i].quantity,
                      title: cart.items.values.toList()[i].title,
                    )),
                itemCount: cart.itemCount,
              ))
            ],
          );
        },
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;
  const OrderButton({
    required this.cart,
    Key? key,
  }) : super(key: key);

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var isBtnDisabled = widget.cart.totalAmount <= 0 || _isLoading;
    return TextButton(
      onPressed: (isBtnDisabled)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Order>(context, listen: false).addOrder(
                widget.cart.items.values.toList(),
                widget.cart.totalAmount,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart.clearCart();
            },
      child: _isLoading
          ? const CircularProgressIndicator()
          : Text(
              'ORDER NOW',
              style: TextStyle(
                color: isBtnDisabled
                    ? Colors.grey
                    : Theme.of(context).primaryColor,
              ),
            ),
    );
  }
}
