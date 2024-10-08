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
import 'package:rdl_radiant/src/apis/apis.dart';
import 'package:rdl_radiant/src/screens/home/delivary_ramaining/controller/delivery_remaning_controller.dart';
import 'package:rdl_radiant/src/screens/home/delivary_ramaining/models/deliver_remaing_model.dart';
import 'package:rdl_radiant/src/screens/home/invoice_list/controller/invoice_list_controller.dart';
import 'package:rdl_radiant/src/screens/home/page_sate_defination.dart';
import 'package:rdl_radiant/src/screens/home/product_list/models/delivery_data.dart';
import 'package:http/http.dart' as http;
import 'package:rdl_radiant/src/widgets/coomon_widgets_function.dart';

import '../../../theme/text_scaler_theme.dart';
import '../../../widgets/loading/loading_popup_widget.dart';
import '../../../widgets/loading/loading_text_controller.dart';

class ProdouctListPage extends StatefulWidget {
  final DateTime? dateOfDelivery;
  final InvoiceList invoice;
  final String invioceNo;
  final String totalAmount;
  final int index;
  const ProdouctListPage({
    super.key,
    required this.invoice,
    required this.invioceNo,
    required this.totalAmount,
    required this.index,
    this.dateOfDelivery,
  });

  @override
  State<ProdouctListPage> createState() => _ProdouctListPageState();
}

class _ProdouctListPageState extends State<ProdouctListPage> {
  final invoiceListController = Get.put(InvoiceListController());
  final LoadingTextController loadingTextController = Get.find();

  late List<ProductList> productList;
  List<TextEditingController> receiveTextEditingControllerList = [];
  List<TextEditingController> returnTextEditingControllerList = [];
  List<double> receiveAmountList = [];
  List<double> returnAmountList = [];
  final formKey = GlobalKey<FormState>();

  final DeliveryRemaningController deliveryRemaningController = Get.find();

  String pageType = '';

  @override
  void initState() {
    productList = widget.invoice.productList ?? [];
    for (int i = 0; i < productList.length; i++) {
      receiveTextEditingControllerList.add(TextEditingController());
      receiveAmountList.add(0);
      returnTextEditingControllerList.add(TextEditingController());
      returnAmountList.add(0);
    }
    pageType = deliveryRemaningController.pageType.value;

    super.initState();
  }

  Widget divider = const Divider(
    color: Colors.white,
    height: 1,
  );

