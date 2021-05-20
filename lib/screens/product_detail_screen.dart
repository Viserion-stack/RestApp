import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../providers/cart.dart';

class ProductDetailScreen extends StatefulWidget {
  // final String title;
  // final double price;

  // ProductDetailScreen(this.title, this.price);
  static const routeName = '/product-detail';

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final descriptionController = TextEditingController();
  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    final productId =
        ModalRoute.of(context).settings.arguments as String; // is the id!
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(height: 10),
                Text(
                  '\$${loadedProduct.price}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    loadedProduct.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Form(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Komentarz'),
                      textInputAction: TextInputAction.done,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      controller: descriptionController,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      //borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).accentColor),
                  child: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.shopping_basket),
                      tooltip: 'Dodaj do zamówienia',

                      iconSize: 50,
                      color: Colors.white, //Theme.of(context).accentColor,
                      onPressed: () {
                        cart.addItem(
                            loadedProduct.id,
                            loadedProduct.price,
                            loadedProduct.title,
                            descriptionController
                                .text); //4 arg as extra comment

                        descriptionController.clear();

                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Dodano do zamówienia!'),
                            duration: Duration(seconds: 2),
                            action: SnackBarAction(
                                label: 'COFNIJ',
                                onPressed: () {
                                  cart.removeSingleItem(loadedProduct.id);
                                }),
                          ),
                        );

                        // Future.delayed(Duration(milliseconds: 1300), () {
                        //   // 1,3s over, navigate to a new page
                        //   Navigator.of(context).pop();
                        // });
                        // opóźnienie po recznym dodaniu produktu do zamówienia
                      },
                    ),
                  ),
                ),
                Text(
                  'Dodaj!',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
