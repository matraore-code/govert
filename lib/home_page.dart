import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final SupabaseClient supabase = Supabase.instance.client;
  int selectedTariff = 0;
  var totalSum = 0.0;
  bool rideStarted = false;
  List<Position> positions = [];
  List<Map<String, dynamic>> ridesCreated = [];
  StreamSubscription<Position>? positionStream;

  // StreamSubscription<Position>? positionStream;

  void _selectTariff(int tariff) {
    setState(() {
      selectedTariff = tariff;
    });
  }

  void _startRide() async {
    if (selectedTariff != 0) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        // Location services are not enabled, do something here.
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, do something here.
          print('Location services are disabled');

          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied, do something here.
        print('Location services are disabled');

        return;
      }

      Position startPosition = await Geolocator.getCurrentPosition();

      setState(() {
        rideStarted = true;
        positions.clear(); // Clear previous positions
      });

      try {
        var response = await supabase.from('rides').insert({
          'user_id': supabase.auth.currentUser?.id,
          'price': selectedTariff,
          'start_at': DateTime.now().toUtc().toIso8601String(),
          'start_location':
              'POINT(${startPosition.latitude} ${startPosition.longitude})',
        }).select();

        setState(() {
          ridesCreated = response;
          if (positionStream != null && positionStream!.isPaused)
          positionStream?.resume();
        });
      } catch (e) {
        print('Error inserting ride: $e');
      }
    }
  }

  void _endRide() async {
    Position endPosition = await Geolocator.getCurrentPosition();
    // print('RidesCreated: $ridesCreated');
    double distance = 0.0;
    int price = selectedTariff;
    setState(() {
      rideStarted = false;
      selectedTariff = 0;
      positionStream?.pause();
    });
    print('Positions: $positions');
    for (int i = 1; i < positions.length; i++) {
      distance += Geolocator.distanceBetween(
        positions[i - 1].latitude,
        positions[i - 1].longitude,
        positions[i].latitude,
        positions[i].longitude,
      );
    }
    print('Distance: $distance');
    try {
      await supabase.from('rides').update({
        'end_at': DateTime.now().toUtc().toIso8601String(),
        'end_location':
            'POINT(${endPosition.latitude} ${endPosition.longitude})',
        'distance': distance,
        'price': price,
      }).eq('id', ridesCreated[0]['id']);
    } catch (e) {
      print('Error updating ride: $e');
    }
    _fetchDailyIncome();
  }

  void _fetchDailyIncome() async {
    DateTime now = DateTime.now();
    DateTime startOfToday = DateTime(now.year, now.month, now.day);
    try {
      final response = await supabase
          .from('rides')
          .select('price')
          .eq('user_id', supabase.auth.currentUser!.id)
          .gte('end_at', startOfToday.toUtc().toIso8601String());

      double sum = 0;
      for (var ride in response) {
        sum += ride['price'];
      }
      setState(() {
        totalSum = sum;
      });
      print('Response: $response');
    } catch (e) {
      print('Error fetching daily income: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        positions.add(position);

        if (positions.isNotEmpty) {
          for (int i = 1; i < positions.length; i++) {
            
            print(
                'Position $i : ${positions[i].latitude} ${positions[i].longitude}');
          }
          
          //positions.clear();
        }
      });
    });
    _fetchDailyIncome();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
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
        centerTitle: true,
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
                    backgroundColor: selectedTariff == tariff
                        ? Colors.green
                        : Colors.transparent,
                    foregroundColor:
                        selectedTariff == tariff ? Colors.white : Colors.green,
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
