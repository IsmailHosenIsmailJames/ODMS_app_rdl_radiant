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
import 'package:intl/intl.dart';
import 'package:odms/src/apis/apis.dart';
import 'package:odms/src/screens/home/delivery_remaining/controller/delivery_remaining_controller.dart';
import 'package:odms/src/screens/home/delivery_remaining/models/deliver_remaining_model.dart';
import 'package:odms/src/screens/home/invoice_list/controller/invoice_list_controller.dart';
import 'package:odms/src/screens/home/page_sate_definition.dart';
import 'package:odms/src/screens/home/product_list/cash_collection/to_send_cash_data_model.dart';
import 'package:http/http.dart' as http;
import 'package:odms/src/widgets/common_widgets_function.dart';

import '../../../../theme/text_scaler_theme.dart';
import '../../../../widgets/loading/loading_popup_widget.dart';
import '../../../../widgets/loading/loading_text_controller.dart';

class ProductListCashCollection extends StatefulWidget {
  final InvoiceList invoice;
  final String invoiceNo;
  final String totalAmount;
  final int index;
  const ProductListCashCollection({
    super.key,
    required this.invoice,
    required this.invoiceNo,
    required this.totalAmount,
    required this.index,
  });

  @override
  State<ProductListCashCollection> createState() =>
      _ProductListCashCollectionState();
}

class _ProductListCashCollectionState extends State<ProductListCashCollection> {
  final invoiceListController = Get.put(InvoiceListController());
  final LoadingTextController loadingTextController = Get.find();
  List<ProductList> productList = [];
  List<TextEditingController> receiveTextEditingControllerList = [];
  List<TextEditingController> returnTextEditingControllerList = [];
  TextEditingController receivedAmountController = TextEditingController();
  List<double> receiveAmountList = [];
  List<double> returnAmountList = [];
  double dueAmount = 0;
  final formKey = GlobalKey<FormState>();

  final DeliveryRemainingController deliveryRemainingController = Get.find();

  String pageType = '';
  @override
  void initState() {
    for (ProductList product in (widget.invoice.productList ?? [])) {
      productList.add(product);
    }

    for (int i = 0; i < productList.length; i++) {
      receiveTextEditingControllerList.add(TextEditingController());
      receiveAmountList.add(0);
      returnTextEditingControllerList.add(TextEditingController());
      returnAmountList.add(0);
    }

    dueAmount = double.parse(widget.totalAmount);
    pageType = deliveryRemainingController.pageType.value;
    receivedAmountController.text = dueAmount.toPrecision(2).toStringAsFixed(2);
    dueAmount = 0;
    super.initState();
  }

  Widget divider = const Divider(
    color: Colors.white,
    height: 1,
  );

