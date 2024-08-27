import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyMapView extends StatefulWidget {
  final double lat;
  final double lng;
  const MyMapView({super.key, required this.lat, required this.lng});

  @override
  State<MyMapView> createState() => _MyMapViewState();
}

class _MyMapViewState extends State<MyMapView> {
  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          bearing: 192.8334901395799,
          target: LatLng(widget.lat, widget.lng),
          tilt: 59.440717697143555,
          zoom: 19.151926040649414,
        ),
      ),
    );
  }
}
