import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:odms/src/screens/home/delivery_remaining/models/deliver_remaining_model.dart';
import 'package:odms/src/screens/maps/map_view.dart';
import 'package:odms/src/screens/overdue/controller.dart';
import 'package:odms/src/screens/overdue/overdue_product_list.dart';
import 'package:simple_icons/simple_icons.dart';

import '../../theme/text_scaler_theme.dart';
import '../../widgets/common_widgets_function.dart';
import '../../widgets/loading/loading_text_controller.dart';

class OverdueInvoiceList extends StatefulWidget {
  final DateTime dateTime;
  final Result result;
  final String totalAmount;
  const OverdueInvoiceList(
      {super.key,
      required this.dateTime,
      required this.result,
      required this.totalAmount});

  @override
  State<OverdueInvoiceList> createState() => _OverdueInvoiceListState();
}

class _OverdueInvoiceListState extends State<OverdueInvoiceList> {
  final overdueInvoiceListController = Get.put(OverdueInvoiceListController());
  final OverdueCollectController deliveryRemainingController = Get.find();
  final LoadingTextController loadingTextController = Get.find();
  late final routeName =
      overdueInvoiceListController.invoiceList[0].routeName ?? "";
  late final daName = overdueInvoiceListController.invoiceList[0].daName ?? "";
  late final partner =
      overdueInvoiceListController.invoiceList[0].partner ?? "";
  late final customerName =
      overdueInvoiceListController.invoiceList[0].customerName ?? "";
  late final customerAddress =
      overdueInvoiceListController.invoiceList[0].customerAddress ?? "";

  String pageType = '';
  late double due =
      overdueInvoiceListController.invoiceList[0].previousDueAmount ?? 0;
  late final customerMobile =
      overdueInvoiceListController.invoiceList[0].customerMobile ?? "";
  late final gatePassNo =
      overdueInvoiceListController.invoiceList[0].gatePassNo ?? "";

  late String totalAmount;

  @override
  void initState() {
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
          title: const Text("Overdue Invoice List"),
        ),
        floatingActionButton: widget.result.customerLatitude != null &&
                widget.result.customerLongitude != null
            ? FloatingActionButton(
                onPressed: () async {
                  log("Lat:${widget.result.customerLatitude} ");
                  log("Lat:${widget.result.customerLongitude} ");
                  Get.to(
                    () => MyMapView(
                      lat: widget.result.customerLatitude,
                      lng: widget.result.customerLongitude,
                      customerName: customerName,
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
                        "Total Amount",
                        double.parse(totalAmount).toStringAsFixed(2),
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
                  overdueInvoiceListController.invoiceList.value;
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
                        Get.to(() => OverdueProductList(
                              invoice: invoiceList[index],
                              invoiceNo: (invoiceList[index].billingDocNo ?? 0)
                                  .toString(),
                              totalAmount: (amount - returnAmount).toString(),
                              index: index,
                              dateOfDelivery: widget.dateTime,
                            ));
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
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Billing Date:",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Gap(7),
                                      Text(
                                        DateFormat('yyyy-MM-dd').format(
                                            invoiceList[index].billingDate ??
                                                DateTime.now()),
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
                                        "Due amount:",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Gap(7),
                                      Text(
                                        (invoiceList[index].dueAmount ?? 0)
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
                                      onPressed: () {},
                                      child: Text("Collect"),
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

  TextStyle style = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
  TextStyle topContainerTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
