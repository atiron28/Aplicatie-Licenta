import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GastroGrid/providers/provider_themes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';

class AddressSelector extends StatefulWidget {
  @override
  _AddressSelectorState createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  late GooglePlace googlePlace;
  TextEditingController searchController = TextEditingController();
  TextEditingController manualAddressController = TextEditingController();
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  List<AutocompletePrediction> predictions = [];
  bool loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace('AIzaSyBPKl6hVOD0zauA38oy1RQ3KXW8SM6pwZQ');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialLocation();
    });
  }

  @override
  void dispose() {
    mapController?.dispose();
    searchController.dispose();
    manualAddressController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
  if (mapController != null) {
    mapController!.dispose();
  }
  mapController = controller;
}


  Future<void> _setInitialLocation() async {
    LatLng initialLocation = LatLng(40.7128, -74.0060);
    await Future.delayed(Duration(milliseconds: 300));
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLngZoom(initialLocation, 14.0));
    }
  }

  void _onMapTapped(LatLng position) async {
    setSelectedLocation(position);
    await fetchAddressFromCoordinates(position);
  }

  void setSelectedLocation(LatLng position) {
    setState(() {
      selectedLocation = position;
    });
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(position));
    }
  }

  Future<void> fetchAddressFromCoordinates(LatLng coordinates) async {
    setState(() {
      loading = true;
    });
    try {
      var result = await googlePlace.search.getNearBySearch(
          Location(lat: coordinates.latitude, lng: coordinates.longitude), 500);
      if (result != null && result.results != null && result.results!.isNotEmpty && result.results!.first.formattedAddress != null) {
        var address = result.results!.first.formattedAddress!;
        searchController.text = address;
      }
    } catch (e) {
      debugPrint('Error fetching address: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void autoCompleteSearch(String value) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(Duration(milliseconds: 300), () async {
    if (value.isEmpty) {
      setState(() {
        predictions = [];
      });
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      print('Searching for: $value'); // Debugging line
      var result = await googlePlace.autocomplete.get(value);
      if (result != null && result.predictions != null) {
        setState(() {
          predictions = result.predictions!;
        });
        print("Predictions: ${predictions.length}"); // Debugging line
      } else {
        setState(() {
          predictions = [];
        });
        print("No predictions found"); // Debugging line
      }
    } catch (e) {
      debugPrint('Error fetching predictions: $e');
      setState(() {
        predictions = [];
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  });
}

  void saveAddress(String address) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc();
      await docRef.set({'address': address});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Address saved successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not found")),
      );
    }
    Navigator.pop(context, true);
  }

  @override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  return Scaffold(
    appBar: AppBar(
      title: Text('Alege Adresa'),
      backgroundColor: themeProvider.themeData.colorScheme.background,
      actions: [
        IconButton(
          icon: Icon(Icons.save),
          onPressed: () {
            if (searchController.text.isNotEmpty) {
              saveAddress(searchController.text);
            } else if (manualAddressController.text.isNotEmpty) {
              saveAddress(manualAddressController.text);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please enter an address")),
              );
            }
          },
        )
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Material(
                elevation: 5.0,
                shadowColor: Colors.black54,
                borderRadius: BorderRadius.circular(15.0),
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by street, city, or state',
                    prefixIcon: Icon(Icons.search, color: themeProvider.themeData.colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: themeProvider.themeData.colorScheme.surface,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    suffixIcon: loading 
                        ? Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          )
                        : null,
                  ),
                  onChanged: autoCompleteSearch,
                ),
              ),
              SizedBox(height: 8.0),
              predictions.isNotEmpty
                  ? Container(
                      constraints: BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: themeProvider.themeData.colorScheme.surface,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: predictions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            textColor: themeProvider.themeData.colorScheme.primary,
                            title: Text(predictions[index].description ?? ''),
                            onTap: () async {
                              var placeId = predictions[index].placeId!;
                              var details = await googlePlace.details.get(placeId);
                              if (details != null && details.result != null) {
                                var location = details.result!.geometry!.location!;
                                setSelectedLocation(LatLng(location.lat!, location.lng!));
                                await fetchAddressFromCoordinates(LatLng(location.lat!, location.lng!));
                                setState(() {
                                  searchController.text = predictions[index].description ?? '';
                                  predictions = [];
                                });
                              }
                            },
                          );
                        },
                      ),
                    )
                  : Container(),
              SizedBox(height: 8.0),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(40.7128, -74.0060),
                  zoom: 14.0,
                ),
                markers: {
                  if (selectedLocation != null)
                    Marker(
                      markerId: MarkerId("selectedLocation"),
                      position: selectedLocation!,
                      draggable: true,
                      onDragEnd: (newPosition) async {
                        setSelectedLocation(newPosition);
                        await fetchAddressFromCoordinates(newPosition);
                      },
                    )
                },
                onTap: _onMapTapped,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}