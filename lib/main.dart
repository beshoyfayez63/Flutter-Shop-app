import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/cart_screen.dart';
import './screens/order_screen.dart';
import './screens/user_products_screen.dart';
import './screens/auth_screen.dart';
import './screens/edit_product_screen.dart';

import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products(null, null, []),
          update: (ctx, auth, previousProducts) =>
              Products(auth.token, auth.userId, previousProducts!.items),
        ),
        ChangeNotifierProvider(create: (ctx) => Cart()),
        ChangeNotifierProxyProvider<Auth, Order>(
          create: (ctx) => Order(null, null, []),
          update: (_, auth, order) =>
              Order(auth.token, auth.userId, order!.orders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, child) => MaterialApp(
          theme: ThemeData(
            appBarTheme: const AppBarTheme(color: Colors.purple),
            primarySwatch: Colors.purple,
            colorScheme:
                ThemeData().colorScheme.copyWith(secondary: Colors.deepOrange),
            fontFamily: 'Lato',
            progressIndicatorTheme:
                const ProgressIndicatorThemeData(color: Colors.purple),
          ),
          // home: const ProductsOverviewScreen(),
          home: auth.isAuth
              ? const ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      print('WAITING....');
                      return const SplashScreen();
                    } else {
                      return const AuthScreen();
                      // return const ProductsOverviewScreen();
                    }
                  },
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => const EditProductScreen(),
          },
        ),
      ),
    );
  }
}
