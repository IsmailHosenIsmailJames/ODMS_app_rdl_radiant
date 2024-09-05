import 'dart:convert';
import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:rdl_radiant/src/apis/apis.dart';
import 'package:rdl_radiant/src/screens/home/delivary_ramaining/controller/delivery_remaning_controller.dart';
import 'package:rdl_radiant/src/screens/home/delivary_ramaining/models/deliver_remaing_model.dart';
import 'package:rdl_radiant/src/screens/home/invoice_list/controller/invoice_list_controller.dart';
import 'package:rdl_radiant/src/screens/home/product_list/cash_collection/to_send_cash_data_model.dart';
import 'package:http/http.dart' as http;

class ProductListCashCollection extends StatefulWidget {
  final InvoiceList invoice;
  final String invioceNo;
  final String totalAmount;
  final int index;
  const ProductListCashCollection({
    super.key,
    required this.invoice,
    required this.invioceNo,
    required this.totalAmount,
    required this.index,
  });

  @override
  State<ProductListCashCollection> createState() =>
      _ProductListCashCollectionState();
}

class _ProductListCashCollectionState extends State<ProductListCashCollection> {
  final invoiceListController = Get.put(InvoiceListController());
  late List<ProductList> productList;
  List<TextEditingController> receiveTextEditingControllerList = [];
  List<TextEditingController> returnTextEditingControllerList = [];
  TextEditingController receivedAmmountController = TextEditingController();
  List<double> receiveAmountList = [];
  List<double> returnAmountList = [];
  double dueAmmount = 0;
  final formKey = GlobalKey<FormState>();

  final DeliveryRemaningController deliveryRemaningController = Get.find();

  bool isDataForDeliveryDone = false;

