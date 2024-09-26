import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:rdl_radiant/src/screens/home/delivary_ramaining/models/deliver_remaing_model.dart';
import 'package:rdl_radiant/src/screens/home/invoice_list/controller/invoice_list_controller.dart';
import 'package:rdl_radiant/src/screens/home/page_sate_defination.dart';
import 'package:rdl_radiant/src/screens/home/product_list/prodouct_list_page.dart';
import 'package:rdl_radiant/src/screens/home/product_list/cash_collection/product_list_cash_collection.dart';
import 'package:rdl_radiant/src/screens/maps/map_view.dart';
import 'package:simple_icons/simple_icons.dart';

import '../../../theme/text_scaler_theme.dart';
import '../../../widgets/coomon_widgets_function.dart';
import '../delivary_ramaining/controller/delivery_remaning_controller.dart';

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
  final DeliveryRemaningController deliveryRemaningController = Get.find();
  String pageType = '';

  @override
  void initState() {
    pageType = deliveryRemaningController.pageType.value;
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
          title: deliveryRemaningController.pageType.value != ""
              ? Text("${deliveryRemaningController.pageType.value} Details")
              : const Text("Delivery Details"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Get.to(
              () => const MyMapView(
                lat: 23.7363,
                lng: 90.3925,
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
        ),
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
                        widget.result.routeName ?? "",
                      ),
                      divider,
                      getRowWidgetForDetailsBox(
                        "Partner ID",
                        widget.result.partner ?? "",
                      ),
                      divider,
                      getRowWidgetForDetailsBox(
                        "Da Name",
                        widget.result.daName ?? "",
                      ),
                      divider,
                      getRowWidgetForDetailsBox(
                        "Coustomer Name",
                        widget.result.customerName ?? "",
                      ),
                      divider,
                      getRowWidgetForDetailsBox(
                        "Coustomer Address",
                        widget.result.customerAddress ?? "",
                      ),
                      // divider,
                      // getRowWidgetForDetailsBox(
                      //   "Coustomer lat.",
                      //   widget.result.latitude.toString(),
                      // ),
                      // divider,
                      // getRowWidgetForDetailsBox(
                      //   "Coustomer lon.",
                      //   widget.result.longitude.toString(),
                      // ),
                      divider,
                      getRowWidgetForDetailsBox(
                        "Coustomer Mobile",
                        widget.result.customerMobile ?? "",
                        optionalWidgetsAtLast: SizedBox(
                          height: 23,
                          width: 50,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              FlutterClipboard.copy(
                                widget.result.customerMobile ?? "",
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
                        widget.result.gatePassNo ?? "",
                      ),
                      divider,
                      getRowWidgetForDetailsBox(
                        "Total Amount",
                        widget.totalAmount,
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
                    double deliveryAmmount = 0;
                    for (final ProductList productList
                        in invoiceList[index].productList ?? []) {
                      amount +=
                          (productList.netVal ?? 0) + (productList.vat ?? 0);
                      returnQty += (productList.returnQuantity ?? 0).toInt();
                      returnAmount += (productList.returnNetVal ?? 0);
                      deliveryQty +=
                          (productList.deliveryQuantity ?? 0).toInt();
                      deliveryAmmount += (productList.deliveryNetVal ?? 0);
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
                                  invioceNo:
                                      (invoiceList[index].billingDocNo ?? 0)
                                          .toString(),
                                  totalAmount: (amount - returnAmount)
                                      .toStringAsFixed(2),
                                  index: index,
                                ),
                              )
                            : await Get.to(
                                () => ProdouctListPage(
                                  invoice: invoiceList[index],
                                  invioceNo:
                                      (invoiceList[index].billingDocNo ?? 0)
                                          .toString(),
                                  totalAmount: (amount - returnAmount)
                                      .toStringAsFixed(2),
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
                              child: Row(
                                children: [
                                  Text(
                                    (invoiceList[index].billingDocNo ?? 0)
                                        .toString(),
                                    style: style,
                                  ),
                                  const Spacer(),
                                  Text(
                                    invoiceList[index].deliveryStatus ?? "",
                                    style: style.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.3),
                                      borderRadius: const BorderRadius.only(
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
                                      color: Colors.purple.withOpacity(0.3),
                                      borderRadius: !(returnQty == 0 ||
                                              deliveryQty == 0)
                                          ? null
                                          : const BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
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
                                            (invoiceList[index].productList ??
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
                                        color: Colors.green.withOpacity(0.35),
                                        borderRadius: returnQty < 0
                                            ? const BorderRadius.only(
                                                bottomLeft: Radius.circular(10),
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
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: width / 3.5,
                                            child: Text(
                                              deliveryQty.toString(),
                                              style: style.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: width / 3.5,
                                            child: Text(
                                              deliveryAmmount
                                                  .toStringAsFixed(2),
                                              style: style.copyWith(
                                                fontWeight: FontWeight.w500,
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
                                        color: Colors.red.withOpacity(0.35),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
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
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: width / 3.5,
                                            child: Text(
                                              returnQty.toString(),
                                              style: style.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: width / 3.5,
                                            child: Text(
                                              returnAmount.toStringAsFixed(2),
                                              style: style.copyWith(
                                                fontWeight: FontWeight.w500,
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

  TextStyle style = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
  TextStyle topContainerTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
