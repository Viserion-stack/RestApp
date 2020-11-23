import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauranttt/screens/cart_screen.dart';
import 'package:restauranttt/screens/notyfication.dart';
import 'package:restauranttt/screens/products_overview_screen.dart';

import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Witaj!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Menu'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ProductsOverviewScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Zamówienia'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(OrdersScreen.routeName);
              // Navigator.of(context).pushReplacement(
              //   CustomRoute(
              //     builder: (ctx) => OrdersScreen(),
              //   ),
              // );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Zarządzaj Produktami'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(UserProductsScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shopping_basket),
            title: Text('Podsumowanie'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(CartScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('Powiadomienia'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Notyfi.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Wyloguj'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');

              // Navigator.of(context)
              //     .pushReplacementNamed(UserProductsScreen.routeName);
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
