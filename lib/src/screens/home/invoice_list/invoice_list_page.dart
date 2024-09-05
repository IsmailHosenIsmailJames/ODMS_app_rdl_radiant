import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:rdl_radiant/src/screens/home/delivary_ramaining/models/deliver_remaing_model.dart';
import 'package:rdl_radiant/src/screens/home/invoice_list/controller/invoice_list_controller.dart';
import 'package:rdl_radiant/src/screens/home/product_list/prodouct_list_page.dart';
import 'package:rdl_radiant/src/screens/home/product_list/cash_collection/product_list_cash_collection.dart';
import 'package:rdl_radiant/src/screens/maps/map_view.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:http/http.dart' as http;

import '../../../apis/apis.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
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
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: const Text(
                              "Route Name",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          ":  ",
                          style: TextStyle(fontSize: 18),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              widget.result.routeName ?? "",
                              style: topContainerTextStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.white,
                      height: 1,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: const Text(
                              "Da Name",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          ":  ",
                          style: TextStyle(fontSize: 18),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              widget.result.daName ?? "",
                              style: topContainerTextStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.white,
                      height: 1,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: const Text(
                              "Coustomer Name",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          ":  ",
                          style: TextStyle(fontSize: 18),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              widget.result.customerName ?? "",
                              style: topContainerTextStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.white,
                      height: 1,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: const Text(
                              "Coustomer Address",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          ":  ",
                          style: TextStyle(fontSize: 18),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              widget.result.customerAddress ?? "",
                              style: topContainerTextStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.white,
                      height: 1,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: const Text(
                              "Coustomer Mobile",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          ":  ",
                          style: TextStyle(fontSize: 18),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  widget.result.customerMobile ?? "",
                                  style: topContainerTextStyle,
                                ),
                                SizedBox(
                                  height: 23,
                                  width: 90,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      FlutterClipboard.copy(
                                        widget.result.customerMobile ?? "",
                                      ).then((value) {
                                        Fluttertoast.showToast(
                                            msg: "Number Copied");
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.copy,
                                      size: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.white,
                      height: 1,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: const Text(
                              "Gate Pass",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          ":  ",
                          style: TextStyle(fontSize: 18),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Text(
                                  widget.result.gatePassNo ?? "",
                                  style: topContainerTextStyle,
                                ),
                                SizedBox(
                                  height: 23,
                                  width: 90,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      FlutterClipboard.copy(
                                        widget.result.gatePassNo ?? "",
                                      ).then((value) {
                                        Fluttertoast.showToast(
                                            msg: "Number Copied");
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.copy,
                                      size: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.white,
                      height: 1,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: const Text(
                              "Total Amount",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          ":  ",
                          style: TextStyle(fontSize: 18),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              widget.totalAmount,
                              style: topContainerTextStyle,
                            ),
                          ),
                        ),
                      ],
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
                    deliveryQty += (productList.deliveryQuantity ?? 0).toInt();
                    deliveryAmmount += (productList.deliveryNetVal ?? 0);
                  }

                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      deliveryRemaningController.pageType.value;
                      deliveryRemaningController.pageType.value != ""
                          ? await Get.to(
                              () => ProductListCashCollection(
                                invoice: invoiceList[index],
                                invioceNo:
                                    (invoiceList[index].billingDocNo ?? 0)
                                        .toString(),
                                totalAmount: amount.toStringAsFixed(2),
                                index: index,
                              ),
                            )
                          : await Get.to(
                              () => ProdouctListPage(
                                invoice: invoiceList[index],
                                invioceNo:
                                    (invoiceList[index].billingDocNo ?? 0)
                                        .toString(),
                                totalAmount: amount.toStringAsFixed(2),
                                index: index,
                              ),
                            );
                      if (invoiceList.isEmpty) {
                        final box = Hive.box('info');
                        final url = Uri.parse(
                          "$base$getDelivaryList/${box.get('sap_id')}?type=Remaining&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
                        );

                        final response = await http.get(url);

                        if (response.statusCode == 200) {
                          if (kDebugMode) {
                            print("Got Delivery Remaning List");
                            print(response.body);
                          }

                          final controller = Get.put(
                            DeliveryRemaningController(
                              DeliveryRemaing.fromJson(response.body),
                            ),
                          );
                          controller.deliveryRemaing.value =
                              DeliveryRemaing.fromJson(response.body);
                          controller.constDeliveryRemaing.value =
                              DeliveryRemaing.fromJson(response.body);
                          controller.deliveryRemaing.value.result ??= [];
                          controller.constDeliveryRemaing.value.result ??= [];
                        }
                      }
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: width / 3.39,
                                        child: Text(
                                          "Type",
                                          style: style,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width / 3.39,
                                        child: Text(
                                          "Quantity",
                                          style: style,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width / 3.39,
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
                                    borderRadius: ((deliveryRemaningController
                                                        .isDataForDeliveryDone
                                                        .value ==
                                                    false &&
                                                deliveryRemaningController
                                                        .pageType.value !=
                                                    "")) ||
                                            deliveryRemaningController
                                                .isDataForDeliveryDone.value
                                        ? null
                                        : const BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: width / 3.39,
                                        child: Text(
                                          "Invoice",
                                          style: style.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width / 3.39,
                                        child: Text(
                                          (invoiceList[index].productList ?? [])
                                              .length
                                              .toString(),
                                          style: style.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width / 3.39,
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
                                if ((deliveryRemaningController
                                                .isDataForDeliveryDone.value ==
                                            false &&
                                        deliveryRemaningController
                                                .pageType.value !=
                                            "") ||
                                    deliveryRemaningController
                                        .isDataForDeliveryDone.value)
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.35),
                                      borderRadius: deliveryRemaningController
                                              .isDataForDeliveryDone.value
                                          ? const BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10))
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: width / 3.39,
                                          child: Text(
                                            "Delivered",
                                            style: style.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: width / 3.39,
                                          child: Text(
                                            deliveryQty.toString(),
                                            style: style.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: width / 3.39,
                                          child: Text(
                                            deliveryAmmount.toStringAsFixed(2),
                                            style: style.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if ((deliveryRemaningController
                                            .isDataForDeliveryDone.value ==
                                        false &&
                                    deliveryRemaningController.pageType.value !=
                                        ""))
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
                                          width: width / 3.39,
                                          child: Text(
                                            "Returned",
                                            style: style.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: width / 3.39,
                                          child: Text(
                                            returnQty.toString(),
                                            style: style.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: width / 3.39,
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
    );
  }

  TextStyle style = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
  TextStyle topContainerTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
