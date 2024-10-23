import 'dart:convert';
import 'dart:developer';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:odms/src/apis/apis.dart';
import 'package:odms/src/screens/home/conveyance/controller/conveyance_data_controller.dart';
import 'package:http/http.dart' as http;
import 'package:odms/src/screens/home/conveyance/finish_conveyance/finish_conveyance.dart';
import '../../../theme/text_scaler_theme.dart';
import '../../../widgets/loading/loading_popup_widget.dart';
import '../../../widgets/loading/loading_text_controller.dart';
import 'model/conveyance_data_model.dart';

class ConveyancePage extends StatefulWidget {
  const ConveyancePage({super.key});

  @override
  State<ConveyancePage> createState() => _ConveyancePageState();
}

class _ConveyancePageState extends State<ConveyancePage> {
  final conveyanceDataController = Get.put(ConveyanceDataController());
  final LoadingTextController loadingTextController = Get.find();
  final dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScalerValue)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Conveyance"),
          actions: [
            GetX<ConveyanceDataController>(
              builder: (controller) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isSummary.value
                      ? Colors.blue.shade900
                      : Colors.grey.shade300,
                  foregroundColor: controller.isSummary.value
                      ? Colors.white
                      : Colors.blue.shade900,
                ),
                onPressed: () {
                  controller.isSummary.value = !controller.isSummary.value;
                },
                child: const Text(
                  "Summary",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const Gap(7),
            IconButton(
              onPressed: () async {
                await pickDateTimeAndFilter(context);
              },
              icon: const Icon(
                Icons.filter_alt_sharp,
              ),
            ),
            const Gap(10),
          ],
        ),
        body: GetX<ConveyanceDataController>(
          builder: (controller) {
            var convinceData = controller.convinceData;
            bool isAnyLive = false;

            for (var e in convinceData) {
              if (isAnyLive == false) isAnyLive = (e.journeyStatus == 'live');
            }

            log(isAnyLive.toString());

            if (convinceData.isEmpty) {
              return Column(
                children: [
                  const Spacer(),
                  const Center(
                    child: Text("Conveyance list is empty"),
                  ),
                  const Spacer(),
                  widgetForNewStart(),
                ],
              );
            }
            TextStyle textStyleForHeader = TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            );
            TextStyle textStyleForContent = const TextStyle(fontSize: 13);
            double deviceWidth = MediaQuery.of(context).size.width;
            return controller.isSummary.value
                ? Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade400,
                              blurRadius: 15,
                            ),
                          ],
                          color: Colors.blue.shade100,
                        ),
                        height: 30,
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: deviceWidth * (1 / 9),
                              child: Text(
                                "SL. No.",
                                style: textStyleForHeader,
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: deviceWidth * (1 / 4),
                              child: Text(
                                "From",
                                style: textStyleForHeader,
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: deviceWidth * (1 / 4),
                              child: Text(
                                "To",
                                style: textStyleForHeader,
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: deviceWidth * (1 / 4.5),
                              child: Text(
                                "Transport Mode",
                                style: textStyleForHeader,
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: deviceWidth * (1 / 7),
                              child: Text(
                                "Cost",
                                style: textStyleForHeader,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: ListView.builder(
                        itemCount: controller.convinceData.length,
                        itemBuilder: (context, index) {
                          var current = controller.convinceData[index];
                          return Container(
                            color: index % 2 == 0
                                ? Colors.white
                                : Colors.grey.shade200,
                            child: Row(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: deviceWidth * (1 / 9),
                                  child: Text(
                                    "${index + 1}",
                                    style: textStyleForHeader,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 1, right: 1, top: 2, bottom: 2),
                                  alignment: Alignment.center,
                                  width: deviceWidth * (1 / 4),
                                  child: FutureBuilder(
                                    future: placemarkFromCoordinates(
                                      double.parse(
                                          current.startJourneyLatitude!),
                                      double.parse(
                                          current.startJourneyLongitude!),
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        log(snapshot.data![0].toString());
                                        String street = "";
                                        for (var x in snapshot.data!) {
                                          if (!(street
                                                  .contains(x.street ?? "")) &&
                                              'Unnamed Road' != x.street) {
                                            street += x.street ?? "";
                                            street += ", ";
                                          }
                                        }
                                        return Text(
                                          street,
                                          style: textStyleForContent,
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  alignment: Alignment.center,
                                  width: deviceWidth * (1 / 4),
                                  child: (current.endJourneyLatitude != null &&
                                          current.startJourneyLongitude != null)
                                      ? FutureBuilder(
                                          future: placemarkFromCoordinates(
                                            double.parse(
                                                current.startJourneyLatitude!),
                                            double.parse(
                                                current.startJourneyLongitude!),
                                          ),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              log(snapshot.data![0].toString());
                                              String street = "";
                                              for (var x in snapshot.data!) {
                                                if (!(street.contains(
                                                        x.street ?? "")) &&
                                                    'Unnamed Road' !=
                                                        x.street) {
                                                  street += x.street ?? "";
                                                  street += ", ";
                                                }
                                              }
                                              return Text(
                                                street,
                                                style: textStyleForContent,
                                              );
                                            } else {
                                              return const SizedBox();
                                            }
                                          },
                                        )
                                      : const Text(
                                          "Live",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width: deviceWidth * (1 / 4.5),
                                  padding: const EdgeInsets.all(2),
                                  child: current.transportMode != null
                                      ? Text(
                                          current.transportMode
                                              .toString()
                                              .replaceAll('[', '')
                                              .replaceAll(']', '')
                                              .replaceAll('"', '')
                                              .replaceAll(',', ', '),
                                          style: textStyleForContent,
                                        )
                                      : const Text(
                                          "Live",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                ),
                                current.transportCost != null
                                    ? Container(
                                        alignment: Alignment.center,
                                        width: deviceWidth * (1 / 7),
                                        child: Text(
                                          current.transportCost
                                              .toString()
                                              .split('.')[0],
                                          style: textStyleForHeader,
                                        ),
                                      )
                                    : const Text(
                                        "Live",
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                              ],
                            ),
                          );
                        },
                      ))
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: convinceData.length,
                          itemBuilder: (context, index) {
                            final current = convinceData[index];
                            String transportMode = current.transportMode
                                .toString()
                                .replaceAll('[', '')
                                .replaceAll(']', '')
                                .replaceAll('"', '')
                                .replaceAll(',', ', ');
                            DateTime? staringDate = DateTime.tryParse(controller
                                .convinceData[index].startJourneyDateTime
                                .toString());
                            // DateTime? endDate = DateTime.tryParse(controller
                            //     .convinceData[index].endJourneyDateTime
                            //     .toString());

                            bool isLive = current.journeyStatus != 'end';
                            return Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade500,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  if (staringDate != null)
                                    Row(
                                      children: [
                                        Text(
                                          '${staringDate.day}/${staringDate.month}/${staringDate.year}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),

                                  FutureBuilder(
                                    future: placemarkFromCoordinates(
                                      double.parse(controller
                                          .convinceData[index]
                                          .startJourneyLatitude!),
                                      double.parse(controller
                                          .convinceData[index]
                                          .startJourneyLongitude!),
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData == false) {
                                        return const SizedBox();
                                      }
                                      List<String> placeMarkImportantData =
                                          analyzePlaceMark(snapshot.data!);

                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Your starting location was: ",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (isLive)
                                                const Text(
                                                  "Live",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              if (!isLive)
                                                const Text(
                                                  "End",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          getAddressWidget(
                                            placeMarkImportantData,
                                            LatLng(
                                              double.parse(controller
                                                  .convinceData[index]
                                                  .startJourneyLatitude!),
                                              double.parse(controller
                                                  .convinceData[index]
                                                  .startJourneyLongitude!),
                                            ),
                                            showTitle: false,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  if (!isLive)
                                    FutureBuilder(
                                      future: placemarkFromCoordinates(
                                        double.parse(
                                            current.endJourneyLatitude ?? '0'),
                                        double.parse(
                                            current.endJourneyLongitude ?? '0'),
                                      ),
                                      builder: (context, snapshot) {
                                        List<String>? placeMarkImportantData =
                                            snapshot.hasData
                                                ? analyzePlaceMark(
                                                    snapshot.data!)
                                                : null;

                                        return Column(
                                          children: [
                                            if (!isLive) const Gap(10),
                                            if (!isLive)
                                              const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Your end location was: ",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            placeMarkImportantData == null
                                                ? const Row(
                                                    children: [
                                                      Text(
                                                        "Data is not valid",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : getAddressWidget(
                                                    placeMarkImportantData,
                                                    LatLng(
                                                      double.parse(controller
                                                              .convinceData[
                                                                  index]
                                                              .endJourneyLatitude ??
                                                          '0'),
                                                      double.parse(controller
                                                              .convinceData[
                                                                  index]
                                                              .endJourneyLongitude ??
                                                          '0'),
                                                    ),
                                                    showTitle: false,
                                                  ),
                                          ],
                                        );
                                      },
                                    ),

                                  // if (endDate != null)
                                  //   Row(
                                  //     children: [
                                  //       Text(
                                  //           "Starting Date: ${endDate.day}/${endDate.month}/${endDate.year}"),
                                  //     ],
                                  //   ),
                                  if (isLive)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.to(
                                            () => FinishConveyance(
                                              conveyanceData:
                                                  convinceData.value[index],
                                            ),
                                          );
                                        },
                                        child: const Text("Next"),
                                      ),
                                    ),
                                  if (!isLive)
                                    if (current.endJourneyLatitude != null &&
                                        current.endJourneyLongitude != null)
                                      Row(
                                        children: [
                                          const Text(
                                            "Distance: ",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Gap(5),
                                          Text(
                                            '${(Geolocator.distanceBetween(
                                                  double.parse(current
                                                          .startJourneyLatitude ??
                                                      '0'),
                                                  double.parse(current
                                                          .startJourneyLongitude ??
                                                      '0'),
                                                  double.parse(current
                                                          .endJourneyLatitude ??
                                                      '0'),
                                                  double.parse(current
                                                          .endJourneyLongitude ??
                                                      '0'),
                                                ) / 1000).toStringAsFixed(2)} km',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                  if (current.transportMode != null)
                                    Row(
                                      children: [
                                        const Text(
                                          "Transport Mode:",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Gap(7),
                                        Text(
                                          transportMode,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      if (!isAnyLive) widgetForNewStart(),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget widgetForNewStart() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        color: Colors.white,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            loadingTextController.currentState.value = 0;
            loadingTextController.loadingText.value =
                'Getting your Location\nPlease wait...';

            showCustomPopUpLoadingDialog(context, isCupertino: true);

            Position position = await Geolocator.getCurrentPosition(
                locationSettings: AndroidSettings(
              accuracy: LocationAccuracy.best,
              forceLocationManager: true,
              distanceFilter: 10,
            ));
            List<Placemark> placeMarks = await placemarkFromCoordinates(
              position.latitude,
              position.longitude,
            );
            List<String> placeMarkImportantData = analyzePlaceMark(placeMarks);

            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Are you sure?"),
                content: getAddressWidget(placeMarkImportantData,
                    LatLng(position.latitude, position.longitude)),
                actions: [
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.blue.shade900,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        final box = Hive.box('info');

                        callStartConveyance(
                            position, box.get('sap_id').toString());
                      },
                      child: const Text("Yes"),
                    ),
                  ),
                ],
              ),
            );
          },
          child: const Text("Start New Conveyance"),
        ),
      ),
    );
  }

  void callStartConveyance(Position position, String sapID) async {
    Navigator.pop(context);
    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Please wait...';

    showCustomPopUpLoadingDialog(context, isCupertino: true);

    final uri = Uri.parse(base + conveyanceStart);
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "da_code": sapID,
        "start_journey_latitude": position.latitude.toStringAsFixed(9),
        "start_journey_longitude": position.longitude.toStringAsFixed(9),
      }),
    );
    if (response.statusCode == 200) {
      final decode = jsonDecode(response.body);
      if (decode['success'] == true) {
        final url = Uri.parse(
          "$base$conveyanceList?da_code=$sapID&date=${DateFormat('yyyy-MM-dd').format(dateTime)}",
        );

        final response = await http.get(url);

        if (response.statusCode == 200) {
          loadingTextController.currentState.value = 1;
          loadingTextController.loadingText.value = 'Successful';

          log("Message with success: ${response.body}");

          Map decoded = jsonDecode(response.body);

          final conveyanceDataController = Get.put(ConveyanceDataController());

          var temList = <SavePharmaceuticalsLocationData>[];
          List<Map> tem = List<Map>.from(decoded['result']);
          for (int i = 0; i < tem.length; i++) {
            temList.add(SavePharmaceuticalsLocationData.fromMap(
                Map<String, dynamic>.from(tem[i])));
          }
          conveyanceDataController.convinceData.value =
              temList.reversed.toList();
        }
      }
      Navigator.pop(context);
    }
  }

  Future<void> pickDateTimeAndFilter(
    BuildContext context,
  ) async {
    DateTime? pickedDateTime;
    await showModalBottomSheet(
      context: context,
      builder: (context) => BottomPicker.date(
        height: 500,
        pickerTitle: const Text(
          "Pick a Date",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onSubmit: (p0) {
          pickedDateTime = p0 as DateTime;
        },
      ),
    );

    if (pickedDateTime != null) {
      loadingTextController.currentState.value = 0;
      loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
      showCustomPopUpLoadingDialog(context, isCupertino: true);

      final box = Hive.box('info');
      final url = Uri.parse(
        "$base$conveyanceList?da_code=${box.get('sap_id')}&date=${DateFormat('yyyy-MM-dd').format(pickedDateTime!)}",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        loadingTextController.currentState.value = 1;
        loadingTextController.loadingText.value = 'Successful';

        Map decoded = jsonDecode(response.body);

        final conveyanceDataController = Get.put(ConveyanceDataController());
        var temList = <SavePharmaceuticalsLocationData>[];
        List<Map> tem = List<Map>.from(decoded['result']);
        for (int i = 0; i < tem.length; i++) {
          temList.add(SavePharmaceuticalsLocationData.fromMap(
              Map<String, dynamic>.from(tem[i])));
        }
        conveyanceDataController.convinceData.value = temList.reversed.toList();

        await Future.delayed(const Duration(milliseconds: 100));
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else {
        loadingTextController.currentState.value = -1;
        loadingTextController.loadingText.value = 'Something went wrong';

        Fluttertoast.showToast(msg: "Something went wrong");
      }
    }
  }
}

List<String> analyzePlaceMark(List<Placemark> placeMarks) {
  String street = '';
  String name = '';
  String administrativeArea = '';
  String subAdministrativeArea = '';
  String locality = '';
  String country = '';
  String subLocality = '';
  for (Placemark placemark in placeMarks) {
    street +=
        '${placemark.street ?? ""}${(placemark.street ?? "").isEmpty ? "" : ", "}';

    name +=
        '${placemark.name ?? ""}${(placemark.name ?? "").isEmpty ? "" : ", "}';
    if (!administrativeArea.contains(placemark.administrativeArea ?? "")) {
      administrativeArea +=
          '${placemark.administrativeArea ?? ""}${(placemark.administrativeArea ?? "").isEmpty ? "" : ", "}';
    }
    if (!subAdministrativeArea
        .contains(placemark.subAdministrativeArea ?? "")) {
      subAdministrativeArea +=
          '${placemark.subAdministrativeArea ?? ""}${(placemark.subAdministrativeArea ?? "").isEmpty ? "" : ", "}';
    }
    if (!locality.contains(placemark.locality ?? "")) {
      locality +=
          '${placemark.locality ?? ""}${(placemark.locality ?? "").isEmpty ? "" : ", "}';
    }
    if (!country.contains(placemark.country ?? "")) {
      country +=
          '${placemark.country ?? ""}${(placemark.country ?? "").isEmpty ? "" : ", "}';
    }
    if (!subLocality.contains(placemark.subLocality ?? "")) {
      subLocality +=
          '${placemark.subLocality ?? ""}${(placemark.subLocality ?? "").isEmpty ? "" : ", "}';
    }
  }

  if (street.length > 1) {
    street = street.substring(0, street.length - 2);
  }
  if (name.length > 1) name = name.substring(0, name.length - 2);
  if (administrativeArea.length > 1) {
    administrativeArea =
        administrativeArea.substring(0, administrativeArea.length - 2);
  }
  if (subAdministrativeArea.length > 1) {
    subAdministrativeArea =
        subAdministrativeArea.substring(0, subAdministrativeArea.length - 2);
  }
  if (locality.length > 1) {
    locality = locality.substring(0, locality.length - 2);
  }
  if (country.length > 1) {
    country = country.substring(0, country.length - 2);
  }
  if (subLocality.length > 1) {
    subLocality = subLocality.substring(0, subLocality.length - 2);
  }
  return [
    street,
    name,
    administrativeArea,
    subAdministrativeArea,
    locality,
    country,
    subLocality,
  ];
}

Widget getAddressWidget(
  List<String> placeMarkImportantData,
  LatLng latLng, {
  bool showTitle = true,
}) {
  String street = placeMarkImportantData[0];
  String administrativeArea = placeMarkImportantData[2];
  String subAdministrativeArea = placeMarkImportantData[3];
  String locality = placeMarkImportantData[4];
  String country = placeMarkImportantData[5];
  String subLocality = placeMarkImportantData[6];
  return Container(
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
        if (showTitle)
          const Text(
            "Your location is: ",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        Text(
          street,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
              latLng.latitude.toStringAsFixed(4),
            ),
            const Gap(15),
            const Text(
              "Lon: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(2),
            Text(
              latLng.longitude.toStringAsFixed(4),
            ),
          ],
        ),
      ],
    ),
  );
}
