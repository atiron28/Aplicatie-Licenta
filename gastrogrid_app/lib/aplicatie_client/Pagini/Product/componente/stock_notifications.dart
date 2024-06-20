import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:gastrogrid_app/clase/clasa_produs.dart';
import 'package:gastrogrid_app/providers/provider_notificareStoc.dart';

Future<void> notifyLowStock(BuildContext context, Product product) async {
  try {
    QuerySnapshot supplierSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(product.id)
        .collection('suppliers')
        .get();

    List supplierEmails = supplierSnapshot.docs.map((doc) {
      var supplierData = doc.data() as Map<String, dynamic>;
      return supplierData['email'] ?? '';
    }).toList();

    supplierEmails.removeWhere((email) => email.isEmpty); // Remove empty emails

    if (supplierEmails.isNotEmpty) {
      await Provider.of<NotificationProviderStoc>(context, listen: false).addNotification(
        'Stoc redus pentru ${product.title}',
        product.id,
        supplierEmails.join(', '), // Join all emails
        product.title,
      );
    }
  } catch (e) {
    print('Failed to fetch supplier email: $e');
  }
}

Future<void> notifyOutOfStock(BuildContext context, Product product) async {
  try {
    QuerySnapshot supplierSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(product.id)
        .collection('suppliers')
        .get();

    List supplierEmails = supplierSnapshot.docs.map((doc) {
      var supplierData = doc.data() as Map<String, dynamic>;
      return supplierData['email'] ?? '';
    }).toList();

    supplierEmails.removeWhere((email) => email.isEmpty); // Remove empty emails

    if (supplierEmails.isNotEmpty) {
      await Provider.of<NotificationProviderStoc>(context, listen: false).addNotification(
        'Stoc Epuizat pentru ${product.title}',
        product.id,
        supplierEmails.join(', '), // Join all emails
        product.title,
      );
    }
  } catch (e) {
    print('Failed to fetch supplier email: $e');
  }
}

Future<void> notifyExpired(BuildContext context, Product product) async {
  try {
    QuerySnapshot supplierSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(product.id)
        .collection('suppliers')
        .get();

    List supplierEmails = supplierSnapshot.docs.map((doc) {
      var supplierData = doc.data() as Map<String, dynamic>;
      return supplierData['email'] ?? '';
    }).toList();

    supplierEmails.removeWhere((email) => email.isEmpty); // Remove empty emails

    if (supplierEmails.isNotEmpty) {
      await Provider.of<NotificationProviderStoc>(context, listen: false).addExpiryNotification(
        product.id,
        supplierEmails.join(', '), // Join all emails
        product.title,
      );
    }
  } catch (e) {
    print('Failed to fetch supplier email: $e');
  }
}
