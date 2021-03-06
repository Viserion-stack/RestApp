import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _expanded
          ? min(widget.order.products.length * 40.0 + 220, 200)
          : 95, //20 110 200 95
      child: GestureDetector(
        onDoubleTap: () {
          return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Jesteś pewien??'),
              content: const Text(
                'Czy na pewno gotowe ?',
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
                    onPressed: () {
                      Provider.of<ord.Orders>(context, listen: false)
                          .updateOrder(widget.order.id);
                      print(widget.order.id);
                      setState(() {});
                      Navigator.of(ctx).pop(true);
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Zamównienie gotowe!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),
              ],
            ),
          );
        },
        child: Card(
          color: widget.order.isReady ? Colors.green[100] : Colors.white,
          margin: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: FittedBox(
                      child: Text('${widget.order.tableNumber}'),
                    ),
                  ),
                ),
                title: Text('\$${widget.order.amount.toStringAsFixed(2)}'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
                ),
                trailing: IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                height: _expanded
                    ? min(widget.order.products.length * 20.0 + 50,
                        100) //20 10 100
                    : 0,
                child: ListView(
                  children: widget.order.products
                      .map(
                        (prod) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prod.extraComment != null
                                  ? '${prod.extraComment}'
                                  : '',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  prod.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${prod.quantity}x \$${prod.price}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
