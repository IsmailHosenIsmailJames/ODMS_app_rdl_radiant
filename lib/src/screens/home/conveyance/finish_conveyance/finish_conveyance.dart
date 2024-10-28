import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:odms/src/apis/apis.dart';
import 'package:odms/src/screens/home/conveyance/controller/conveyance_data_controller.dart';
import 'package:odms/src/screens/home/conveyance/conveyance_page.dart';
import 'package:odms/src/screens/maps/keys/google_maps_api_key.dart';

import '../../../../theme/text_scaler_theme.dart';
import '../../../../widgets/loading/loading_popup_widget.dart';
import '../../../../widgets/loading/loading_text_controller.dart';
import '../model/conveyance_data_model.dart';

class FinishConveyance extends StatefulWidget {
  final SavePharmaceuticalsLocationData conveyanceData;
  const FinishConveyance({
    super.key,
    required this.conveyanceData,
  });

  @override
  State<FinishConveyance> createState() => _MyMapViewState();
}

class _MyMapViewState extends State<FinishConveyance> {
  final ConveyanceDataController conveyanceDataController = Get.find();
  final LoadingTextController loadingTextController = Get.find();

  LatLng? initMyLocation;
  LatLng? destination;

  @override
  void initState() {
    super.initState();

    setState(() {
      initMyLocation = LatLng(
          double.parse(widget.conveyanceData.startJourneyLatitude!),
          double.parse(widget.conveyanceData.startJourneyLongitude!));
    });

    Geolocator.getCurrentPosition().then(
      (value) async {
        setState(() {
          destination = LatLng(value.latitude, value.longitude);
        });

        getLocationDetailsFormLatLon(destination!);

        await cameraPositionUpdater(
          LatLng(value.latitude, value.longitude),
          zoom: 12,
        );
      },
    );
  }

  double zoomLabel = 13;

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

  String street = '';
  String name = '';
  String administrativeArea = '';
  String subAdministrativeArea = '';
  String locality = '';
  String country = '';
  String subLocality = '';

  double distance = 0;

  Future<void> getLocationDetailsFormLatLon(LatLng latlng) async {
    destination = latlng;
    markers['destination'] = Marker(
        markerId: const MarkerId("destination"),
        position: latlng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: "Destination"));

    setState(() {
      destination = LatLng(latlng.latitude, latlng.longitude);
    });

    cameraPositionUpdater(
        destination = LatLng(latlng.latitude, latlng.longitude),
        zoom: zoomLabel);

