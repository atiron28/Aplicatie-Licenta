import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/providers/provider_adresa_plata_cart.dart';
import 'package:gastrogrid_app/providers/provider_livrare.dart';
import 'package:gastrogrid_app/providers/provider_themes.dart';

class DeliveryInfoSection extends StatelessWidget {
  final DeliveryProvider deliveryInfo;
  final SelectedOptionsProvider optionsProvider;
  final VoidCallback onSelectDeliveryAddress;

  const DeliveryInfoSection({super.key, 
    required this.deliveryInfo,
    required this.optionsProvider,
    required this.onSelectDeliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: themeProvider.themeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: deliveryInfo.isDelivery
          ? ListTile(
              title: Text('Adresa selectata'),
              subtitle: Text(optionsProvider.selectedAddress ?? 'Nu a fost selectata nicio adresa'),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: onSelectDeliveryAddress,
            )
          : ListTile(
              title: Text('Ridicare personală activata'),
              subtitle: Text('Produsele vor fi ridicate de la magazin'),
            ),
    );
  }
}
