import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:rdl_radiant/src/apis/apis.dart';
import 'package:rdl_radiant/src/screens/home/conveyance/controller/conveyance_data_controller.dart';
import 'package:http/http.dart' as http;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conveyance"),
      ),
      body: GetX<ConveyanceDataController>(
        builder: (controller) {
          if (controller.convenceData.isEmpty) {
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
          return ListView.builder(
            itemCount: controller.convenceData.length,
            itemBuilder: (context, index) {
              return Text(controller.convenceData[index].toString());
            },
          );
        },
      ),
    );
  }

  Widget widgetForNewStart() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            loadingTextController.currentState.value = 0;
            loadingTextController.loadingText.value =
                'Getting your Location\nPlease wait...';

            showCoustomPopUpLoadingDialog(context, isCuputino: true);

            Position position = await Geolocator.getCurrentPosition();
            List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude,
              position.longitude,
            );
            String street = '';
            String name = '';
            String administrativeArea = '';
            String subAdministrativeArea = '';
            String locality = '';
            String country = '';
            String subLocality = '';
            for (Placemark placemark in placemarks) {
              street +=
                  '${placemark.street ?? ""}${(placemark.street ?? "").isEmpty ? "" : ", "}';

              name +=
                  '${placemark.name ?? ""}${(placemark.name ?? "").isEmpty ? "" : ", "}';
              if (!administrativeArea
                  .contains(placemark.administrativeArea ?? "")) {
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
              administrativeArea = administrativeArea.substring(
                  0, administrativeArea.length - 2);
            }
            if (subAdministrativeArea.length > 1) {
              subAdministrativeArea = subAdministrativeArea.substring(
                  0, subAdministrativeArea.length - 2);
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

            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Are you sure?"),
                content: Container(
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
                        "Your location is: ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                            position.latitude.toStringAsFixed(4),
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
                            position.longitude.toStringAsFixed(4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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

    showCoustomPopUpLoadingDialog(context, isCuputino: true);

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
          conveyanceDataController.convenceData.value = temList;
        }
      }
      Navigator.pop(context);
    }
  }
}
