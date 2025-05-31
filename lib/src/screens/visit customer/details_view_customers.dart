import 'dart:convert';
import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
// import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:delivery/src/apis/apis.dart';
import 'package:delivery/src/screens/customer_location/model/customer_details_model.dart';
import 'package:delivery/src/screens/visit%20customer/model/visits_data_to_api.dart';

import '../../theme/text_scaler_theme.dart';
import '../../widgets/common_widgets_function.dart';
import '../../widgets/loading/loading_popup_widget.dart';
import '../../widgets/loading/loading_text_controller.dart';

class VisitCustomerDetailsPage extends StatefulWidget {
  final String? route;
  final String partnerID;
  const VisitCustomerDetailsPage(
      {super.key, required this.partnerID, this.route});

  @override
  State<VisitCustomerDetailsPage> createState() =>
      _VisitCustomerDetailsPageState();
}

class _VisitCustomerDetailsPageState extends State<VisitCustomerDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController transitionAnimationController;
  late Animation<double> transitionAnimation;
  bool isForward = false;
  @override
  void initState() {
    transitionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    transitionAnimation = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(
        parent: transitionAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    getData();
    super.initState();
  }

  CustomerDetailsModel? customerDetailsModel;
  bool isUnsuccessful = false;

  String? visitTypeName;

  Future<void> getData() async {
    String partnerID = widget.partnerID;
    http.Response response = await http
        .get(Uri.parse('$base$getCustomerDetailsByPartnerID/$partnerID'));
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

  TextEditingController commentsController = TextEditingController();

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
                        SizedBox(
                          height: isForward ? null : 100,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                getRowWidgetForDetailsBox('Partner ID',
                                    customerDetailsModel?.partner),
                                dividerWhite,
                                getRowWidgetForDetailsBox('Pharmacy Name',
                                    customerDetailsModel?.name1),
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
                                              msg: customerDetailsModel
                                                      ?.mobileNo ??
                                                  '');
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
                                if ((customerDetailsModel?.street1 ?? '')
                                    .isNotEmpty)
                                  const Divider(
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                if ((customerDetailsModel?.street1 ?? '')
                                    .isNotEmpty)
                                  getRowWidgetForDetailsBox('Street 1',
                                      customerDetailsModel?.street1),
                                if ((customerDetailsModel?.street2 ?? '')
                                    .isNotEmpty)
                                  const Divider(
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                if ((customerDetailsModel?.street2 ?? '')
                                    .isNotEmpty)
                                  getRowWidgetForDetailsBox('Street 2',
                                      customerDetailsModel?.street2),
                                dividerWhite,
                                getRowWidgetForDetailsBox(
                                    'District', customerDetailsModel?.district),
                                dividerWhite,
                                getRowWidgetForDetailsBox(
                                    'Upazila', customerDetailsModel?.upazilla),
                                dividerWhite,
                                getRowWidgetForDetailsBox('Trans. P. zone',
                                    customerDetailsModel?.transPZone),
                                dividerWhite,
                                getRowWidgetForDetailsBox(
                                    'Latitude',
                                    (customerDetailsModel?.latitude ??
                                            'No Data Found')
                                        .toString()),
                                dividerWhite,
                                getRowWidgetForDetailsBox(
                                    'Longitude',
                                    (customerDetailsModel?.longitude ??
                                            'No Data Found')
                                        .toString()),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                isForward = !isForward;
                              });
                            },
                            child: Icon(
                              isForward
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(15),
                  Text(
                    'Visit Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                  ),
                  Gap(5),
                  FutureBuilder(
                    future: get(Uri.parse(
                        '$base/api/v1/visit/visit_type')),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List visitTypes = jsonDecode(snapshot.data!.body);

                        return SizedBox(
                          child: DropdownMenu(
                              width: double.infinity,
                              dropdownMenuEntries: List.generate(
                                visitTypes.length,
                                (index) {
                                  return DropdownMenuEntry(
                                    value: (visitTypes[index]['value'] ?? '')
                                        .toString(),
                                    label: (visitTypes[index]['value'] ?? '')
                                        .toString()
                                        .replaceAll('_', ' '),
                                  );
                                },
                              ),
                              hintText: 'Select Visit Type',
                              onSelected: (value) {
                                setState(() {
                                  visitTypeName = value.toString();
                                });
                              }),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return Text('Something went wrong');
                      }
                    },
                  ),
                  Gap(15),
                  Text(
                    'Comment',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                  ),
                  Gap(5),
                  TextFormField(
                    controller: commentsController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'type your comment here...'),
                  ),
                  Gap(15),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton.icon(
                      onPressed: null,
                      //  () async {
                      //   if (visitTypeName != null) {
                      //     loadingTextController.currentState.value = 0;
                      //     loadingTextController.loadingText.value =
                      //         'Getting your Location\nPlease wait...';

                      //     showCustomPopUpLoadingDialog(context,
                      //         isCupertino: true);

                      //     Position position =
                      //         await Geolocator.getCurrentPosition();

                      //     log('Got user Location');

                      //     if (Navigator.canPop(context)) {
                      //       Navigator.pop(context);
                      //     }

                      //     if (customerDetailsModel != null) {
                      //       showDialog(
                      //         context: context,
                      //         builder: (context) => AlertDialog(
                      //           insetPadding: EdgeInsets.all(10),
                      //           title: const Text('Are you sure?'),
                      //           content: Column(
                      //             mainAxisAlignment: MainAxisAlignment.start,
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             mainAxisSize: MainAxisSize.min,
                      //             children: [
                      //               Text(
                      //                 'Visit Type : ',
                      //                 style: TextStyle(
                      //                   color: Colors.grey.shade600,
                      //                 ),
                      //               ),
                      //               Text((visitTypeName ?? '')
                      //                   .replaceAll('_', ' ')),
                      //               Gap(7),
                      //               if (commentsController.text.isNotEmpty)
                      //                 Text(
                      //                   'Comments :',
                      //                   style: TextStyle(
                      //                     color: Colors.grey.shade600,
                      //                   ),
                      //                 ),
                      //               if (commentsController.text.isNotEmpty)
                      //                 Text(commentsController.text),
                      //               Gap(7),
                      //               Text(
                      //                 'Your Latitude : ${position.latitude.toPrecision(6)}',
                      //                 style: TextStyle(
                      //                     color: Colors.grey.shade600),
                      //               ),
                      //               Text(
                      //                 'Your Longitude : ${position.longitude.toPrecision(6)}',
                      //                 style: TextStyle(
                      //                     color: Colors.grey.shade600),
                      //               ),
                      //             ],
                      //           ),
                      //           actions: [
                      //             SizedBox(
                      //               width: 120,
                      //               child: ElevatedButton(
                      //                 style: ElevatedButton.styleFrom(
                      //                   backgroundColor: Colors.grey.shade300,
                      //                   foregroundColor: Colors.blue.shade900,
                      //                 ),
                      //                 onPressed: () {
                      //                   Navigator.pop(context);
                      //                 },
                      //                 child: const Text('Cancel'),
                      //               ),
                      //             ),
                      //             SizedBox(
                      //               width: 120,
                      //               child: ElevatedButton(
                      //                 onPressed: () {
                      //                   final box = Hive.box('info');

                      //                   callSetLocationOfCustomer(
                      //                     position,
                      //                     box.get('sap_id').toString(),
                      //                     customerDetailsModel!,
                      //                     visitTypeName!,
                      //                     commentsController.text,
                      //                   );
                      //                 },
                      //                 child: const Text('Yes'),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       );
                      //     }
                      //   } else {
                      //     Fluttertoast.showToast(
                      //       msg: 'Please select visit type',
                      //       toastLength: Toast.LENGTH_SHORT,
                      //     );
                      //   }
                      // },
                      label: Text(
                        'Save',
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

  Future<void> callSetLocationOfCustomer(
      Position position,
      String sapID,
      CustomerDetailsModel customerDetailsModel,
      String visitType,
      String comment) async {
    Navigator.pop(context);
    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Please wait...';

    showCustomPopUpLoadingDialog(context, isCupertino: true);

    final uri = Uri.parse(base + visitApiPath);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: VisitsDataToApiModel(
        daCode: sapID,
        routeCode: widget.route,
        partner: customerDetailsModel.partner,
        visitType: visitType,
        visitLatitude: position.latitude.toPrecision(6),
        visitLongitude: position.longitude.toPrecision(6),
        comment: comment,
      ).toJson(),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
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
