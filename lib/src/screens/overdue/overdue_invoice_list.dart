import 'dart:convert';
import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:odms/src/screens/overdue/controllers/overdue_controller_getx.dart';
import 'package:odms/src/screens/overdue/models/overdue_response_model.dart';
import 'package:odms/src/screens/overdue/overdue_product_list.dart';
import 'package:simple_icons/simple_icons.dart';

import '../../apis/apis.dart';
import '../../theme/text_scaler_theme.dart';
import '../../widgets/common_widgets_function.dart';
import '../../widgets/loading/loading_popup_widget.dart';
import '../../widgets/loading/loading_text_controller.dart';
import '../maps/map_view.dart';

class OverdueInvoiceList extends StatefulWidget {
  final DateTime dateTime;
  final Result result;
  final double dueAmount;
  const OverdueInvoiceList(
      {super.key,
      required this.dateTime,
      required this.result,
      required this.dueAmount});

  @override
  State<OverdueInvoiceList> createState() => _OverdueInvoiceListState();
}

class _OverdueInvoiceListState extends State<OverdueInvoiceList> {
  final overdueInvoiceListController = Get.put(OverdueDocsListController());
  final OverdueControllerGetx overdueCollectController = Get.find();
  final LoadingTextController loadingTextController = Get.find();

  // late final routeName =
  //     overdueInvoiceListController.docsList[0].routeName ?? "";
  late final daName = widget.result.daFullName;
  late final partner = widget.result.partnerId;
  late final customerName = widget.result.customerName;
  late final customerAddress = widget.result.customerAddress;

  String pageType = '';
  late double due = overdueInvoiceListController.docsList[0].dueAmount ?? 0;
  late final customerMobile = widget.result.customerMobile;
  // late final gatePassNo =
  //     overdueInvoiceListController.docsList[0].gatePassNo ;

  double totalAmount = 0;

  @override
  void initState() {
    widget.result.billingDocs?.forEach(
      (element) {
        totalAmount += element.dueAmount ?? 0;
      },
    );
    super.initState();
  }

