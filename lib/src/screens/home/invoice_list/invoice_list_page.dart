import 'dart:convert';
import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:rdl_radiant/src/apis/apis.dart';
import 'package:rdl_radiant/src/screens/home/delivery_remaining/models/deliver_remaining_model.dart';
import 'package:rdl_radiant/src/screens/home/invoice_list/controller/invoice_list_controller.dart';
import 'package:rdl_radiant/src/screens/home/page_sate_definition.dart';
import 'package:rdl_radiant/src/screens/home/product_list/product_list_page.dart';
import 'package:rdl_radiant/src/screens/home/product_list/cash_collection/product_list_cash_collection.dart';
import 'package:rdl_radiant/src/screens/maps/map_view.dart';
import 'package:simple_icons/simple_icons.dart';

import '../../../theme/text_scaler_theme.dart';
import '../../../widgets/common_widgets_function.dart';
import '../../../widgets/loading/loading_popup_widget.dart';
import '../../../widgets/loading/loading_text_controller.dart';
import '../delivery_remaining/controller/delivery_remaining_controller.dart';
import 'controller/overdue_collect_controller.dart';

class InvoiceListPage extends StatefulWidget {
  final DateTime dateTime;
  final Result result;
  final String totalAmount;
  const InvoiceListPage(
      {super.key,
      required this.dateTime,
      required this.result,
      required this.totalAmount});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  final invoiceListController = Get.put(InvoiceListController());
  final DeliveryRemainingController deliveryRemainingController = Get.find();
  final LoadingTextController loadingTextController = Get.find();
  late final routeName = invoiceListController.invoiceList[0].routeName ?? "";
  late final daName = invoiceListController.invoiceList[0].daName ?? "";
  late final partner = invoiceListController.invoiceList[0].partner ?? "";
  late final customerName =
      invoiceListController.invoiceList[0].customerName ?? "";
  late final customerAddress =
      invoiceListController.invoiceList[0].customerAddress ?? "";

  String pageType = '';
  late double due = invoiceListController.invoiceList[0].previousDueAmount ?? 0;
  late final customerMobile =
      invoiceListController.invoiceList[0].customerMobile ?? "";
  late final gatePassNo = invoiceListController.invoiceList[0].gatePassNo ?? "";

  late String totalAmount;

  @override
  void initState() {
    pageType = deliveryRemainingController.pageType.value;
    totalAmount = widget.totalAmount;
    super.initState();
  }