  @override
  Widget build(BuildContext context) {
    bool isDeliveryForToday = true;
    if (widget.dateOfDelivery != null) {
      DateTime now = DateTime.now();
      DateTime dateOfDelivery = widget.dateOfDelivery!;
      if (dateOfDelivery.day != now.day ||
          dateOfDelivery.month != now.month ||
          dateOfDelivery.year != now.year) {
        isDeliveryForToday = false;
      }
    }
    double totalReceiveAmmount = 0;
    for (var e in receiveAmountList) {
      totalReceiveAmmount += e;
    }
    double totalRetrunAmmount = 0;
    for (var e in returnAmountList) {
      totalRetrunAmmount += e;
    }
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScalerValue)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "$pageType Product List",
            style: const TextStyle(fontSize: 20),
          ),
          actions: pageType == pagesState[1]
              ? null
              : [
                  if (isDeliveryForToday)
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(
                                Icons.done_all,
                                color: Colors.green,
                              ),
                              Gap(10),
                              Text("All Received"),
                            ],
                          ),
                          onTap: () {
                            for (var index = 0;
                                index < productList.length;
                                index++) {
                              ProductList current = productList[index];
                              double perProduct =
                                  ((current.netVal ?? 0) + (current.vat ?? 0)) /
                                      (current.quantity ?? 0);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                receiveTextEditingControllerList[index].text =
                                    (current.quantity ?? 0).toInt().toString();
                                returnTextEditingControllerList[index].text =
                                    '0';
                              });
                              receiveAmountList[index] =
                                  (current.quantity ?? 0) * perProduct;
                              returnAmountList[index] = 0;
                            }
                            setState(() {});
                          },
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(
                                Icons.close,
                                color: Colors.deepOrange,
                              ),
                              Gap(10),
                              Text("All Return"),
                            ],
                          ),
                          onTap: () {
                            for (var index = 0;
                                index < productList.length;
                                index++) {
                              ProductList current = productList[index];
                              double perProduct =
                                  ((current.netVal ?? 0) + (current.vat ?? 0)) /
                                      (current.quantity ?? 0);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                returnTextEditingControllerList[index].text =
                                    (current.quantity ?? 0).toInt().toString();
                                receiveTextEditingControllerList[index].text =
                                    '0';
                              });
                              returnAmountList[index] =
                                  (current.quantity ?? 0) * perProduct;
                              receiveAmountList[index] = 0;
                            }
                            setState(() {});
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
                                widget.invioceNo,
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
                                "Coustomer Name",
                                widget.invoice.customerName ?? "",
                              ),
                              divider,
                              getRowWidgetForDetailsBox(
                                "Coustomer Address",
                                widget.invoice.customerAddress ?? "",
                              ),
                              divider,
                              getRowWidgetForDetailsBox(
                                "Coustomer Mobile",
                                widget.invoice.customerMobile ?? "",
                                optionalWidgetsAtLast: SizedBox(
                                  height: 23,
                                  width: 50,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      FlutterClipboard.copy(
                                        widget.invoice.customerMobile ?? "",
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
                              ),
                              divider,
                              getRowWidgetForDetailsBox(
                                "Gate Pass",
                                widget.invoice.gatePassNo ?? "",
                              ),
                              divider,
                              getRowWidgetForDetailsBox(
                                "Vehicle No",
                                widget.invoice.vehicleNo ?? "",
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
                ] +
                List.generate(
                  productList.length,
                  (index) {
                    double perProduct = ((productList[index].netVal ?? 0) +
                            (productList[index].vat ?? 0)) /
                        (productList[index].quantity ?? 0);
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
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Text(
                                        "Product Name: ",
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
                                      "Quantity : ",
                                      style: style,
                                    ),
                                    const Gap(5),
                                    Text(
                                      (productList[index].quantity ?? 0)
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "Invoice Amount : ",
                                      style: style,
                                    ),
                                    const Gap(5),
                                    Text(
                                      ((productList[index].vat ?? 0) +
                                              (productList[index].netVal ?? 0))
                                          .toStringAsFixed(2),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade800,
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
                                if (pageType == pagesState[1]) const Gap(10),
                                if (pageType == pagesState[1])
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Delivered Quantity: ${(productList[index].deliveryQuantity ?? 0).toInt().toString()}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "Delivered Returned: ${(productList[index].returnQuantity ?? 0).toInt().toString()}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                if (pageType == pagesState[1]) const Divider(),
                                if (!(pageType == pagesState[1]) &&
                                    isDeliveryForToday &&
                                    pageType != pagesState[5])
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            value ??= "";
                                            if (value.isEmpty) value = "0";
                                            int? recQuentaty =
                                                int.tryParse(value);
                                            if (recQuentaty != null) {
                                              int? retQuentaty = int.tryParse(
                                                  returnTextEditingControllerList[
                                                          index]
                                                      .text);
                                              retQuentaty ??= 0;
                                              int totalQuentaty =
                                                  recQuentaty + retQuentaty;
                                              if (totalQuentaty !=
                                                  (productList[index]
                                                          .quantity ??
                                                      0)) {
                                                return "Not valid";
                                              }

                                              return null;
                                            } else {
                                              return "Not a valid digit";
                                            }
                                          },
                                          onChanged: (value) {
                                            newRecivedQtyTextFieldChange(
                                              value,
                                              index,
                                              perProduct,
                                              (productList[index].quantity ?? 0)
                                                  .toInt(),
                                            );
                                          },
                                          controller:
                                              receiveTextEditingControllerList[
                                                  index],
                                          decoration: InputDecoration(
                                            hintText: "Received Qty.",
                                            labelText: "Received Qty.",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Gap(20),
                                      Expanded(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            value ??= "";
                                            if (value.isEmpty) value = "0";
                                            int? retQuentaty =
                                                int.tryParse(value);
                                            if (retQuentaty != null) {
                                              int? recQuentaty = int.tryParse(
                                                  receiveTextEditingControllerList[
                                                          index]
                                                      .text);
                                              recQuentaty ??= 0;
                                              int totalQuentaty =
                                                  retQuentaty + recQuentaty;
                                              if (totalQuentaty !=
                                                  (productList[index]
                                                          .quantity ??
                                                      0)) {
                                                return "Not valid";
                                              }

                                              return null;
                                            } else {
                                              return "Not a valid digit";
                                            }
                                          },
                                          onChanged: (value) {
                                            onRetQtyTextfieldChange(
                                              value,
                                              index,
                                              perProduct,
                                              (productList[index].quantity ?? 0)
                                                  .toInt(),
                                            );
                                          },
                                          controller:
                                              returnTextEditingControllerList[
                                                  index],
                                          decoration: InputDecoration(
                                            hintText: "Return Qty.",
                                            labelText: "Return Qty.",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (isDeliveryForToday) const Gap(5),
                                if (!(pageType == pagesState[1]) &&
                                    isDeliveryForToday &&
                                    pageType != pagesState[5])
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Rec. Amount :  ${receiveAmountList[index].toStringAsFixed(2)}",
                                        style: style.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "Ret. Amount :  ${returnAmountList[index].toStringAsFixed(2)}",
                                        style: style.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                if ((pageType == pagesState[1]) &&
                                    isDeliveryForToday)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Rec. Amount :  ${(productList[index].deliveryNetVal ?? 0).toStringAsFixed(2)}",
                                        style: style.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "Ret. Amount :  ${(productList[index].returnNetVal ?? 0).toStringAsFixed(2)}",
                                        style: style.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ) +
                <Widget>[
                  if (!(pageType == pagesState[1])) const Gap(20),
                  if (!(pageType == pagesState[1]) && isDeliveryForToday)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(100),
                              bottomLeft: Radius.circular(100),
                            ),
                            color: Colors.blue.shade200,
                          ),
                          width: MediaQuery.of(context).size.width * .45,
                          height: 40,
                          child: Center(
                            child: Text(
                                "Total Rec.: ${totalReceiveAmmount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(100),
                              bottomRight: Radius.circular(100),
                            ),
                            color: Colors.red.shade200,
                          ),
                          width: MediaQuery.of(context).size.width * .45,
                          height: 40,
                          child: Center(
                            child: Text(
                              "Total Ret.: ${totalRetrunAmmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (!(pageType == pagesState[1])) const Gap(30),
                  if (!(pageType == pagesState[1]) && isDeliveryForToday)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text("Cancel"),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: ElevatedButton(
                            onPressed: () async {
                              await onDeliveredButtonPressed(context);
                            },
                            child: const Text("Delivered"),
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

  void onRetQtyTextfieldChange(
    String value,
    int index,
    double perProduct,
    int realQty,
  ) {
    if (value.isEmpty) value = "0";
    int? retQuentaty = int.tryParse(value);
    if (retQuentaty != null) {
      int? recQuentaty =
          int.tryParse(receiveTextEditingControllerList[index].text);
      recQuentaty ??= 0;
      int totalQuentaty = retQuentaty + recQuentaty;
      if (totalQuentaty != (productList[index].quantity ?? 0)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            receiveAmountList[index] = 0;
          });
        });
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          returnAmountList[index] = perProduct * retQuentaty;
          receiveAmountList[index] = perProduct * (recQuentaty ?? 0);
        });
      });
      int autoReceviedQty = realQty - retQuentaty;
      if (autoReceviedQty >= 0) {
        if (recQuentaty != autoReceviedQty) {
          receiveTextEditingControllerList[index].text =
              autoReceviedQty.toString();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              receiveAmountList[index] = perProduct * autoReceviedQty;
            });
          });
        }
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          receiveAmountList[index] = 0;
        });
      });
    }
  }

  void newRecivedQtyTextFieldChange(
    String value,
    int index,
    double perProduct,
    int realQty,
  ) {
    if (value.isEmpty) value = "0";
    int? recQuentaty = int.tryParse(value);
    if (recQuentaty != null) {
      int? retQuentaty =
          int.tryParse(returnTextEditingControllerList[index].text);
      retQuentaty ??= 0;
      int totalQuentaty = recQuentaty + retQuentaty;
      if (totalQuentaty != (productList[index].quantity ?? 0)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            receiveAmountList[index] = 0;
          });
        });
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          returnAmountList[index] = perProduct * (retQuentaty ?? 0);
          receiveAmountList[index] = perProduct * recQuentaty;
        });
      });
      int autoRetQty = realQty - recQuentaty;
      if (autoRetQty >= 0) {
        if (retQuentaty != autoRetQty) {
          returnTextEditingControllerList[index].text = autoRetQty.toString();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              returnAmountList[index] = perProduct * autoRetQty;
            });
          });
        }
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          receiveAmountList[index] = 0;
        });
      });
    }
  }

  Future<void> onDeliveredButtonPressed(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      loadingTextController.currentState.value = 0;
      loadingTextController.loadingText.value =
          'Accessing Your Location\nPlease wait...';

      showCoustomPopUpLoadingDialog(context, isCuputino: true);

      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings:
              AndroidSettings(timeLimit: const Duration(seconds: 30)),
        );

        List<Delivery> listOfDelivery = [];
        for (int i = 0; i < productList.length; i++) {
          final e = productList[i];
          String returnText = returnTextEditingControllerList[i].text.trim();
          String receiveText = receiveTextEditingControllerList[i].text;
          if (returnText.isEmpty) returnText = "0";
          if (receiveText.isEmpty) receiveText = "0";
          listOfDelivery.add(
            Delivery(
              matnr: e.matnr,
              batch: e.batch,
              quantity: (productList[i].quantity ?? 0).toInt(),
              tp: e.tp,
              vat: e.vat,
              netVal: e.netVal,
              deliveryQuantity: int.parse(receiveText),
              deliveryNetVal: (((e.netVal ?? 0) + (e.vat ?? 0)) /
                      (productList[i].quantity ?? 0).toInt()) *
                  int.parse(receiveText),
              returnQuantity: int.parse(returnText),
              returnNetVal: (((e.netVal ?? 0) + (e.vat ?? 0)) /
                      (productList[i].quantity ?? 0).toInt()) *
                  int.parse(returnText),
              id: e.id,
            ),
          );
        }

        final deliveryData = DeliveryData(
          billingDocNo: widget.invoice.billingDocNo,
          billingDate:
              DateFormat('yyyy-MM-dd').format(widget.invoice.billingDate!),
          routeCode: widget.invoice.routeCode,
          partner: widget.invoice.partner,
          gatePassNo: widget.invoice.gatePassNo,
          daCode: (widget.invoice.daCode ?? 0).toInt().toString(),
          vehicleNo: widget.invoice.vehicleNo,
          deliveryLatitude: position.latitude.toString(),
          deliveryLongitude: position.longitude.toString(),
          transportType: widget.invoice.transportType,
          deliveryStatus: 'Done',
          lastStatus: "delivery",
          type: "delivery",
          cashCollection: 0.00,
          cashCollectionLatitude: null,
          cashCollectionLongitude: null,
          cashCollectionStatus: null,
          deliverys: listOfDelivery,
        );
        loadingTextController.loadingText.value =
            'Your Location Accessed\nSending data to server\nPlease wait...';
        final uri = Uri.parse(base + saveDeliveryList);
        log("Attempting to post ${deliveryData.toJson()}");
        final response = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: deliveryData.toJson(),
        );
        log("Successfull post : ${response.statusCode}");
        log("Got response data :${response.body}");

        if (response.statusCode == 200) {
          final decoded = Map<String, dynamic>.from(jsonDecode(response.body));
          if (decoded['success'] == true) {
            try {
              final box = Hive.box('info');
              final url = Uri.parse(
                "$base${(pageType == pagesState[0] || pageType == pagesState[1]) ? getDelivaryList : cashCollectionList}/${box.get('sap_id')}?type=${(pageType == pagesState[1] ? "Done" : "Remaining")}&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
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
            } catch (e) {
              log(e.toString());
            }
            loadingTextController.currentState.value = 0;
            loadingTextController.loadingText.value = 'Successful';
            invoiceListController.invoiceList.removeAt(
              widget.index,
            );
            await Future.delayed(const Duration(milliseconds: 100));
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
              'Something went worng with ${response.statusCode}';
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
}
