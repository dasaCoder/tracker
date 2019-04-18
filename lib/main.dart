import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

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

  final String vehicle_no = 'xxx-4655';

  void initState() {
    super.initState();
    
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;

    initPlatformState();
    
    locationSubscription = location.onLocationChanged().listen((Map<String, double> result) {
      setState(() {
        database.child(vehicle_no).push().set({
          'lat' : result['latitude'],
          'lng' : result['longitude']
        });


        print("location");

        // update firebase

        currentLocation = result;
        print(result);
      });
    });
  }

  sendData() {
    
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase"),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: FlatButton(
            onPressed: () => sendData(),
            child: Text("Send"),
        color: Colors.amber),
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