  @override
  void initState() {
    productList = widget.invoice.productList ?? [];
    for (int i = 0; i < productList.length; i++) {
      receiveTextEditingControllerList.add(TextEditingController());
      receiveAmountList.add(0);
      returnTextEditingControllerList.add(TextEditingController());
      returnAmountList.add(0);
    }
    isDataForDeliveryDone =
        deliveryRemaningController.isDataForDeliveryDone.value;

    dueAmmount = double.parse(widget.totalAmount);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double totalRetrunAmmount = 0;
    for (var e in returnAmountList) {
      totalRetrunAmmount += e;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Product List",
        ),
        actions: isDataForDeliveryDone
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
                            receiveTextEditingControllerList[index].text = '0';
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
                                      widget.invoice.customerName ?? "",
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
                                      widget.invoice.customerAddress ?? "",
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.invoice.customerMobile ?? "",
                                          style: topContainerTextStyle,
                                        ),
                                        SizedBox(
                                          height: 23,
                                          width: 90,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              FlutterClipboard.copy(
                                                widget.invoice.customerMobile ??
                                                    "",
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
                                    child: Text(
                                      widget.invoice.gatePassNo ?? "",
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
                                      "Vehicle No",
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
                                      widget.invoice.vehicleNo ?? "",
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
                                      "Return Amount",
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
                                      totalRetrunAmmount.toStringAsFixed(2),
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
                                      "Due Amount",
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
                                      (dueAmmount - totalRetrunAmmount)
                                          .toStringAsFixed(2),
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
                const Text(
                  "Received ammount",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(5),
                TextFormField(
                  controller: receivedAmmountController,
                  validator: (value) {
                    final x = double.tryParse(value ?? "");
                    if (x != null) {
                      final totalAmount =
                          double.parse(widget.totalAmount) - totalRetrunAmmount;
                      if (x > totalAmount) {
                        return "received amount can't beyond total ammount";
                      }
                      return null;
                    } else {
                      return "Not a valid number";
                    }
                  },
                  onChanged: (value) {
                    final x = double.tryParse(value);
                    if (x != null) {
                      final totalAmount =
                          double.parse(widget.totalAmount) - totalRetrunAmmount;
                      if (x <= totalAmount) {
                        setState(() {
                          dueAmmount = double.parse(widget.totalAmount) -
                              x -
                              totalRetrunAmmount;
                        });
                        return;
                      }
                    } else {
                      setState(() {
                        dueAmmount = dueAmmount =
                            double.parse(widget.totalAmount) -
                                totalRetrunAmmount;
                      });
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: "Receive ammount",
                    labelText: "Receive ammount",
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
                              Row(
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
                              if (isDataForDeliveryDone) const Gap(10),
                              if (isDataForDeliveryDone)
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
                              if (isDataForDeliveryDone) const Divider(),
                              if (!isDataForDeliveryDone)
                                TextFormField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if ((value ?? "") == "") return null;
                                    int? retQuentaty =
                                        int.tryParse(value ?? "");
                                    if (retQuentaty != null) {
                                      if (retQuentaty >
                                          (productList[index].quantity ?? 0)) {
                                        Fluttertoast.cancel().then(
                                          (value) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Ensure that the receive & return quantity does not exceed with specified quantity in invoice");
                                          },
                                        );

                                        return "Not valid";
                                      }

                                      return null;
                                    } else {
                                      return "Not a valid digit";
                                    }
                                  },
                                  onChanged: (value) {
                                    int? retQuentaty = int.tryParse(value);
                                    if (retQuentaty != null) {
                                      int? recQuentaty = int.tryParse(
                                          receiveTextEditingControllerList[
                                                  index]
                                              .text);
                                      recQuentaty ??= 0;
                                      int totalQuentaty =
                                          retQuentaty + recQuentaty;
                                      if (totalQuentaty !=
                                          (productList[index].quantity ?? 0)) {
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
                                              perProduct * retQuentaty;
                                          receiveAmountList[index] =
                                              perProduct * (recQuentaty ?? 0);
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
                                    hintText: "Return Qty.",
                                    labelText: "Return Qty.",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              const Gap(5),
                              if (!isDataForDeliveryDone)
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
                              if (isDataForDeliveryDone)
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
                if (!isDataForDeliveryDone) const Gap(30),
                if (!isDataForDeliveryDone)
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
                            if (formKey.currentState!.validate()) {
                              showCupertinoModalPopup(
                                context: context,
                                builder: (context) => Scaffold(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.1),
                                  body: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color.fromARGB(255, 74, 174, 255),
                                    ),
                                  ),
                                ),
                              );
                              final position =
                                  await Geolocator.getCurrentPosition();
                              //       deliveryDetailsM.billing_doc_no,
                              // last_status = "cash_collection",
                              // type = "cash_collection",
                              // cash_collection = cashCollection,
                              // cash_collection_latitude = latitude.toString(),
                              // cash_collection_longitude = longitude.toString(),
                              // cash_collection_status = "Done",
                              // deliverys = cashCollectionList

                              List<DeliveryCash> listOfDeliveryCash = [];
                              for (int i = 0; i < productList.length; i++) {
                                final e = productList[i];
                                String returnText =
                                    returnTextEditingControllerList[i]
                                        .text
                                        .trim();
                                if (returnText.isEmpty) returnText = "0";
                                listOfDeliveryCash.add(DeliveryCash(
                                  id: int.parse("${productList[i].id}"),
                                  returnNetVal:
                                      (((e.netVal ?? 0) + (e.vat ?? 0)) /
                                              (productList[i].quantity ?? 0)
                                                  .toInt()) *
                                          int.parse(returnText),
                                  returnQuantity: int.parse(returnText),
                                  vat: e.vat,
                                ));
                              }

                              final toSendCashDataModel = ToSendCashDataModel(
                                billingDocNo: widget.invoice.billingDocNo,
                                lastStatus: "cash_collection",
                                type: "cash_collection",
                                cashCollection: double.tryParse(
                                    receivedAmmountController.text),
                                cashCollectionLatitude:
                                    position.latitude.toString(),
                                cashCollectionLongitude:
                                    position.longitude.toString(),
                                cashCollectionStatus: "Done",
                                deliverys: listOfDeliveryCash,
                              );

                              if (kDebugMode) {
                                log(toSendCashDataModel.toJson());
                              }
                              final box = Hive.box('info');

                              final uri = Uri.parse(
                                  "$base$cashCollectionSave/${box.get('sap_id')}");
                              final response = await http.put(
                                uri,
                                headers: {"Content-Type": "application/json"},
                                body: toSendCashDataModel.toJson(),
                              );
                              if (kDebugMode) {
                                print(response.body);
                              }
                              if (kDebugMode) {
                                log(response.statusCode.toString());
                              }

                              if (response.statusCode == 200) {
                                final decoded = Map<String, dynamic>.from(
                                    jsonDecode(response.body));
                                if (decoded['success'] == true) {
                                  invoiceListController.invoiceList.removeAt(
                                    widget.index,
                                  );
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
                                  Get.back();
                                }
                              }
                            }
                          },
                          child: const Text("Cash Collected"),
                        ),
                      ),
                    ],
                  ),
              ],
        ),
      ),
    );
  }

  TextStyle style = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);

  TextStyle topContainerTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
