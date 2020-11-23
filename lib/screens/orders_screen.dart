import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauranttt/providers/auth.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    Firebase.initializeApp();
    final fbm = FirebaseMessaging();

    fbm.requestNotificationPermissions();
    fbm.configure(
      onMessage: (msg) {
        print(msg);
        return;
      },
      onLaunch: (msg) {
        print(msg);

        return;
      },
      onResume: (msg) {
        print(msg);
        return;
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('building orders');
    // final orderData = Provider.of<Orders>(context);
    final userData = Provider.of<Auth>(context, listen: false);
    DatabaseReference fbm1 =
        FirebaseDatabase.instance.reference().child('orders');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twoje zamówienia'),
      ),
      drawer: AppDrawer(),
      body: StreamBuilder<Object>(
          stream: fbm1.onValue,
          builder: (context, snapshot) {
            return FutureBuilder(

                //fbm1.onValue, //
                //.fetchAndSetOrders(), //true (slave app)
                // false (mother app)
                future: Provider.of<Orders>(context, listen: false)
                    .fetchAndSetOrders(false),
                //false kazdy widzi wszystko
                //true kazdy widzi swoje
                //dla wyswietlania zamównień tylko po id (slave app)
                builder: (ctx, dataSnapshot) {
                  print('building orders');

                  // if (dataSnapshot.connectionState == ConnectionState.waiting) {
                  //   return Center(child: CircularProgressIndicator());
                  // } else {
                  //   if (dataSnapshot.error != null) {
                  //     // ...
                  //     // Do error handling stuff
                  //     return Center(
                  //       child: const Text('Wystąpił błąd!'),
                  //     );
                  //   } else {
                  return Consumer<Orders>(
                    builder: (ctx, orderData, child) =>
                        orderData.orders.length > 0
                            ? ListView.builder(
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
                                                Provider.of<Orders>(context,
                                                        listen: false)
                                                    .deleteOrder(
                                                  userData.userId,
                                                  orderData.orders[i].id,
                                                ); // true dla usuwania zamowienia po id (slave app)
                                              } catch (error) {
                                                Scaffold.of(ctx).showSnackBar(
                                                  SnackBar(
                                                    content: const Text(
                                                      'Deleting failed!',
                                                      textAlign:
                                                          TextAlign.center,
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
                              )
                            : Center(
                                child: const Text('Brak zamówień!'),
                              ),
                  );
                }
                // }
                // },
                );
          }),
    );
  }
}
