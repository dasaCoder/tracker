import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';


import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: MainActivity(),
  ));
}


class MainActivity extends StatefulWidget {
  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  
  Map<String, double> currentLocation = new Map();
  StreamSubscription<Map<String, double>> locationSubscription;

  final DatabaseReference database = FirebaseDatabase.instance.reference().child("vehicles");

   Location location = new Location();
    String error;

  Completer<GoogleMapController> _controller = Completer();

  LatLng _center = LatLng(45.521563, -12.677433);
  GoogleMapController mapController;
  final Set <Marker> markers = {}; // CLASS MEMBER, MAP OF MARKS

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    mapController = controller;
  }

  final String vehicle_no = 'xxx-4655';

  void initState() {
    super.initState();
    
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;

    initPlatformState();
    
    locationSubscription = location.onLocationChanged().listen((Map<String, double> result) {
      //print("xdsfsfsdfdsfds");
      setState(() {
        database.child(vehicle_no).push().set({
          'lat' : result['latitude'],
          'lng' : result['longitude']
        });

        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(result['latitude'],result['longitude']),
              tilt: 50.0,
              bearing: 45.0,
              zoom: 18.0,
            ),
          ),
        );

        markers.clear();

        markers.add(
            Marker(
              markerId: MarkerId(LatLng(result['latitude'], result['longitude']).toString()),
              position: LatLng(result['latitude'], result['longitude']),
              icon: BitmapDescriptor.fromAsset('assets/icons/car.png') 
            )
          );

        currentLocation = result;
        //print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
        //print(BitmapDescriptor.fromAsset('/assets/icons/car.png').toString());
      });
    });
  }

  sendData() {
    
    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('UOK Tracker'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 20.0,
          ),
          markers: Set<Marker>.of(markers),
        ),
      ),
    );
  }

  void initPlatformState()  async {
    Map<String, double> my_location;

    try{
      my_location = await location.getLocation();
      error = "";
    } on PlatformException catch (e) {
      if(e.code == 'PERMISSION_DENIED')
        error = 'Permission Dinided';
      my_location = null;
    }

    setState(() {
      currentLocation = my_location;
    });

  }
}