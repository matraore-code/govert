import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTariff = 0;
  int totalSum = 0;
  bool rideStarted = false;
  List<Position> positions = [];
  StreamSubscription<Position>? positionStream;

  void _selectTariff(int tariff) {
    setState(() {
      selectedTariff = tariff;
    });
  }

  void _startRide() async {
    if (selectedTariff != 0) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, do something here.
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, do something here.
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied, do something here.
        return;
      }

      setState(() {
        totalSum += selectedTariff;
        rideStarted = true;
        positions.clear(); // Clear previous positions
      });

      positionStream = Geolocator.getPositionStream().listen((Position position) {
        setState(() {
          positions.add(position);
        });
      });
    }
  }

  void _endRide() {
    positionStream?.cancel();

    double distance = 0.0;
    for (int i = 1; i < positions.length; i++) {
      distance += Geolocator.distanceBetween(
        positions[i - 1].latitude,
        positions[i - 1].longitude,
        positions[i].latitude,
        positions[i].longitude,
      );
    }

    setState(() {
      rideStarted = false;
      selectedTariff = 0; // Reset the selected tariff after ending the ride
    });

    // Show the total distance
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Course terminée'),
          content: Text('Distance parcourue: ${distance.toStringAsFixed(2)} mètres'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Govert',
            style: TextStyle(
                color: Colors.green,
                fontSize: 40,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: rideStarted ? _buildRideInProgress() : _buildTariffSelection(),
      ),
    );
  }

  Widget _buildTariffSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Votre recette du jour: $totalSum XOF',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        SizedBox(height: 40),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choisir un tarif',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [200, 300, 400, 500, 600, 700].map((tariff) {
                return ElevatedButton(
                  onPressed: () => _selectTariff(tariff),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedTariff == tariff ? Colors.green : Colors.transparent,
                    foregroundColor: selectedTariff == tariff ? Colors.white : Colors.green,
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    tariff.toString(),
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 50),
            Text(
              'Tarif de la course en cours : $selectedTariff',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _startRide,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                'Démarrer la course',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRideInProgress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/lottie/animation.json',
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 40),
        Text(
          'Course en Cours',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
          ),
        ),
        SizedBox(height: 50),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _endRide,
          child: Text(
            'Terminer la course',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
      ],
    );
  }
}
