// ignore_for_file: prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Home/componente/butoane_livrare.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Product/pagina_produs.dart';
import 'package:gastrogrid_app/aplicatie_client/Pagini/Address/pagina_selectare_adresa.dart';
import 'package:gastrogrid_app/aplicatie_client/clase/produs.dart';
import 'package:gastrogrid_app/providers/provider_themes.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _selectAddress(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressSelector(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.themeData.colorScheme.background,
      body: CustomScrollView(
        slivers: <Widget>[
          
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.only(top: 50,bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _selectAddress(context),
                    child: Center(
                         
                        child:Icon(Icons.pin_drop_outlined, color: Colors.white,size: 40,)
                      
                    ),
                  ),
                  SizedBox(height: 20),
                  DeliveryToggleButtons(),
                  
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              minHeight: 80.0,
              maxHeight: 80.0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.center,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(30.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                      hintText: 'Caută produse',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      filled: true,
                      fillColor: themeProvider.themeData.colorScheme.surface,
                    ),
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ),
                ),
              ),
            ),
            pinned: false,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              var docs = snapshot.data!.docs;
              var filteredDocs = docs.where((doc) {
                var product = Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                return product.title.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

              return SliverPadding(
                padding: EdgeInsets.all(10),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.5 / 1.2, 
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if (index < filteredDocs.length) {
                        var product = Product.fromMap(filteredDocs[index].data() as Map<String, dynamic>, filteredDocs[index].id);
                        return Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15.0),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(product: product),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                                      image: DecorationImage(
                                        image: NetworkImage(product.imageUrl), 
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 30.0,left: 20, top: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Row(
                                          children: [
                                            Text(
                                              product.title, 
                                              style: TextStyle(
                                                fontSize: 16, 
                                                fontWeight: FontWeight.bold
                                                     ),
                                            ),
                                            SizedBox(width: 180),
                                            Text(
                                              '${product.price} lei', 
                                              style: TextStyle(
                                                fontSize: 14, 
                                                color: Colors.grey[600]
                                                      )
                                            )
                                          ]
                                        )
                                      ),
                                      
                                     
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                    childCount: filteredDocs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight > minHeight ? maxHeight : minHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
