import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAddressPage extends StatefulWidget {
  final String addressId;
  final String street;
  final String city;
  final String state;
  final String zipCode;

  const EditAddressPage({super.key, 
    required this.addressId,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;
  String? userId;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController(text: widget.street);
    _cityController = TextEditingController(text: widget.city);
    _stateController = TextEditingController(text: widget.state);
    _zipCodeController = TextEditingController(text: widget.zipCode);
    _initializeUser();
  }

  void _initializeUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilizatorul nu este autentificat')),
      );
    }
  }

  void _saveAddress() async {
    if (userId != null && widget.addressId.isNotEmpty) {
      try {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(widget.addressId);
        await docRef.set({
          'street': _streetController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'zipCode': _zipCodeController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adresa a fost salvata')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la salvarea adresei: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID sau Address ID lipseste')),
      );
    }
  }

  void _removeAddress() async {
    if (userId != null && widget.addressId.isNotEmpty) {
      try {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(widget.addressId);
        await docRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adresa a fost stearsă')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la stergerea adresei: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID sau Address ID lipseste')),
      );
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editeaza Adresa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _streetController,
              decoration: InputDecoration(labelText: 'Strada'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'Oras'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _stateController,
              decoration: InputDecoration(labelText: 'Judet'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _zipCodeController,
              decoration: InputDecoration(labelText: 'Cod postal'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveAddress,
                  child: Text('Salveaza'),
                ),
                ElevatedButton(
                  onPressed: _removeAddress,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Sterge'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
