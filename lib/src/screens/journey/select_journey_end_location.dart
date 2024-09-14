import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:rdl_radiant/src/screens/maps/keys/google_maps_api_key.dart';

class SelectJourneyEndLocation extends StatefulWidget {
  const SelectJourneyEndLocation({
    super.key,
  });

  @override
  State<SelectJourneyEndLocation> createState() => _MyMapViewState();
}

class _MyMapViewState extends State<SelectJourneyEndLocation> {
  Position? initMyLocation;
  @override
  void initState() {
    super.initState();

    Geolocator.getCurrentPosition().then(
      (value) async {
        setState(() {
          initMyLocation = value;
        });

        await cameraPositionUpdater(LatLng(value.latitude, value.longitude));
      },
    );
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

  FocusNode focusNode = FocusNode();
  String? description;
  LatLng? destination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Start Journey"),
      ),
      body: Stack(
        children: [
          initMyLocation == null
              ? const Center(
                  child: Text("Loading your location..."),
                )
              : GoogleMap(
                  onTap: (argument) {
                    log([argument.latitude, argument.longitude].toString());
                  },
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      initMyLocation!.latitude,
                      initMyLocation!.longitude,
                    ),
                    tilt: 90,
                    zoom: 10,
                  ),
                  markers: markers.values.toSet(),
                  onMapCreated: (controller) {
                    googleMapController.complete(controller);

                    if (initMyLocation != null) {
                      addMarkers(
                        'My Location',
                        LatLng(initMyLocation!.latitude,
                            initMyLocation!.longitude),
                        infoWindow: const InfoWindow(title: "My Location"),
                      );
                    }
                  },
                  polylines: Set<Polyline>.of(polynlies.values),
                ),
          SizedBox(
            height: 50,
            child: GooglePlaceAutoCompleteTextField(
              focusNode: focusNode,
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
                  contentPadding: EdgeInsets.zero,
                  icon: Icon(Icons.search),
                  hintText: "Search places",
                  border: OutlineInputBorder(borderSide: BorderSide.none)),
              textEditingController: googleMapSearchTextField,
              googleAPIKey: googleMapsApiKey,
              countries: const ["bd"],
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction prediction) async {
                focusNode.unfocus();
                if (prediction.lat != null && prediction.lng != null) {
                  log("Getting poliyes");

                  addMarkers(
                    "des",
                    LatLng(double.parse(prediction.lat!),
                        double.parse(prediction.lng!)),
                  );

                  setState(() {
                    description = prediction.description;

                    destination = LatLng(double.parse(prediction.lat!),
                        double.parse(prediction.lng!));
                  });

                  await cameraPositionUpdater(
                    LatLng(double.parse(prediction.lat!),
                        double.parse(prediction.lng!)),
                    zoom: initMyLocation == null
                        ? null
                        : zoomLabelCalculate(
                            LatLng(double.parse(prediction.lat!),
                                double.parse(prediction.lng!)),
                            LatLng(initMyLocation!.latitude,
                                initMyLocation!.longitude),
                          ),
                  );

                  await getPoliLinePoints(
                          LatLng(initMyLocation!.latitude,
                              initMyLocation!.longitude),
                          LatLng(double.parse(prediction.lat!),
                              double.parse(prediction.lng!)))
                      .then(
                    (value) {
                      generatePolylinesFormsPoints(value);
                    },
                  );
                } else {
                  log("Was lat lon null");
                }
              },
              itemClick: (Prediction prediction) async {
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
          if (destination != null)
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.8),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          description ?? "",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 33,
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text("Start"),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "Lat: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(5),
                        Text(destination!.latitude.toString()),
                        const Gap(15),
                        const Text(
                          "Lon: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(5),
                        Text(destination!.longitude.toString()),
                      ],
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Future<void> cameraPositionUpdater(LatLng latlon, {double? zoom}) async {
    final GoogleMapController controller = await googleMapController.future;
    CameraPosition cameraPosition =
        CameraPosition(target: latlon, zoom: zoom ?? 11);
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  double zoomLabelCalculate(LatLng pos1, LatLng pos2) {
    double distance = Geolocator.distanceBetween(
            pos1.latitude, pos1.longitude, pos2.latitude, pos2.longitude) /
        1000;
    log("distance: $distance");

    if (distance > 100) {
      return 11;
    } else if (distance > 50) {
      return 13;
    } else {
      return 15;
    }
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

  Future<List<LatLng>> getPoliLinePoints(LatLng pos1, pos2) async {
    List<LatLng> polyLinePointsList = [];
    PolylinePoints polylinePoints = PolylinePoints();
    try {
      PolylineResult polylineResult =
          await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleMapsApiKey,
        request: PolylineRequest(
          origin: PointLatLng(pos1.latitude, pos1.longitude),
          destination: PointLatLng(pos2.latitude, pos2.longitude),
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
