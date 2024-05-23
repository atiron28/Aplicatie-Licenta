// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Profile/pagini/pagina_adrese.dart';

import 'package:provider/provider.dart';
import 'package:gastrogrid_app/providers/provider_cart.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/cart.dart';
import 'package:gastrogrid_app/providers/provider_livrare.dart';
import 'package:gastrogrid_app/providers/theme_provider.dart';

class ShoppingCartPage extends StatefulWidget {

 
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {

  String? _selectedAddress;
  

  void _selectDeliveryAddress() async {
    final selectedAddress = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SavedAddressesPage(),
      ),
    );

    if (selectedAddress != null) {
      setState(() {
        _selectedAddress = selectedAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final deliveryInfo = Provider.of<DeliveryProvider>(context);
    

    double deliveryFee = cart.items.isEmpty ? 0.0 : (deliveryInfo.isDelivery ? deliveryInfo.deliveryFee : 0);
    double total = cart.total + deliveryFee;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.themeData.colorScheme.background,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Column(
              children: [
                Flexible(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) => _buildCartItem(cart.items[index]),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDeliveryInfoSection(deliveryInfo),
                _buildTotalSection(cart, deliveryFee, total),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoSection(DeliveryProvider deliveryInfo) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: themeProvider.themeData.colorScheme.background,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: deliveryInfo.isDelivery
          ? ListTile(
              title: Text('Selectați adresa de livrare'),
              subtitle: Text(deliveryInfo.selectedAddress ?? 'Nu a fost selectată nicio adresă'),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: _selectDeliveryAddress,
            )
          : ListTile(
              title: Text('Ridicare personală activată'),
              subtitle: Text('Produsele vor fi ridicate de la magazin'),
            ),
    );
  }

  Widget _buildCartItem(CartItem item) {
   
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                   
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Price: \$${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Quantity: ${item.quantity}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildQuantityControls(item),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(CartItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            if (item.quantity > 1) {
              Provider.of<CartProvider>(context, listen: false).updateProductQuantity(item, item.quantity - 1);
            } else {
              Provider.of<CartProvider>(context, listen: false).removeProduct(item);
            }
          },
        ),
        Text(item.quantity.toString()),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Provider.of<CartProvider>(context, listen: false).updateProductQuantity(item, item.quantity + 1);
          },
        ),
      ],
    );
  }

  Widget _buildTotalSection(CartProvider cart, double deliveryFee, double total) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.only(top:0,left:15,right:15),
      decoration: BoxDecoration(
        color: themeProvider.themeData.colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryLine('Produse în coș:', '${cart.totalItemsQuantity}'),
            _buildSummaryLine('Subtotal:', '${cart.total.toStringAsFixed(2)} lei'),
            _buildSummaryLine('Livrare:', cart.items.isEmpty ? '0 lei' : '${deliveryFee.toStringAsFixed(2)} lei'),
            Divider(),
            _buildSummaryLine('Total:', '${total.toStringAsFixed(2)} lei', isTotal: true),
            SizedBox(height: 20),
            ElevatedButton(
              
              onPressed: () {
                // Logică pentru finalizarea comenzii
              },
              child: Text('FINALIZEAZA COMANDA', style: TextStyle(color: themeProvider.themeData.colorScheme.primary)),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String title, String value, {bool isTotal = false}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: isTotal ? 18 : 16, color: isTotal ? themeProvider.themeData.colorScheme.primary : themeProvider.themeData.colorScheme.primary)),
          Text(value, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}