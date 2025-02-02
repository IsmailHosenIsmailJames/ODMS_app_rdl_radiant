import 'dart:convert';
import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:odms/src/apis/apis.dart';
import 'package:odms/src/screens/customer_location/model/customer_details_model.dart';

import '../../theme/text_scaler_theme.dart';
import '../../widgets/common_widgets_function.dart';
import '../../widgets/loading/loading_popup_widget.dart';
import '../../widgets/loading/loading_text_controller.dart';
import '../home/conveyance/conveyance_page.dart';

class CustomerDetailsPage extends StatefulWidget {
  final String partnerID;
  const CustomerDetailsPage({super.key, required this.partnerID});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  CustomerDetailsModel? customerDetailsModel;
  bool isUnsuccessful = false;

  Future<void> getData() async {
    String partnerID = widget.partnerID;
    http.Response response = await http
        .get(Uri.parse("$base$getCustomerDetailsByPartnerID/$partnerID"));
    if (response.statusCode == 200) {
      Map decodedData = jsonDecode(response.body);
      if (decodedData['success'] == true) {
        customerDetailsModel = CustomerDetailsModel.fromMap(
            Map<String, dynamic>.from(decodedData['result']));
        setState(() {});
        return;
      }
    }
    setState(() {
      isUnsuccessful = true;
    });
  }

  Widget dividerWhite = const Divider(
    color: Colors.white,
    height: 1,
  );
  final LoadingTextController loadingTextController = Get.find();

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScalerValue)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Details'),
        ),
        body: customerDetailsModel == null || isUnsuccessful
            ? Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: Colors.green,
                  size: 40,
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        getRowWidgetForDetailsBox(
                            'Partner ID', customerDetailsModel?.partner),
                        dividerWhite,
                        getRowWidgetForDetailsBox(
                            'Pharmacy Name', customerDetailsModel?.name1),
                        dividerWhite,
                        getRowWidgetForDetailsBox('Customer Name',
                            customerDetailsModel?.contactPerson),
                        dividerWhite,
                        getRowWidgetForDetailsBox(
                          'Customer Mobile',
                          customerDetailsModel?.mobileNo,
                          optionalWidgetsAtLast: SizedBox(
                            height: 23,
                            width: 50,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                FlutterClipboard.copy(
                                  customerDetailsModel?.mobileNo ?? '',
                                ).then((value) {
                                  Fluttertoast.showToast(
                                      msg:
                                          customerDetailsModel?.mobileNo ?? '');
                                });
                              },
                              icon: const Icon(
                                Icons.copy,
                                size: 17,
                              ),
                            ),
                          ),
                        ),
                        dividerWhite,
                        getRowWidgetForDetailsBox(
                            'Street', customerDetailsModel?.street),
                        if ((customerDetailsModel?.street1 ?? '').isNotEmpty)
                          const Divider(
                            color: Colors.white,
                            height: 1,
                          ),
                        if ((customerDetailsModel?.street1 ?? '').isNotEmpty)
                          getRowWidgetForDetailsBox(
                              'Street 1', customerDetailsModel?.street1),
                        if ((customerDetailsModel?.street2 ?? '').isNotEmpty)
                          const Divider(
                            color: Colors.white,
                            height: 1,
                          ),
                        if ((customerDetailsModel?.street2 ?? '').isNotEmpty)
                          getRowWidgetForDetailsBox(
                              'Street 2', customerDetailsModel?.street2),
                        dividerWhite,
                        getRowWidgetForDetailsBox(
                            'District', customerDetailsModel?.district),
                        dividerWhite,
                        getRowWidgetForDetailsBox(
                            'Upazila', customerDetailsModel?.upazilla),
                        dividerWhite,
                        getRowWidgetForDetailsBox(
                            'Trans. P. zone', customerDetailsModel?.transPZone),
                        dividerWhite,
                        getRowWidgetForDetailsBox(
                            'Latitude',
                            (customerDetailsModel?.latitude ?? 'Not Data Found')
                                .toString()),
                        dividerWhite,
                        getRowWidgetForDetailsBox(
                            'Longitude',
                            (customerDetailsModel?.longitude ??
                                    'Not Data Found')
                                .toString()),
                      ],
                    ),
                  ),
                  const Gap(30),
                  Center(
                    child: Text(
                      (customerDetailsModel?.longitude == null ||
                              customerDetailsModel?.latitude == null)
                          ? 'Location data not found.'
                          : 'Already have location data.',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Gap(50),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        loadingTextController.currentState.value = 0;
                        loadingTextController.loadingText.value =
                            'Getting your Location\nPlease wait...';

                        showCustomPopUpLoadingDialog(context,
                            isCupertino: true);

                        Position position = await Geolocator.getCurrentPosition(
                            locationSettings: AndroidSettings(
                          accuracy: LocationAccuracy.best,
                          forceLocationManager: true,
                        ));
                        List<Placemark> placeMarks =
                            await placemarkFromCoordinates(
                          position.latitude,
                          position.longitude,
                        );
                        List<String> placeMarkImportantData =
                            analyzePlaceMark(placeMarks);

                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }

                        if (customerDetailsModel != null) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Are you sure?'),
                              content: getAddressWidget(
                                  placeMarkImportantData,
                                  LatLng(
                                      position.latitude, position.longitude)),
                              actions: [
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade300,
                                      foregroundColor: Colors.blue.shade900,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final box = Hive.box('info');

                                      callSetLocationOfCustomer(
                                          position,
                                          box.get('sap_id').toString(),
                                          customerDetailsModel!);
                                    },
                                    child: const Text('Yes'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.location_on),
                      label: Text(
                        (customerDetailsModel?.longitude == null ||
                                customerDetailsModel?.latitude == null)
                            ? 'Set Location now!'
                            : 'Update Location now!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> callSetLocationOfCustomer(Position position, String sapID,
      CustomerDetailsModel customerDetailsModel) async {
    Navigator.pop(context);
    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Please wait...';

    final box = Hive.box('info');

    showCustomPopUpLoadingDialog(context, isCupertino: true);

    final uri = Uri.parse(base + setCustomerLatLon);
    final response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'work_area_t': box.get('sap_id').toString(),
          'customer_id': widget.partnerID,
          'latitude': position.latitude,
          'longitude': position.longitude,
        }));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      log(decoded.toString());
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful...';
      await Future.delayed(const Duration(milliseconds: 100));
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      log(response.statusCode.toString());
      log(response.body);
      loadingTextController.currentState.value = -1;
      loadingTextController.loadingText.value = 'Something went wrong...';
    }
  }
}
