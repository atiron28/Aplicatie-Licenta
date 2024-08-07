// Importă biblioteca principală Flutter pentru a crea interfețe de utilizator.
import 'package:flutter/material.dart';

// Importă providerul pentru gestionarea livrărilor.
import 'package:gastrogrid_app/providers/provider_livrare.dart';

// Importă pachetul provider pentru gestionarea stării.
import 'package:provider/provider.dart';

// Declarația unei clase stateful pentru butoanele de toggle pentru livrare.
class DeliveryToggleButtons extends StatefulWidget {
  const DeliveryToggleButtons({super.key});

  @override
  _DeliveryToggleButtonsState createState() => _DeliveryToggleButtonsState();
}

// Declarația stării pentru clasa DeliveryToggleButtons.
class _DeliveryToggleButtonsState extends State<DeliveryToggleButtons> {
  @override
  Widget build(BuildContext context) {
    // Obține informațiile de livrare folosind providerul.
    final deliveryInfo = Provider.of<DeliveryProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Padding pentru a adăuga spațiu în jurul butoanelor.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Buton pentru opțiunea de livrare.
              _buildDeliveryButton(deliveryInfo.isDelivery),
              SizedBox(width: 10),
              // Buton pentru opțiunea de ridicare.
              _buildPickupButton(!deliveryInfo.isDelivery),
            ],
          ),
        ),
        SizedBox(height: 16),
        // Afișează informațiile de livrare sau ridicare, în funcție de selecție.
        Center(
          child: deliveryInfo.isDelivery 
            ? _buildDeliveryInfo(deliveryInfo) 
            : _buildPickupInfo(deliveryInfo),
        ),
      ],
    );
  }

  // Metodă pentru construirea butonului de livrare.
  Widget _buildDeliveryButton(bool isDeliverySelected) {
    return _buildToggleButton(
      'Livrare', 
      isDeliverySelected, 
      Icons.delivery_dining,
      () {
        Provider.of<DeliveryProvider>(context, listen: false).toggleDelivery(true);
      }
    );
  }

  // Metodă pentru construirea butonului de ridicare.
  Widget _buildPickupButton(bool isPickupSelected) {
    return _buildToggleButton(
      'Ridicare', 
      isPickupSelected, 
      Icons.storefront,
      () {
        Provider.of<DeliveryProvider>(context, listen: false).toggleDelivery(false);
      }
    );
  }

  // Metodă pentru construirea unui buton de toggle.
  Widget _buildToggleButton(String text, bool isSelected, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : const Color.fromARGB(255, 238, 238, 238),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.blue.withOpacity(0.3), spreadRadius: 1, blurRadius: 8)]
              : [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5)],
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black, size: 18),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Metodă pentru afișarea informațiilor de livrare.
  Widget _buildDeliveryInfo(DeliveryProvider deliveryInfo) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timelapse_outlined, size: 14, color: Colors.blue),
        SizedBox(width: 4),
        Text('${deliveryInfo.formattedDeliveryTime}', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.inversePrimary)),
        SizedBox(width: 16),
        Icon(Icons.delivery_dining_outlined, size: 16, color: Colors.blue),
        SizedBox(width: 4),
        Text('${deliveryInfo.deliveryFee} lei', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.inversePrimary)),
      ],
    );
  }

  // Metodă pentru afișarea informațiilor de ridicare.
  Widget _buildPickupInfo(DeliveryProvider deliveryInfo) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timelapse_outlined, size: 14, color: Colors.blue),
        SizedBox(width: 4),
        Text('${deliveryInfo.formattedDeliveryTime}', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.inversePrimary)),
      ],
    );
  }
}
