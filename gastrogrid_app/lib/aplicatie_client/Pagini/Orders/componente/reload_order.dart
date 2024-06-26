import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/clase/clasa_cart.dart';
import 'package:gastrogrid_app/clase/clasa_produs.dart';
import 'package:gastrogrid_app/providers/provider_cart.dart';

void reloadOrder(BuildContext context, List<dynamic> items) {
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  for (var item in items) {
    var productData = item['product'];
    if (productData != null) {
      var product = Product.fromMap(productData, productData['id'] ?? 'unknown');
      var cartItem = CartItem(
        product: product,
        quantity: item['quantity'],
      );
      cartProvider.addProductToCart(cartItem, context);
    }
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Produsele au fost adaugate în cos')),
  );
}
