import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:rdl_radiant/src/screens/maps/keys/google_maps_api_key.dart';

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
    // Geolocator.getPositionStream(
    //   locationSettings: const LocationSettings(
    //     accuracy: LocationAccuracy.bestForNavigation,
    //     distanceFilter: 50,
    //     timeLimit: Duration(seconds: 30),
    //   ),
    // ).listen(
    //   (event) {
    //     setState(() {
    //       myLatLng = LatLng(event.latitude, event.longitude);
    //     });

    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       cameraPositionUpdater(LatLng(event.latitude, event.longitude));
    //     });
    //   },
    // );

    // Geolocator.getCurrentPosition().then(
    //   (value) {
    //     getPoliLinePoints(LatLng(value.latitude, value.longitude)).then(
    //       (value) {
    //         generatePolylinesFormsPoints(value);
    //       },
    //     );
    //   },
    // );
  }

  Map<PolylineId, Polyline> polynlies = {};

  Map<String, Marker> markers = {};
  final Completer<GoogleMapController> googleMapController =
      Completer<GoogleMapController>();

  TextEditingController googleMapSearchTextField = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maps"),
        actions: const [
          Text(
            "Lat Lon is not available.\nShowing demo data.",
            style: TextStyle(color: Colors.redAccent),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.lat,
                widget.lng,
              ),
              tilt: 59.440717697143555,
              zoom: 10,
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
              if (myLatLng != null) {
                addMarkers(
                  'My Location',
                  myLatLng!,
                  infoWindow: const InfoWindow(title: "My Location"),
                );
              }
            },
            polylines: Set<Polyline>.of(polynlies.values),
          ),
          SizedBox(
            height: 50,
            child: GooglePlaceAutoCompleteTextField(
              boxDecoration: BoxDecoration(
                color: Colors.blue.shade100,
                border: const Border(
                  bottom: BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
              ),
              containerVerticalPadding: 0,
              inputDecoration: const InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Search places",
                  border: OutlineInputBorder(borderSide: BorderSide.none)),
              textEditingController: googleMapSearchTextField,
              googleAPIKey: googleMapsApiKey,
              debounceTime: 800,
              countries: const ["bd"],
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction prediction) {
                log("placeDetails${prediction.lng}, ${prediction.lat}");
              },
              itemClick: (Prediction prediction) {
                googleMapSearchTextField.text = prediction.description!;
                googleMapSearchTextField.selection = TextSelection.fromPosition(
                    TextPosition(offset: prediction.description!.length));
              },
              // if we want to make custom list item builder
              itemBuilder: (context, index, Prediction prediction) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(
                        width: 7,
                      ),
                      Expanded(
                        child: Text(prediction.description ?? ""),
                      ),
                      Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black),
                          color: Colors.blue.shade100,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                );
              },
              // if you want to add seperator between list items
              seperatedBuilder: const Divider(),
              // want to show close icon
              isCrossBtnShown: true,
              // optional container padding
              containerHorizontalPadding: 2,

              // place type
              placeType: PlaceType.geocode,
            ),
          ),
        ],
      ),
    );
  }

  cameraPositionUpdater(LatLng latlon) async {
    final GoogleMapController controller = await googleMapController.future;
    CameraPosition cameraPosition = CameraPosition(target: latlon, zoom: 10);
    controller.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  addMarkers(String id, LatLng position,
      {InfoWindow infoWindow = InfoWindow.noText}) async {
    markers[id] = Marker(
        markerId: MarkerId(id), position: position, infoWindow: infoWindow);

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