  @override
  Widget build(BuildContext context) {
    double totalReturnAmount = 0;
    for (var e in returnAmountList) {
      totalReturnAmount += e;
    }
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScalerValue)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Product List',
          ),
          actions: pageType == pagesState[1]
              ? null
              : [
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(
                              Icons.close,
                              color: Colors.deepOrange,
                            ),
                            Gap(10),
                            Text('Deselect All'),
                          ],
                        ),
                        onTap: () {
                          onAllReturnClick();
                        },
                      ),
                    ],
                  )
                ],
        ),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: <Widget>[
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
                                widget.invoiceNo,
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
                                'Customer Name',
                                widget.invoice.customerName ?? '',
                              ),
                              divider,
                              getRowWidgetForDetailsBox(
                                'Customer Address',
                                widget.invoice.customerAddress ?? '',
                              ),
                              divider,
                              getRowWidgetForDetailsBox(
                                'Customer Mobile',
                                widget.invoice.customerMobile ?? '',
                                optionalWidgetsAtLast: SizedBox(
                                  height: 23,
                                  width: 50,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      FlutterClipboard.copy(
                                        widget.invoice.customerMobile ?? '',
                                      ).then((value) {
                                        Fluttertoast.showToast(
                                            msg: 'Number Copied');
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
                                'Gate Pass',
                                widget.invoice.gatePassNo ?? '',
                              ),
                              divider,
                              getRowWidgetForDetailsBox(
                                'Vehicle No',
                                widget.invoice.vehicleNo ?? '',
                              ),
                              divider,
                              getRowWidgetForDetailsBox(
                                'Total Amount',
                                double.parse(widget.totalAmount)
                                    .toPrecision(2)
                                    .toStringAsFixed(2),
                              ),
                              divider,
                              getRowWidgetForDetailsBox(
                                'Return Amount',
                                totalReturnAmount
                                    .toPrecision(2)
                                    .toStringAsFixed(2),
                              ),
                              divider,
                              getRowWidgetForDetailsBox(
                                'To pay',
                                calculateFloatValueWithHighPrecision(
                                  double.parse(widget.totalAmount),
                                  totalReturnAmount,
                                ).toPrecision(2).toStringAsFixed(2),
                              ),
                              divider,
                              getRowWidgetForDetailsBox(
                                'Due Amount',
                                calculateFloatValueWithHighPrecision(
                                        dueAmount, null)
                                    .toPrecision(2)
                                    .toStringAsFixed(2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!(deliveryRemainingController.pageType.value ==
                          pagesState[4] ||
                      deliveryRemainingController.pageType.value ==
                          pagesState[3]))
                    const Gap(15),
                  if (!(deliveryRemainingController.pageType.value ==
                          pagesState[4] ||
                      deliveryRemainingController.pageType.value ==
                          pagesState[3]))
                    const Text(
                      'Received amount',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (!(deliveryRemainingController.pageType.value ==
                          pagesState[4] ||
                      deliveryRemainingController.pageType.value ==
                          pagesState[3]))
                    const Gap(5),
                  if (!(deliveryRemainingController.pageType.value ==
                          pagesState[4] ||
                      deliveryRemainingController.pageType.value ==
                          pagesState[3]))
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: receivedAmountController,
                      validator: (value) {
                        value ??= '';
                        final x = double.tryParse(value);
                        if (x != null && x >= 0) {
                          final totalAmount =
                              calculateFloatValueWithHighPrecision(
                            double.parse(widget.totalAmount),
                            totalReturnAmount,
                          );
                          if (x > totalAmount) {
                            return "received amount can't beyond total amount";
                          }
                          return null;
                        } else {
                          return 'Not a valid number';
                        }
                      },
                      onChanged: (_) {
                        calculateDependOnReceivedAmount();
                      },
                      autovalidateMode: AutovalidateMode.always,
                      decoration: InputDecoration(
                        hintText: 'Receive amount',
                        labelText: 'Receive amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  const Gap(15),
                ] +
                List.generate(
                  productList.length,
                  (index) {
                    double perProduct =
                        ((productList[index].deliveryNetVal ?? 0)) /
                            (productList[index].deliveryQuantity ?? 0);
                    return Container(
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ID: ${productList[index].matnr}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const Gap(20),
                                    Text(
                                      'Batch: ${productList[index].batch}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Text(
                                        'Product Name: ',
                                        style: style,
                                      ),
                                      const Gap(5),
                                      Text(
                                        productList[index].materialName ?? '',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  height: 4,
                                  color: Colors.white,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Quantity : ',
                                      style: style,
                                    ),
                                    const Gap(5),
                                    Text(
                                      (productList[index].deliveryQuantity ?? 0)
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Invoice Amount : ',
                                      style: style,
                                    ),
                                    const Gap(5),
                                    Text(
                                      (perProduct *
                                              (productList[index]
                                                      .deliveryQuantity ??
                                                  0))
                                          .toStringAsFixed(2),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                if ((productList[index].returnQuantity ?? 0) >
                                    0)
                                  const Divider(
                                    height: 1,
                                    color: Colors.white,
                                  ),
                                if (((productList[index].returnQuantity ?? 0) >
                                        0) &&
                                    (pageType == pagesState[2] ||
                                        pageType == pagesState[3]))
                                  Row(
                                    children: [
                                      Text(
                                        'Return : ',
                                        style:
                                            style.copyWith(color: Colors.red),
                                      ),
                                      const Gap(5),
                                      Text(
                                        (productList[index].returnQuantity ?? 0)
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                if (!(deliveryRemainingController
                                                .pageType.value ==
                                            pagesState[4] ||
                                        deliveryRemainingController
                                                .pageType.value ==
                                            pagesState[3]) &&
                                    (((productList[index].quantity ?? 0) -
                                            (productList[index]
                                                    .returnQuantity ??
                                                0)) !=
                                        0))
                                  TextFormField(
                                    keyboardType: TextInputType.number,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if ((value ?? '') == '') return null;
                                      int? retQuantity =
                                          int.tryParse(value ?? '');
                                      if (retQuantity != null &&
                                          retQuantity >= 0) {
                                        if (retQuantity >
                                            (productList[index]
                                                    .deliveryQuantity ??
                                                0)) {
                                          return 'Not valid';
                                        }

                                        return null;
                                      } else {
                                        return 'Not a valid digit';
                                      }
                                    },
                                    onChanged: (value) {
                                      if (value.isEmpty) value = '0';
                                      int? retQuantity = int.tryParse(value);
                                      if (retQuantity != null) {
                                        int? recQuantity = int.tryParse(
                                            receiveTextEditingControllerList[
                                                    index]
                                                .text);
                                        recQuantity ??= 0;
                                        int totalQuantity = recQuantity;
                                        if (totalQuantity !=
                                            (productList[index].quantity ??
                                                0)) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            setState(() {
                                              receiveAmountList[index] = 0;
                                            });
                                          });
                                        }
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          setState(() {
                                            returnAmountList[index] =
                                                perProduct * retQuantity;
                                            receiveAmountList[index] =
                                                perProduct * (recQuantity ?? 0);
                                          });

                                          calculateDependOnReceivedAmount();
                                        });
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          double returnAmountTem = 0;
                                          for (int i = 0;
                                              i < returnAmountList.length;
                                              i++) {
                                            returnAmountTem +=
                                                returnAmountList[i];
                                          }
                                          setState(() {
                                            totalReturnAmount = returnAmountTem;
                                            dueAmount = double.parse(
                                                    widget.totalAmount) -
                                                totalReturnAmount;
                                            receivedAmountController.text =
                                                dueAmount
                                                    .toPrecision(2)
                                                    .toStringAsFixed(2);
                                          });
                                        });
                                      } else {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          setState(() {
                                            receiveAmountList[index] = 0;
                                          });
                                        });
                                      }
                                    },
                                    controller:
                                        returnTextEditingControllerList[index],
                                    decoration: InputDecoration(
                                      hintText: 'Return Qty.',
                                      labelText: 'Return Qty.',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                const Gap(5),
                                if (deliveryRemainingController
                                        .pageType.value ==
                                    pagesState[4])
                                  Text(
                                    'Return Qty. : ${(productList[index].quantity ?? 0).toInt()}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                // if (deliveryRemainingController.pageType.value ==
                                //     "Cash Collection Done")
                                //   Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       Text(
                                //         "Received Qty. : ${(productList[index].deliveryQuantity ?? 0).toInt()}",
                                //         style: TextStyle(
                                //           fontSize: 16,
                                //           fontWeight: FontWeight.bold,
                                //           color: Colors.green.shade900,
                                //         ),
                                //       ),
                                //       Text(
                                //         "Received Amount. : ${(productList[index].deliveryNetVal ?? 0) * (productList[index].deliveryQuantity ?? 0)}",
                                //         style: TextStyle(
                                //           fontSize: 16,
                                //           fontWeight: FontWeight.bold,
                                //           color: Colors.green.shade900,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                //   if (deliveryRemainingController.pageType.value ==
                                //       "Cash Collection Done")
                                //     const Divider(),
                                //   if (deliveryRemainingController.pageType.value ==
                                //       "Cash Collection Done")
                                //     Row(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.spaceBetween,
                                //       children: [
                                //         Text(
                                //           "Return Qty. : ${(productList[index].returnQuantity ?? 0).toInt()}",
                                //           style: TextStyle(
                                //             fontSize: 16,
                                //             fontWeight: FontWeight.bold,
                                //             color: Colors.red.shade800,
                                //           ),
                                //         ),
                                //         Text(
                                //           "Return Amount. : ${(productList[index].returnNetVal ?? 0) * (productList[index].returnQuantity ?? 0)}",
                                //           style: TextStyle(
                                //             fontSize: 16,
                                //             fontWeight: FontWeight.bold,
                                //             color: Colors.red.shade800,
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   if (deliveryRemainingController.pageType.value ==
                                //       "Cash Collection Done")
                                //     Row(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.spaceBetween,
                                //       children: [
                                //         if (!(deliveryRemainingController
                                //                     .pageType.value ==
                                //                 "Return" ||
                                //             deliveryRemainingController
                                //                     .pageType.value ==
                                //                 "Cash Collection Done"))
                                //           Text(
                                //             "Rec. Amount :  ${receiveAmountList[index].toStringAsFixed(2)}",
                                //             style: style.copyWith(
                                //               fontWeight: FontWeight.w500,
                                //             ),
                                //           ),
                                //         if (!(deliveryRemainingController
                                //                     .pageType.value ==
                                //                 "Return" ||
                                //             deliveryRemainingController
                                //                     .pageType.value ==
                                //                 "Cash Collection Done"))
                                //           Text(
                                //             "Ret. Amount :  ${returnAmountList[index].toStringAsFixed(2)}",
                                //             style: style.copyWith(
                                //               fontWeight: FontWeight.w500,
                                //             ),
                                //           ),
                                //       ],
                                //     ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ) +
                <Widget>[
                  if (!(pageType == pagesState[1])) const Gap(30),
                  if ((!(pageType == pagesState[1])) &&
                      pageType != pagesState[3] &&
                      pageType != pagesState[4])
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Cancel'),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: ElevatedButton(
                            onPressed: () async {
                              await onCashCollectedButtonPressed(
                                  context, totalReturnAmount);
                            },
                            child: const Text('Cash Collected'),
                          ),
                        ),
                      ],
                    ),
                ],
          ),
        ),
      ),
    );
  }

  void onAllReturnClick() {
    for (var index = 0; index < productList.length; index++) {
      ProductList current = productList[index];
      double perProduct = ((current.netVal ?? 0) + (current.vat ?? 0)) /
          (current.quantity ?? 0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        returnTextEditingControllerList[index].text =
            (current.deliveryQuantity ?? 0).toInt().toString();
        receiveTextEditingControllerList[index].text = '0';
      });
      log((current.deliveryQuantity ?? 0).toInt().toString());
      returnAmountList[index] = (current.deliveryQuantity ?? 0) * perProduct;
      receiveAmountList[index] = 0;
    }
    setState(() {
      dueAmount = 0;
      receivedAmountController.text = 0.toString();
    });
  }

  Future<void> onCashCollectedButtonPressed(
      BuildContext context, double totalReturnAmount) async {
    String receivedAmount = receivedAmountController.text;
    bool isValidate = false;
    final x = double.tryParse(receivedAmount);
    if (x != null) {
      final totalAmount = calculateFloatValueWithHighPrecision(
          double.parse(widget.totalAmount), totalReturnAmount);
      log(totalAmount.toString());
      if (x > totalAmount) {
        isValidate = false;
      } else {
        isValidate = true;
      }
    } else {
      isValidate = false;
    }
    if (isValidate == false) {
      Fluttertoast.showToast(
        msg: 'Received amount is not valid',
      );
    }

    if (formKey.currentState!.validate() && isValidate) {
      loadingTextController.currentState.value = 0;
      loadingTextController.loadingText.value =
          'Accessing Your Location\nPlease wait...';

      showCustomPopUpLoadingDialog(context, isCupertino: true);
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings:
              AndroidSettings(timeLimit: const Duration(seconds: 30)),
        );
        List<DeliveryCash> listOfDeliveryCash = [];
        for (int i = 0; i < productList.length; i++) {
          final e = productList[i];
          String returnText = returnTextEditingControllerList[i].text.trim();
          if (returnText.isEmpty) returnText = '0';
          // final unitVat = (e.vat ?? 0) / (e.quantity!);
          final returnQty =
              int.parse(returnText) + (e.returnQuantity ?? 0).toInt();
          listOfDeliveryCash.add(DeliveryCash(
            id: e.matnr,
            returnQuantity: returnQty,
            // vat: (e.vat ?? 0) * int.parse(returnText),
            batch: e.batch,
          ));
        }
        final toSendCashDataModel = ToSendCashDataModel(
          billingDocNo: widget.invoice.billingDocNo,
          lastStatus: 'cash_collection',
          type: 'cash_collection',
          billingDate: widget.invoice.billingDate == null
              ? null
              : DateFormat('yyyy-MM-dd').format(widget.invoice.billingDate!),
          daCode: widget.invoice.daCode?.toInt().toString(),
          gatePassNo: widget.invoice.gatePassNo,
          partner: widget.invoice.partner,
          routeCode: widget.invoice.routeCode,
          cashCollection: double.tryParse(receivedAmountController.text),
          cashCollectionLatitude: position.latitude.toString(),
          cashCollectionLongitude: position.longitude.toString(),
          cashCollectionStatus: 'Done',
          delivers: listOfDeliveryCash,
        );

        if (kDebugMode) {
          log('Sending to api: ');
          log(toSendCashDataModel.toJson());
        }
        loadingTextController.loadingText.value =
            'Your Location Accessed\nSending data to server\nPlease wait...';

        final uri = Uri.parse("$base$cashCollectionSave/${widget.invoice.id}");
        final response = await http.put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: toSendCashDataModel.toJson(),
        );
        if (kDebugMode) {
          log("$base$cashCollectionSave/${widget.invoice.id}");
          log('received form api: ');
          log(response.body);
        }
        if (kDebugMode) {
          log(response.statusCode.toString());
        }

        if (response.statusCode == 200) {
          final decoded = Map<String, dynamic>.from(jsonDecode(response.body));
          if (decoded['success'] == true) {
            log('Awaiting a 1 second');
            await Future.delayed(Duration(seconds: 1));
            log('done awaiting a 1 second');
            try {
              final box = Hive.box('info');
              final url = Uri.parse(
                "$base${(pageType == pagesState[0] || pageType == pagesState[1]) ? getDeliveryList : cashCollectionList}/${box.get('sap_id')}?type=${(pageType == pagesState[1] ? "Done" : "Remaining")}&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
              );

              final response = await http.get(url);

              if (response.statusCode == 200) {
                if (kDebugMode) {
                  print('Got Delivery Remaining List');
                  print(response.body);
                }

                final controller = Get.put(
                  DeliveryRemainingController(
                    DeliveryRemaining.fromJson(response.body),
                  ),
                );
                controller.deliveryRemaining.value =
                    DeliveryRemaining.fromJson(response.body);
                controller.constDeliveryRemaining.value =
                    DeliveryRemaining.fromJson(response.body);
                controller.deliveryRemaining.value.result ??= [];
                controller.constDeliveryRemaining.value.result ??= [];
              }
            } catch (e) {
              log(e.toString());
            }
            loadingTextController.currentState.value = 0;
            loadingTextController.loadingText.value = 'Successful';
            invoiceListController.invoiceList.removeAt(
              widget.index,
            );
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            Get.back();
          } else {
            loadingTextController.currentState.value = -1;
            loadingTextController.loadingText.value = decoded['message'];
          }
        } else {
          loadingTextController.currentState.value = -1;
          loadingTextController.loadingText.value =
              'Something went wrong with ${response.statusCode}';
        }
      } catch (e) {
        loadingTextController.currentState.value = -1;
        loadingTextController.loadingText.value =
            'Unable to access your location';
      }
    }
  }

  TextStyle style = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);

  TextStyle topContainerTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  void calculateDependOnReceivedAmount() {
    String receivedText = receivedAmountController.text;
    if (receivedText.isEmpty) receivedText = '0';
    double? receivedAmount = double.tryParse(receivedText);
    if (receivedAmount != null) {
      double totalAmountPrevious = double.parse(widget.totalAmount);
      double returnAmountNow = 0;
      for (double returnAmount in returnAmountList) {
        returnAmountNow += returnAmount;
      }

      dueAmount = (totalAmountPrevious - (returnAmountNow + receivedAmount))
          .toPrecision(2);

      if (dueAmount < 0) {
        dueAmount = totalAmountPrevious - returnAmountNow;
      }
      setState(() {
        dueAmount;
      });
    }
  }

  double calculateFloatValueWithHighPrecision(double x, double? y) {
    double res = x - (y ?? 0);
    // print(res);
    // if (res < 0) {
    res = res.toPrecision(2);
    // }
    return res;
  }
}
