// Importă pachetele necesare pentru utilizarea Flutter, Firestore, Firebase Storage și navigare.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'pagina_editare_produs.dart';

// Definirea clasei ProductManagement ca widget stateless.
class ProductManagement extends StatelessWidget {
  const ProductManagement({super.key});

  // Metodă pentru a naviga la pagina de adăugare a unui nou produs.
  void _addProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProductPage(),
      ),
    );
  }

  // Metodă asincronă pentru a șterge un produs din Firestore.
  void _deleteProduct(String id) async {
    await FirebaseFirestore.instance.collection('products').doc(id).delete();
  }

  // Metodă asincronă pentru a încărca o imagine din Firebase Storage.
  Future<void> loadImage(BuildContext context) async {
    try {
      String imageUrl = await firebase_storage.FirebaseStorage.instance
          .ref('product_images/imaginea1.jpeg')
          .getDownloadURL();

      print('Download URL: $imageUrl');
    } catch (e) {
      print('Error occurred while loading the image: $e');
    }
  }

  // Metodă build pentru a construi interfața utilizatorului.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = (constraints.maxWidth ~/ 250).clamp(2, 6); // Calcularea numărului de coloane.
                double fontSize = constraints.maxWidth / 60; // Calcularea dimensiunii fontului.

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: snapshot.data!.docs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: () => _addProduct(context),
                        child: Card(
                          color: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: Center(
                            child: Icon(Icons.add, size: fontSize * 2, color: Colors.white),
                          ),
                        ),
                      );
                    }

                    var product = snapshot.data!.docs[index - 1];
                    Map<String, dynamic> productData = product.data() as Map<String, dynamic>;
                    String imageUrl = productData['imageUrl'];
                    double quantity = productData['quantity'].toDouble();

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Icon(Icons.broken_image, size: fontSize * 2));
                                },
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Text(
                              productData['title'],
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('${productData['price']} lei', style: TextStyle(fontSize: fontSize * 0.8)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Cantitate: ${quantity.toStringAsFixed(3)} kg',
                              style: TextStyle(fontSize: fontSize * 0.8),
                            ),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProductPage(
                                        productId: product.id,
                                        currentTitle: productData['title'],
                                        currentPrice: productData['price'].toString(),
                                        currentDescription: productData['description'],
                                        currentImageUrl: imageUrl,
                                        currentQuantity: quantity.toStringAsFixed(3),
                                        currentUnit: 'kg',
                                        currentExpiryDate: productData['expiryDate'],
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Editeaza', style: TextStyle(fontSize: fontSize * 0.8)),
                              ),
                              TextButton(
                                onPressed: () => _deleteProduct(product.id),
                                child: Text('Sterge', style: TextStyle(fontSize: fontSize * 0.8)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