  Widget divider = const Divider(
    color: Colors.white,
    height: 1,
  );

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScalerValue)),
      child: Scaffold(
        appBar: AppBar(
          title: deliveryRemainingController.pageType.value != ""
              ? Text("${deliveryRemainingController.pageType.value} Details")
              : const Text("Delivery Details"),
        ),
        floatingActionButton: widget.result.customerLatitude != null &&
                widget.result.customerLongitude != null
            ? FloatingActionButton(
                onPressed: () async {
                  Get.to(
                    () => MyMapView(
                      lat: widget.result.customerLatitude,
                      lng: widget.result.customerLongitude,
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
        body: ListView(padding: const EdgeInsets.all(10), children: [
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
                      getRowWidgetForDetailsBox(
                        "Route Name",
                        routeName,
                      ),

                      divider,
                      getRowWidgetForDetailsBox(
                        "Da Name",
                        daName,
                      ),
                      divider,
                      getRowWidgetForDetailsBox(
                        "Partner ID",
                        partner,
                      ),
                      divider,
                      getRowWidgetForDetailsBox(
                        "Customer Name",
                        customerName,
                      ),
                      divider,
                      getRowWidgetForDetailsBox(
                        "Customer Address",
                        customerAddress,
                      ),
                      // divider,
                      // getRowWidgetForDetailsBox(
                      //   "Customer lat.",
                      //   invoiceListController.invoiceList[0].latitude.toString(),
                      // ),
                      // divider,
                      // getRowWidgetForDetailsBox(
                      //   "Customer lon.",
                      //   invoiceListController.invoiceList[0].longitude.toString(),
                      // ),
                      divider,
                      getRowWidgetForDetailsBox(
                        "Customer Mobile",
                        customerMobile,
                        optionalWidgetsAtLast: SizedBox(
                          height: 23,
                          width: 50,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              FlutterClipboard.copy(
                                customerMobile,
                              ).then((value) {
                                Fluttertoast.showToast(msg: "Number Copied");
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
                      getRowWidgetForDetailsBox(
                        "Gate Pass",
                        gatePassNo,
                      ),
                      divider,
                      getRowWidgetForDetailsBox(
                        (pageType == pagesState[5])
                            ? "Total Due Amount"
                            : "Total Amount",
                        double.parse(totalAmount).toStringAsFixed(2),
                      ),
                      if (pageType != pagesState[5]) divider,
                      if (pageType != pagesState[5])
                        getRowWidgetForDetailsBox(
                          "Previous Due",
                          due.toStringAsFixed(2),
                          optionalWidgetsAtLast: Row(
                            children: [
                              SizedBox(
                                height: 25,
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: due == 0
                                      ? null
                                      : () async {
                                          // Backup Current Data
                                          await onPreviousDueCollectButtonPressed(
                                              context);
                                        },
                                  child: const Text("Collect"),
                                ),
                              ),
                            ],
                          ),
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
              List<InvoiceList> invoiceList =
                  invoiceListController.invoiceList.value;
              return Column(
                children: List.generate(
                  invoiceList.length,
                  (index) {
                    double amount = 0;
                    int returnQty = 0;
                    double returnAmount = 0;
                    int deliveryQty = 0;
                    double deliveryAmount = 0;
                    for (final ProductList productList
                        in invoiceList[index].productList ?? []) {
                      amount +=
                          (productList.netVal ?? 0) + (productList.vat ?? 0);
                      returnQty += (productList.returnQuantity ?? 0).toInt();
                      returnAmount += (productList.returnNetVal ?? 0);
                      deliveryQty +=
                          (productList.deliveryQuantity ?? 0).toInt();
                      deliveryAmount += (productList.deliveryNetVal ?? 0);
                    }

                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        (pageType == pagesState[2] ||
                                pageType == pagesState[3] ||
                                pageType == pagesState[4])
                            ? await Get.to(
                                () => ProductListCashCollection(
                                  invoice: invoiceList[index],
                                  invoiceNo:
                                      (invoiceList[index].billingDocNo ?? 0)
                                          .toString(),
                                  totalAmount:
                                      (amount - returnAmount).toString(),
                                  index: index,
                                ),
                              )
                            : await Get.to(
                                () => ProductListPage(
                                  invoice: invoiceList[index],
                                  invoiceNo:
                                      (invoiceList[index].billingDocNo ?? 0)
                                          .toString(),
                                  totalAmount: pageType == pagesState[5]
                                      ? (invoiceList[index].dueAmount ?? 0)
                                          .toStringAsFixed(2)
                                      : (amount - returnAmount).toString(),
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
                                        "Invoice No:",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Gap(7),
                                      Text(
                                        (invoiceList[index].billingDocNo ?? 0)
                                            .toString(),
                                        style: style,
                                      ),
                                      Text(
                                        " (${invoiceList[index].producerCompany ?? ""})",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        invoiceList[index].deliveryStatus ?? "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                      )
                                    ],
                                  ),
                                  if (pageType == pagesState[5])
                                    Row(
                                      children: [
                                        const Text(
                                          "Billing Date: ",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Gap(5),
                                        Text(
                                          invoiceList[index]
                                              .billingDate!
                                              .toIso8601String()
                                              .split('T')[0],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade700,
                                          ),
                                        )
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: pageType == pagesState[5]
                                  ? Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              "Due amount: ",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Gap(10),
                                            Text(
                                                (invoiceList[index].dueAmount ??
                                                        0)
                                                    .toStringAsFixed(2)),
                                            const Spacer(),
                                            const Icon(
                                              Icons.arrow_forward,
                                              size: 17,
                                            ),
                                          ],
                                        ),
                                        const Gap(10),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 30,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              callDueCollectionApi(
                                                  invoiceList, index, context);
                                            },
                                            child: const Text("Collect"),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: width / 3.5,
                                                child: Text(
                                                  "Type",
                                                  style: style,
                                                ),
                                              ),
                                              SizedBox(
                                                width: width / 3.5,
                                                child: Text(
                                                  "Quantity",
                                                  style: style,
                                                ),
                                              ),
                                              SizedBox(
                                                width: width / 3.5,
                                                child: Text(
                                                  "Amount",
                                                  style: style,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.purple.withOpacity(0.2),
                                            borderRadius: !(returnQty == 0 ||
                                                    deliveryQty == 0)
                                                ? null
                                                : const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10),
                                                  ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: width / 3.5,
                                                child: Text(
                                                  "Invoice",
                                                  style: style.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: width / 3.5,
                                                child: Text(
                                                  (invoiceList[index]
                                                              .productList ??
                                                          [])
                                                      .length
                                                      .toString(),
                                                  style: style.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: width / 3.5,
                                                child: Text(
                                                  amount.toStringAsFixed(2),
                                                  style: style.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (deliveryQty > 0)
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.green.withOpacity(0.2),
                                              borderRadius: returnQty < 0
                                                  ? const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10))
                                                  : null,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: width / 3.5,
                                                  child: Text(
                                                    "Delivered",
                                                    style: style.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: width / 3.5,
                                                  child: Text(
                                                    deliveryQty.toString(),
                                                    style: style.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: width / 3.5,
                                                  child: Text(
                                                    deliveryAmount
                                                        .toStringAsFixed(2),
                                                    style: style.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (returnQty > 0)
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.35),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: width / 3.5,
                                                  child: Text(
                                                    "Returned",
                                                    style: style.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: width / 3.5,
                                                  child: Text(
                                                    returnQty.toString(),
                                                    style: style.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: width / 3.5,
                                                  child: Text(
                                                    returnAmount
                                                        .toStringAsFixed(2),
                                                    style: style.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
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
        ]),
      ),
    );
  }

  Future<void> onPreviousDueCollectButtonPressed(BuildContext context) async {
    // Backup Current Data
    final invoiceList = invoiceListController.invoiceList.value.toList();
    final String? partnerPrev = invoiceListController.invoiceList[0].partner;

    final constDeliveryRemaining =
        deliveryRemainingController.constDeliveryRemaining.value.toMap();
    final pageTypePrev = deliveryRemainingController.pageType.value.toString();
    final x = deliveryRemainingController.x.toMap();

    //Call api for due list
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$getOverdueList/${box.get('sap_id')}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCustomPopUpLoadingDialog(context, isCupertino: true);

    final response = await get(url);

    if (kDebugMode) {
      log("Got Overdue List");
      log(response.statusCode.toString());
      log(response.body);
    }

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';

      final modelFormHTTPResponse = DeliveryRemaining.fromJson(response.body);
      final partners = modelFormHTTPResponse.result!;
      Map<String, List<Result>> mapForMarge = {};
      for (var partner in partners) {
        List<Result> previousList = mapForMarge[partner.partner] ?? [];
        if (previousList.isNotEmpty) {
          previousList[0].invoiceList!.addAll(partner.invoiceList!);
          mapForMarge[partner.partner!] = previousList;
        } else {
          previousList.add(partner);
          mapForMarge[partner.partner!] = previousList;
        }
      }

      modelFormHTTPResponse.result = [];
      mapForMarge.forEach(
        (key, value) {
          modelFormHTTPResponse.result!.add(value[0]);
        },
      );

      final controller = Get.put(
        DeliveryRemainingController(modelFormHTTPResponse),
      );
      controller.deliveryRemaining.value = modelFormHTTPResponse;
      controller.constDeliveryRemaining.value = modelFormHTTPResponse;
      controller.deliveryRemaining.value.result ??= [];
      controller.constDeliveryRemaining.value.result ??= [];
      controller.pageType.value = 'Overdue';
      await Future.delayed(const Duration(milliseconds: 100));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      //  Go to invoice directly
      final results = controller.constDeliveryRemaining.value.result!;
      Result? result;
      for (var r in results) {
        if (r.partner == partnerPrev) {
          result = r;
        }
      }

      if (result != null) {
        invoiceListController.invoiceList.value =
            result.invoiceList ?? <InvoiceList>[];
        await showModalBottomSheet(
            scrollControlDisabledMaxHeightRatio: 0.8,
            context: context,
            builder: (context) => InvoiceListPage(
                  dateTime: widget.dateTime,
                  result: result!,
                  totalAmount: due.toString(),
                ));
      }

      // back
    } else {
      loadingTextController.currentState.value = -1;
      loadingTextController.loadingText.value = 'Something went wrong';
    }

    //Back data again
    invoiceListController.invoiceList.value = invoiceList;

    deliveryRemainingController.constDeliveryRemaining.value =
        DeliveryRemaining.fromMap(constDeliveryRemaining);
    deliveryRemainingController.pageType.value = pageTypePrev;
    deliveryRemainingController.x = DeliveryRemaining.fromMap(x);
  }

  void callDueCollectionApi(
      List<InvoiceList> invoiceList, int index, BuildContext context) {
    final dueController = Get.put(OverdueCollectController());
    dueController.previousDue.value = invoiceList[index].dueAmount ?? 0;
    dueController.currentDue.value = invoiceList[index].dueAmount ?? 0;

    TextEditingController textEditingController = TextEditingController();
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
                  "Collect Due",
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
                    double? doubleValue = double.tryParse(value ?? "");
                    if (doubleValue != null) {
                      if (doubleValue > dueController.previousDue.value) {
                        return "amount can't be bigger than due amount";
                      } else {
                        return null;
                      }
                    } else {
                      return "value is not valid";
                    }
                  },
                  onChanged: (value) {
                    dueController.collectAmount.value =
                        double.tryParse(value) ?? 0;
                    double currentDue = (invoiceList[index].dueAmount ?? 0) -
                        (double.tryParse(value) ?? 0);

                    dueController.currentDue.value = currentDue < 0
                        ? (invoiceList[index].dueAmount ?? 0)
                        : currentDue;
                  },
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: "type amount here",
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
                      "Previous due:",
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
                      "Due after collection:",
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
                            loadingTextController.currentState.value = 0;
                            loadingTextController.loadingText.value =
                                'Accessing Your Location\nPlease wait...';

                            showCustomPopUpLoadingDialog(context,
                                isCupertino: true);
                            try {
                              final position =
                                  await Geolocator.getCurrentPosition(
                                locationSettings: AndroidSettings(
                                    timeLimit: const Duration(seconds: 30)),
                              );
                              String encodedDataToSend = jsonEncode({
                                "billing_doc_no":
                                    invoiceList[index].billingDocNo ?? "",
                                "cash_collection":
                                    dueController.collectAmount.value,
                                "da_code":
                                    Hive.box('info').get("sap_id") as int,
                                "cash_collection_latitude": position.latitude,
                                "cash_collection_longitude": position.longitude,
                              });
                              if (kDebugMode) {
                                log("Sending to api: ");

                                log(encodedDataToSend);
                              }
                              loadingTextController.loadingText.value =
                                  'Your Location Accessed\nSending data to server\nPlease wait...';

                              final response = await put(
                                Uri.parse(
                                  base + collectOverdue,
                                ),
                                body: encodedDataToSend,
                                headers: {
                                  "content-type": "application/json",
                                },
                              );
                              if (response.statusCode == 200) {
                                final decoded = Map<String, dynamic>.from(
                                    jsonDecode(response.body));
                                if (decoded['success'] == true) {
                                  try {
                                    final box = Hive.box('info');
                                    final url = Uri.parse(
                                        "$base$getOverdueList/${box.get('sap_id')}");

                                    final response = await get(url);

                                    if (response.statusCode == 200) {
                                      if (kDebugMode) {
                                        print("Got Due List");
                                        print(response.body);
                                      }

                                      final controller = Get.put(
                                        DeliveryRemainingController(
                                          DeliveryRemaining.fromJson(
                                              response.body),
                                        ),
                                      );
                                      controller.deliveryRemaining.value =
                                          DeliveryRemaining.fromJson(
                                              response.body);
                                      controller.constDeliveryRemaining.value =
                                          DeliveryRemaining.fromJson(
                                              response.body);
                                      controller.deliveryRemaining.value
                                          .result ??= [];
                                      controller.constDeliveryRemaining.value
                                          .result ??= [];
                                    }
                                  } catch (e) {
                                    log(e.toString());
                                  }
                                  loadingTextController.currentState.value = 0;
                                  loadingTextController.loadingText.value =
                                      'Successful';
                                  double due = dueController.previousDue.value -
                                      dueController.collectAmount.value;
                                  if (due == 0) {
                                    invoiceListController.invoiceList.removeAt(
                                      index,
                                    );
                                  } else {
                                    setState(() {
                                      totalAmount = due.toString();
                                      invoiceList[index].dueAmount = due;
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
                                  loadingTextController.loadingText.value =
                                      decoded['message'];
                                }
                              }
                            } catch (e) {
                              loadingTextController.currentState.value = -1;
                              loadingTextController.loadingText.value =
                                  'Unable to access your location';
                            }
                            return;
                          }
                        }
                        Fluttertoast.showToast(msg: "Amount is not valid");
                      },
                      child: const Text("Collect")),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  TextStyle style = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
  TextStyle topContainerTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