    getPoliLinePoints(
            LatLng(initMyLocation!.latitude, initMyLocation!.longitude),
            destination = LatLng(latlng.latitude, latlng.longitude))
        .then(
      (value) {
        for (int i = 1; i < value.length; i++) {
          distance += Geolocator.distanceBetween(value[i - 1].latitude,
              value[i - 1].longitude, value[i].latitude, value[i].longitude);
        }

        generatePolylinesFormsPoints(value);
      },
    );
    List<Placemark> placeMarks = await placemarkFromCoordinates(
      latlng.latitude,
      latlng.longitude,
    );
    final listOfAddress = analyzePlaceMark(placeMarks);
    street = listOfAddress[0];
    name = listOfAddress[1];
    administrativeArea = listOfAddress[2];
    subAdministrativeArea = listOfAddress[3];
    locality = listOfAddress[4];
    country = listOfAddress[5];
    subLocality = listOfAddress[6];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScalerValue)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Map of Journey"),
        ),
        body: Stack(
          children: [
            initMyLocation == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        LoadingAnimationWidget.threeRotatingDots(
                            color: Colors.blue.shade900, size: 30),
                        const Text("Loading your location..."),
                      ],
                    ),
                  )
                : GoogleMap(
                    onCameraMove: (position) {
                      zoomLabel = position.zoom;
                    },
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        initMyLocation!.latitude,
                        initMyLocation!.longitude,
                      ),
                      tilt: 90,
                      zoom: zoomLabel,
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
                    const Text(
                      "Your Current Location Details: ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(
                      height: 3,
                    ),
                    destination == null
                        ? Container(
                            width: double.infinity,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text("Loading your location..."),
                            ),
                          )
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .shimmer(
                              duration: 1200.ms,
                              color: const Color(0xFF80DDFF),
                            )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                street,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "$subLocality, $locality, $subAdministrativeArea, $administrativeArea, $country",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700),
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "Lat: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Gap(2),
                                  Text(
                                      destination!.latitude.toStringAsFixed(4)),
                                  const Gap(15),
                                  const Text(
                                    "Lon: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Gap(2),
                                  Text(destination!.longitude
                                      .toStringAsFixed(4)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "Distance: ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Gap(2),
                                  Text(
                                    "${(distance / 1000).toStringAsFixed(2)} km",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    finishTheJourney(context, distance);
                                  },
                                  icon: const Icon(Icons.done),
                                  label: const Text("Finish the journey"),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void finishTheJourney(BuildContext context, double distance) async {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          insetPadding: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Fill the information",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(10),
                Container(
                  padding: const EdgeInsets.all(5),
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Cost of the journey is required";
                      } else {
                        if (double.tryParse(value) != null) {
                          return null;
                        } else {
                          return "Cost amount must always be a number";
                        }
                      }
                    },
                    controller: controller,
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Cost of the journey",
                    ),
                  ),
                ),
                const Gap(10),
                const Text(
                  "Select Transport Modes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(5),
                FutureBuilder(
                  future: get(Uri.parse(base + conveyanceTransportMode)),
                  builder: (context, snapshot) {
                    // {
                    //   "id": 1,
                    //   "transport_name": "Rickshaw",
                    //   "status": 1,
                    //   "created_at": "2024-09-16T16:24:35+06:00",
                    //   "updated_at": "2024-09-16T16:24:48+06:00"
                    // },
                    // {
                    //   "id": 2,
                    //   "transport_name": "Car",
                    //   "status": 1,
                    //   "created_at": "2024-09-16T16:26:34+06:00",
                    //   "updated_at": null
                    // }
                    if (snapshot.hasData) {
                      final decode = jsonDecode(snapshot.data!.body);
                      List<Map<String, dynamic>> data =
                          List<Map<String, dynamic>>.from(
                        decode['result'],
                      );
                      List<String> transportModes = data
                          .map(
                            (e) => e['transport_name'].toString(),
                          )
                          .toList();

                      return GetX<ConveyanceDataController>(
                        builder: (controller) {
                          return Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: List.generate(
                              transportModes.length,
                              (index) {
                                bool isAlreadySelected = controller
                                    .transportModes
                                    .contains(transportModes[index]);
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: isAlreadySelected
                                          ? Colors.blue.shade900
                                          : Colors.grey.shade300,
                                      foregroundColor: isAlreadySelected
                                          ? Colors.grey.shade200
                                          : Colors.blue.shade900),
                                  onPressed: () {
                                    isAlreadySelected
                                        ? controller.transportModes
                                            .remove(transportModes[index])
                                        : controller.transportModes
                                            .add(transportModes[index]);
                                  },
                                  child: Text(
                                    transportModes[index],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text("Loading transport modes..."),
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: 1200.ms,
                            color: const Color.fromARGB(255, 159, 202, 218),
                          )
                          .animate();
                    }
                  },
                ),
                const Gap(5),
                Text(
                  "Distance : ${(distance / 1000).toStringAsFixed(2)} km",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Gap(10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (double.tryParse(controller.text) != null &&
                          conveyanceDataController.transportModes.isNotEmpty) {
                        loadingTextController.currentState.value = 0;
                        loadingTextController.loadingText.value =
                            'Loading Data\nPlease wait...';
                        showCustomPopUpLoadingDialog(context,
                            isCupertino: true);

                        String toSendData = jsonEncode({
                          "end_journey_latitude":
                              destination!.latitude.toStringAsFixed(9),
                          "end_journey_longitude":
                              destination!.longitude.toStringAsFixed(9),
                          "transport_mode": jsonEncode(
                              conveyanceDataController.transportModes.value),
                          "transport_cost": controller.text,
                        });
                        final response = await put(
                          Uri.parse(
                              '$base$conveyanceEnd/${widget.conveyanceData.id}'),
                          headers: {"Content-Type": "application/json"},
                          body: toSendData,
                        );

                        if (response.statusCode == 200) {
                          final decoded = jsonDecode(response.body);
                          log("Message with success: ${response.body}");
                          if (decoded['success'] == true) {
                            conveyanceDataController.transportModes.value = [];
                            try {
                              final box = Hive.box('info');
                              final url = Uri.parse(
                                "$base$conveyanceList?da_code=${box.get('sap_id')}&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
                              );

                              final response = await get(url);
                              log(response.body);

                              if (response.statusCode == 200) {
                                log("Message with success 2: ${response.body}");

                                Map decoded = jsonDecode(response.body);

                                final conveyanceDataController =
                                    Get.put(ConveyanceDataController());
                                var temList =
                                    <SavePharmaceuticalsLocationData>[];
                                List<Map> tem =
                                    List<Map>.from(decoded['result']);
                                for (int i = 0; i < tem.length; i++) {
                                  temList.add(
                                      SavePharmaceuticalsLocationData.fromMap(
                                          Map<String, dynamic>.from(tem[i])));
                                }
                                conveyanceDataController.convinceData.value =
                                    temList.reversed.toList();
                              }
                            } catch (e) {
                              log(e.toString());
                            }
                            loadingTextController.currentState.value = 1;
                            loadingTextController.loadingText.value =
                                'Successful';

                            await Future.delayed(
                                const Duration(milliseconds: 100));
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Fill the information correctly");
                        }
                      }
                    },
                    child: const Text("Submit"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> cameraPositionUpdater(LatLng latlon, {double? zoom}) async {
    final GoogleMapController controller = await googleMapController.future;
    CameraPosition cameraPosition =
        CameraPosition(target: latlon, zoom: zoomLabel);
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
      return 12;
    } else {
      return 13;
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
