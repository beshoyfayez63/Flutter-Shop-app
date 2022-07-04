import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Order;
import '../widgets/OrderItem.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future? _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Order>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    super.initState();
    _ordersFuture = _obtainOrdersFuture();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Order>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              itemBuilder: (ctx, i) => OrderItem(
                orderItem: orderData.orders[i],
              ),
              itemCount: orderData.orders.length,
            );
          }
        },
      ),
    );
  }
}
