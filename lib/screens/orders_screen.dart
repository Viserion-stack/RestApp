import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauranttt/providers/auth.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    print('building orders');
    // final orderData = Provider.of<Orders>(context);
    final userData = Provider.of<Auth>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twoje zamówienia'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(
            true), //dla wyświetlania wszystkich zamówien (mother app)
        //future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(true),  dla wyswietlania zamównień tylko po id (slave app)
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              // ...
              // Do error handling stuff
              return Center(
                child: const Text('Wystąpił błąd!'),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (ctx, i) => Dismissible(
                    key: UniqueKey(),
                    background: Container(
                      color: Theme.of(context).errorColor,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 40,
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      margin: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 4,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) {
                      return showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Jesteś pewien?'),
                          content: const Text(
                            'Czy na pewno chcesz usunąć?',
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: const Text('Nie'),
                              onPressed: () {
                                Navigator.of(ctx).pop(false);
                              },
                            ),
                            FlatButton(
                              child: const Text('Tak'),
                              onPressed: () async {
                                Navigator.of(ctx).pop(true);
                                try {
                                  Provider.of<Orders>(context, listen: false)
                                      .deleteOrder(
                                    userData.userId,
                                    orderData.orders[i].id,
                                  ); // true dla usuwania zamowienia po id (slave app)
                                } catch (error) {
                                  Scaffold.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Deleting failed!',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {},
                    child: OrderItem(orderData.orders[i]),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
