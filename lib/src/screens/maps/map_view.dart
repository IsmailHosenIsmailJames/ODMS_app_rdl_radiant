import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rdl_radiant/src/screens/maps/google_maps_api_key.dart';

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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          cameraPositionUpdater(LatLng(event.latitude, event.longitude));
        });
      },
    );

    Geolocator.getCurrentPosition().then(
      (value) {
        getPoliLinePoints(LatLng(value.latitude, value.longitude)).then(
          (value) {
            generatePolylinesFormsPoints(value);
          },
        );
      },
    );
  }

  Map<PolylineId, Polyline> polynlies = {};

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
              polylines: Set<Polyline>.of(polynlies.values),
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

  Future<List<LatLng>> getPoliLinePoints(LatLng latlan) async {
    List<LatLng> polyLinePointsList = [];
    PolylinePoints polylinePoints = PolylinePoints();
    try {
      PolylineResult polylineResult =
          await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleMapsApiKey,
        request: PolylineRequest(
          origin: PointLatLng(latlan.latitude, latlan.longitude),
          destination: PointLatLng(widget.lat, widget.lng),
          mode: TravelMode.driving,
        ),
      );
      if (polylineResult.points.isNotEmpty) {
        for (int i = 0; i < polylineResult.points.length; i++) {
          polyLinePointsList.add(LatLng(polylineResult.points[i].latitude,
              polylineResult.points[i].longitude));
        }
      } else {
        if (kDebugMode) {
          print(polylineResult.errorMessage);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return polyLinePointsList;
  }

  void generatePolylinesFormsPoints(List<LatLng> points) {
    PolylineId id = const PolylineId("destination");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepOrange,
      points: points,
      width: 7,
    );
    setState(() {
      polynlies[id] = polyline;
    });
  }
}
