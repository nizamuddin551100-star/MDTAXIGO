import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';

void main() => runApp(MDTaxidoApp());

class MDTaxidoApp extends StatefulWidget {
  @override
  _MDTaxidoAppState createState() => _MDTaxidoAppState();
}

class _MDTaxidoAppState extends State<MDTaxidoApp> {
  // Admin Global Settings
  Color appThemeColor = Colors.yellow;
  double dayRate = 20.0;
  double nightRate = 30.0;
  double baseFare = 40.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: appThemeColor, scaffoldBackgroundColor: Colors.white),
      home: MainSlidingView(),
    );
  }
}

class MainSlidingView extends StatefulWidget {
  @override
  _MainSlidingViewState createState() => _MainSlidingViewState();
}

class _MainSlidingViewState extends State<MainSlidingView> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          MeterPage(),      // Page 1
          EstimatorPage(),  // Page 2
          BookingPage(),    // Page 3
          DriverPage(),     // Page 4
          AdminPage(),      // Page 5
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) => _controller.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.speed), label: "Meter"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Estimate"),
          BottomNavigationBarItem(icon: Icon(Icons.local_taxi), label: "Book"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Driver"),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: "Admin"),
        ],
      ),
    );
  }
}

// --- PAGE 1: LIVE FARE METER ---
class MeterPage extends StatefulWidget {
  @override
  _MeterPageState createState() => _MeterPageState();
}

class _MeterPageState extends State<MeterPage> {
  double fare = 40.0;
  double distance = 0.0;
  double speed = 0.0;
  Duration duration = Duration();
  Timer? timer;
  bool isRunning = false;
  String mode = "Day"; // Day, Night, Auto

  void startTrip() {
    setState(() {
      isRunning = true;
      fare = (mode == "Night") ? 60.0 : 40.0;
      distance = 0.0;
      duration = Duration();
    });
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          duration += Duration(seconds: 1);
          // Logic: Every 100m (simulated here) fare increases
          if (distance > 2.0) {
            fare += (mode == "Night" ? 3.0 : 2.0); // Simple increment logic
          }
        });
      }
    });
  }

  void endTrip() {
    timer?.cancel();
    if (mounted) {
      setState(() => isRunning = false);
    }
    _showReceipt();
  }

  void _showReceipt() {
    String receipt = "MDTAXIDO RECEIPT\nDist: ${distance.toStringAsFixed(2)} km\nFare: ₹${fare.toStringAsFixed(2)}\nDuration: ${duration.inMinutes} mins\nThanks!";
    Share.share(receipt);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 50, bottom: 20),
          color: Colors.black,
          width: double.infinity,
          child: Column(
            children: [
              Text("🛺 MDTAXIDO", style: TextStyle(color: Colors.yellow, fontSize: 24, fontWeight: FontWeight.bold)),
              Text("₹ ${fare.toStringAsFixed(2)}", style: TextStyle(color: Colors.greenAccent, fontSize: 70, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem("KM", distance.toStringAsFixed(2)),
                  _statItem("SPEED", "${speed.toInt()} km/h"),
                  _statItem("TIME", "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}"),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: () => setState(() => mode = "Day"), child: Text("Day (40)")),
            ElevatedButton(onPressed: () => setState(() => mode = "Night"), child: Text("Night (60)")),
          ],
        ),
        Expanded(
          child: FlutterMap(
            options: MapOptions(center: LatLng(12.9716, 77.5946), zoom: 15),
            children: [
              TileLayer(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: ['a', 'b', 'c']),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: isRunning 
            ? ElevatedButton(onPressed: endTrip, child: Text("END TRIP 🔳"), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: Size(double.infinity, 50)))
            : ElevatedButton(onPressed: startTrip, child: Text("START TRIP 🔳"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: Size(double.infinity, 50))),
        )
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(children: [Text(label, style: TextStyle(color: Colors.grey)), Text(value, style: TextStyle(color: Colors.white, fontSize: 18))]);
  }
}

// --- PAGE 5: ADMIN PANEL (PASSWORD PROTECTED) ---
class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool isLocked = true;
  String pass = "";

  @override
  Widget build(BuildContext context) {
    if (isLocked) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 100, color: Colors.grey),
              TextField(
                obscureText: true,
                decoration: InputDecoration(hintText: "Enter Admin Password"),
                onChanged: (val) => pass = val,
              ),
              ElevatedButton(onPressed: () {
                if (pass == "1234") setState(() => isLocked = false);
              }, child: Text("Unlock Dashboard"))
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("MDTAXIDO Dashboard"), backgroundColor: Colors.black),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text("Customise Colors (Choose from 20)", style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            children: List.generate(20, (i) => GestureDetector(
              onTap: () {}, // Logic to change global theme
              child: Container(margin: EdgeInsets.all(5), width: 40, height: 40, color: Colors.primaries[i % Colors.primaries.length]),
            )),
          ),
          Divider(),
          ListTile(title: Text("Edit Base Fare"), trailing: Icon(Icons.edit), subtitle: Text("Current: ₹40")),
          ListTile(title: Text("Edit Greeting"), subtitle: Text("Have a great day ahead!")),
          ElevatedButton(onPressed: () {}, child: Text("FORCE UPDATE ALL USERS")),
        ],
      ),
    );
  }
}

// STUBS FOR REMAINING PAGES (To be expanded)
class EstimatorPage extends StatelessWidget { @override Widget build(BuildContext context) => Center(child: Text("Distance Estimator with Nominatim Search")); }
class BookingPage extends StatelessWidget { @override Widget build(BuildContext context) => Center(child: Text("Booking: Taxi / Auto Rickshaw Selection")); }
class DriverPage extends StatelessWidget { @override Widget build(BuildContext context) => Center(child: Text("Driver Profile & QR Payment Upload")); }
