import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyMapView extends StatefulWidget {
  final double lat;
  final double lng;
  const MyMapView({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  State<MyMapView> createState() => _MyMapViewState();
}

class _MyMapViewState extends State<MyMapView> {
  LatLng? myLatLng;
  @override
  void initState() {
    super.initState();
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    ).listen(
      (event) {
        setState(() {
          myLatLng = LatLng(event.latitude, event.longitude);
        });

        print(event.latitude);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cameraPositionUpdater(LatLng(event.latitude, event.longitude));
        });
      },
    );
  }

  Map<String, Marker> markers = {};
  final Completer<GoogleMapController> googleMapController =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maps"),
      ),
      body: myLatLng == null
          ? const Center(
              child: CupertinoActivityIndicator(),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.lat,
                  widget.lng,
                ),
                tilt: 59.440717697143555,
                zoom: 12,
              ),
              markers: markers.values.toSet(),
              onMapCreated: (controller) {
                googleMapController.complete(controller);
                addMarkers(
                  "Dhaka Medical",
                  LatLng(widget.lat, widget.lng),
                  infoWindow:
                      const InfoWindow(title: "Dhaka Medical Hospital, Dhaka"),
                );
                addMarkers(
                  'My Location',
                  myLatLng!,
                  infoWindow: const InfoWindow(title: "My Location"),
                );
              },
            ),
    );
  }

  cameraPositionUpdater(LatLng latlon) async {
    final GoogleMapController controller = await googleMapController.future;
    CameraPosition cameraPosition = CameraPosition(target: latlon, zoom: 13);
    controller.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  addMarkers(String id, LatLng position,
      {InfoWindow infoWindow = InfoWindow.noText}) async {
    markers[id] = Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: infoWindow,
    );

    setState(() {});
  }

  removeMarker(String id) {
    if (markers.containsKey(id)) {
      markers.remove(id);
      setState(() {});
    }
  }
}
