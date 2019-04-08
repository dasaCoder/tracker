import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyAppState();
  }

}

class MyAppState extends State<MyApp> {

  Map<String, double> currentLocation = new Map();
  StreamSubscription<Map<String, double>> locationSubscription;

  Location location = new Location();
  String error;

  void initState() {
    super.initState();
    
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;

    initPlatformState();
    locationSubscription = location.onLocationChanged().listen((Map<String, double> result) {
      setState(() {

        final vehicleReference = FirebaseDatabase.instance.reference().child('uok-trp');

        vehicleReference.push().set({
          'lat':result['latitude'],
          'lng' : result['longitude']
        })
        .then((_){

        });

        print("location");

        // update firebase

        currentLocation = result;
        print(result);
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: AppBar( title: Text('KLN Tracker'),),
        body: Center(
          child:
          Column(mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Lat/Lng: ${currentLocation['latitude']}/ ${currentLocation['longitude']}',
              style: TextStyle(fontSize: 20.0, color: Colors.blueAccent),
            )
          ],
          ),
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