  Widget divider = const Divider(
    color: Colors.white,
    height: 1,
  );

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScalerValue)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Overdue Invoice List'),
        ),
        floatingActionButton: widget.result.customerLatitude != null &&
                widget.result.customerLongitude != null
            ? FloatingActionButton(
                onPressed: () async {
                  log('Lat:${widget.result.customerLatitude} ');
                  log('Lat:${widget.result.customerLongitude} ');
                  Get.to(
                    () => MyMapView(
                      lat: widget.result.customerLatitude!,
                      lng: widget.result.customerLongitude!,
                      customerName: customerName ?? '',
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade800,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    SimpleIcons.googlemaps,
                  ),
                ),
              )
            : null,
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          widget.dateTime.toIso8601String().split('T')[0],
                          style: topContainerTextStyle,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        // getRowWidgetForDetailsBox(
                        //   "Route Name",
                        //   routeName,
                        // ),
                        // divider,
                        getRowWidgetForDetailsBox(
                          'Da Name',
                          daName,
                        ),
                        divider,
                        getRowWidgetForDetailsBox(
                          'Partner ID',
                          partner,
                        ),
                        divider,
                        getRowWidgetForDetailsBox(
                          'Customer Name',
                          customerName,
                        ),
                        divider,
                        getRowWidgetForDetailsBox(
                          'Customer Address',
                          customerAddress,
                        ),
                        divider,
                        getRowWidgetForDetailsBox(
                          'Customer Mobile',
                          customerMobile,
                          optionalWidgetsAtLast: SizedBox(
                            height: 23,
                            width: 50,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                FlutterClipboard.copy(
                                  customerMobile ?? '',
                                ).then((value) {
                                  Fluttertoast.showToast(msg: 'Number Copied');
                                });
                              },
                              icon: const Icon(
                                Icons.copy,
                                size: 17,
                              ),
                            ),
                          ),
                        ),
                        divider,
                        // getRowWidgetForDetailsBox(
                        //   "Gate Pass",
                        //   gatePassNo,
                        // ),
                        // divider,
                        getRowWidgetForDetailsBox(
                          'Total Due Amount',
                          (totalAmount < 0 ? 0 : totalAmount)
                              .toStringAsFixed(2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(15),
            Obx(
              () {
                log('List Generated');
                List<BillingDoc> docsList =
                    overdueInvoiceListController.docsList.value;
                return Column(
                  children: List.generate(
                    docsList.length,
                    (index) {
                      // double amount = 0;
                      // double returnAmount = 0;
                      // for (final ProductList productList
                      //     in docsList[index].productList ?? []) {
                      //   amount +=
                      //       (productList.netVal ?? 0) + (productList.vat ?? 0);
                      //   returnAmount += (productList.returnNetVal ?? 0);
                      // }

                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          double amount = 0;
                          double returnAmount = 0;
                          for (final MaterialModel productList
                              in docsList[index].materials ?? []) {
                            amount += productList.deliveryNetVal;
                            returnAmount += productList.returnNetVal ?? 0;
                          }
                          Get.to(
                            () => OverdueProductList(
                              billingDoc: docsList[index],
                              invoiceNo:
                                  docsList[index].billingDocNo.toString(),
                              totalAmount: (amount - returnAmount).toString(),
                              result: widget.result,
                              index: index,
                              dateOfDelivery: widget.dateTime,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 5, bottom: 5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                    top: 8, bottom: 5, left: 8, right: 8),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Invoice No:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Gap(7),
                                        Text(
                                          docsList[index]
                                              .billingDocNo
                                              .toString(),
                                          style: style,
                                        ),
                                        // Text(
                                        //   " (${docsList[index].producerCompany ?? ""})",
                                        //   style: TextStyle(
                                        //     color: Colors.grey.shade700,
                                        //   ),
                                        // ),
                                        // const Spacer(),
                                        // Text(
                                        //   docsList[index].deliveryStatus ?? "",
                                        //   style: Theme.of(context)
                                        //       .textTheme
                                        //       .bodyLarge
                                        //       ?.copyWith(
                                        //         color: Colors.grey.shade600,
                                        //       ),
                                        // )
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Billing Date:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Gap(7),
                                        Text(
                                          DateFormat('yyyy-MM-dd').format(
                                              docsList[index].billingDate),
                                          style: style,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Due amount:',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Gap(7),
                                        Text(
                                          (docsList[index].dueAmount ?? 0)
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Gap(10),
                                    SizedBox(
                                      height: 30,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          callDueCollectionApi(
                                              docsList, index, context);
                                        },
                                        child: Text('Collect'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void callDueCollectionApi(
      List<BillingDoc> docsList, int index, BuildContext context) {
    OverdueControllerGetx dueController = Get.find();
    dueController.previousDue.value = docsList[index].dueAmount ?? 0;
    dueController.currentDue.value = 0;

    TextEditingController textEditingController =
        TextEditingController(text: dueController.previousDue.toString());
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Collect Due',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const Gap(20),
                TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) {
                    double? doubleValue = double.tryParse(value ?? '');
                    if (doubleValue != null && doubleValue >= 0) {
                      if (doubleValue > dueController.previousDue.value) {
                        return "amount can't be bigger than due amount";
                      } else {
                        return null;
                      }
                    } else {
                      return 'value is not valid';
                    }
                  },
                  onChanged: (value) {
                    dueController.collectAmount.value =
                        double.tryParse(value) ?? 0;
                    double currentDue = (docsList[index].dueAmount ?? 0) -
                        (double.tryParse(value) ?? 0);

                    dueController.currentDue.value = currentDue < 0
                        ? (docsList[index].dueAmount ?? 0)
                        : currentDue;
                  },
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: 'type amount here',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                ),
                const Gap(10),
                Row(
                  children: [
                    Text(
                      'Previous due:',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Gap(10),
                    Obx(
                      () => Text(
                        dueController.previousDue.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  ],
                ),
                const Gap(5),
                Row(
                  children: [
                    Text(
                      'Due after collection:',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Gap(10),
                    Obx(
                      () => Text(
                        dueController.currentDue.toStringAsFixed(2),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  ],
                ),
                const Gap(15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () async {
                        double? doubleValue =
                            double.tryParse(textEditingController.text);
                        if (doubleValue != null) {
                          if (doubleValue > dueController.previousDue.value) {
                            return;
                          } else {
                            await onDueCashCollection(
                                context,
                                docsList,
                                index,
                                doubleValue,
                                dueController.previousDue.value,
                                dueController);
                            return;
                          }
                        }
                        Fluttertoast.showToast(msg: 'Amount is not valid');
                      },
                      child: const Text('Collect')),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> onDueCashCollection(
      BuildContext context,
      List<BillingDoc> docsList,
      int index,
      double doubleValue,
      double totalDue,
      OverdueControllerGetx dueController) async {
    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value =
        'Accessing Your Location\nPlease wait...';

    showCustomPopUpLoadingDialog(context, isCupertino: true);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            AndroidSettings(timeLimit: const Duration(seconds: 30)),
      );
      String encodedDataToSend = jsonEncode({
        'billing_doc_no': docsList[index].billingDocNo,
        'cash_collection': doubleValue,
        'da_code': Hive.box('info').get('sap_id') as int,
        'cash_collection_latitude': position.latitude,
        'cash_collection_longitude': position.longitude,
      });
      log('Sending to api: ');
      log(encodedDataToSend);

      loadingTextController.loadingText.value =
          'Your Location Accessed\nSending data to server\nPlease wait...';

      final response = await put(
        Uri.parse(
          base + collectOverdue,
        ),
        body: encodedDataToSend,
        headers: {
          'content-type': 'application/json',
        },
      );

      log('Got Response on ${base + collectOverdue}');
      log(response.statusCode.toString());

      if (response.statusCode == 200) {
        final decoded = Map<String, dynamic>.from(jsonDecode(response.body));
        if (decoded['success'] == true) {
          log('Awaiting a 1 second');
          await Future.delayed(Duration(seconds: 1));
          log('done awaiting a 1 second');

          final box = Hive.box('info');
          final url = Uri.parse("$base$getOverdueListV2/${box.get('sap_id')}");

          final response = await get(url);
          log('Got overdue Remaining List');
          log(response.statusCode.toString());
          log(response.body);

          if (response.statusCode == 200) {
            final modelFormHTTPResponse =
                OverdueResponseModel.fromJson(response.body);

            final controller = Get.put(
              OverdueControllerGetx(modelFormHTTPResponse),
            );
            controller.overdueRemaining.value = modelFormHTTPResponse;
            controller.constOverdueRemaining.value = modelFormHTTPResponse;
            controller.overdueRemaining.value.result ??= [];
            controller.constOverdueRemaining.value.result ??= [];

            log(modelFormHTTPResponse.toString());
          }

          loadingTextController.currentState.value = 0;
          loadingTextController.loadingText.value = 'Successful';
          double due = totalDue - doubleValue;
          if (due == 0) {
            log('DUE IS ZERO');

            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                overdueInvoiceListController.docsList.removeAt(
                  index,
                );
              });
            });
          } else {
            log('DUE IS NOT ZERO');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                docsList[index].dueAmount = due;
                totalAmount = 0;
                for (int i = 0; i < docsList.length; i++) {
                  totalAmount += docsList[i].dueAmount ?? 0;
                }
              });
            });
          }
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } else {
          loadingTextController.currentState.value = -1;
          loadingTextController.loadingText.value = decoded['message'];
        }
      }
    } catch (e) {
      loadingTextController.currentState.value = -1;
      loadingTextController.loadingText.value =
          'Unable to access your location';
    }
  }

  TextStyle style = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
  TextStyle topContainerTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
