import 'package:bottom_picker/bottom_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:rdl_radiant/src/screens/home/delivary_ramaining/models/deliver_remaing_model.dart';
import 'package:http/http.dart' as http;
import 'package:rdl_radiant/src/screens/home/invoice_list/invoice_list_page.dart';

import '../../../apis/apis.dart';

class DeliveryRemainingPage extends StatefulWidget {
  final DeliveryRemaing deliveryRemaing;
  const DeliveryRemainingPage({super.key, required this.deliveryRemaing});

  @override
  State<DeliveryRemainingPage> createState() => _DeliveryRemainingPageState();
}

class _DeliveryRemainingPageState extends State<DeliveryRemainingPage> {
  List<Result> listOfReamingDelivery = [];
  late DeliveryRemaing deliveryRemaing;
  late List<Result> constListOfReamingDelivery = [];
  DateTime dateTime = DateTime.now();
  @override
  void initState() {
    deliveryRemaing = widget.deliveryRemaing;
    listOfReamingDelivery = deliveryRemaing.result ?? [];
    constListOfReamingDelivery = listOfReamingDelivery;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Remaining"),
        actions: [
          IconButton(
            onPressed: () async {
              await pickDateTimeAndFilter(context);
            },
            icon: const Icon(
              FluentIcons.calendar_24_regular,
            ),
          ),
          const Gap(10),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.grey.shade400,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SizedBox(
              height: 50,
              child: CupertinoSearchTextField(
                onChanged: (value) {
                  List<Result> filter = [];
                  for (var element in constListOfReamingDelivery) {
                    if (element
                        .toJson()
                        .toLowerCase()
                        .contains(value.toLowerCase())) {
                      filter.add(element);
                    }
                  }
                  setState(() {
                    listOfReamingDelivery = filter;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: listOfReamingDelivery.isEmpty
                ? const Center(
                    child: Text("Empty"),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: listOfReamingDelivery.length,
                    itemBuilder: (context, index) {
                      String name =
                          listOfReamingDelivery[index].customerName ?? "";
                      String address =
                          listOfReamingDelivery[index].customerAddress ?? "";
                      double quantitty = 0;
                      double amount = 0;
                      List<InvoiceList> invoiceList =
                          listOfReamingDelivery[index].invoiceList ?? [];
                      for (InvoiceList invoice in invoiceList) {
                        List<ProductList> droductList =
                            invoice.productList ?? [];
                        for (ProductList product in droductList) {
                          quantitty += product.quantity ?? 0;
                          amount += product.tp ?? 0;
                          amount += product.vat ?? 0;
                        }
                      }
                      String floatingAmount =
                          ("${amount.toString().split('.')[1]}000")
                              .substring(0, 2);

                      return card(
                        index: index,
                        name: name,
                        address: address,
                        invoiceLen: invoiceList.length.toString(),
                        quantitty: quantitty.toInt().toString(),
                        amount:
                            '${amount.toString().split('.')[0]}.$floatingAmount',
                        date: (listOfReamingDelivery[index].billingDate ??
                                DateTime.now())
                            .toIso8601String()
                            .split('T')[0],
                        result: listOfReamingDelivery[index],
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  Future<void> pickDateTimeAndFilter(BuildContext context) async {
    DateTime? pickedDateTime;
    await showModalBottomSheet(
      context: context,
      builder: (context) => BottomPicker.date(
        height: 500,
        pickerTitle: const Text(
          "Pick a Date",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onSubmit: (p0) {
          pickedDateTime = p0 as DateTime;
        },
      ),
    );
    if (pickedDateTime != null) {
      final box = Hive.box('info');
      final url = Uri.parse(
        "$base$getDelivaryList/${box.get('sap_id')}?type=Remaining&date=${DateFormat('yyyy-MM-dd').format(pickedDateTime!)}",
      );

      showCupertinoModalPopup(
        context: context,
        builder: (context) => Scaffold(
          backgroundColor: Colors.white.withOpacity(0.1),
          body: const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 74, 174, 255),
            ),
          ),
        ),
      );

      final response = await http.get(url);

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Got Delivery Remaning List");
          print(response.body);
        }

        setState(() {
          deliveryRemaing = DeliveryRemaing.fromJson(response.body);
          listOfReamingDelivery = deliveryRemaing.result ?? [];
          constListOfReamingDelivery = deliveryRemaing.result ?? [];
          dateTime = pickedDateTime!;
        });
      } else {
        if (kDebugMode) {
          print(
            "Delivery Remaining response error : ${response.statusCode}",
          );
          Fluttertoast.showToast(msg: "Something went wrong");
        }
      }
    }
  }

  Widget card({
    required int index,
    required String name,
    required String address,
    required String invoiceLen,
    required String quantitty,
    required String amount,
    required String date,
    required Result result,
  }) {
    return GestureDetector(
      onTap: () {
        Get.to(() => InvoiceListPage(
              dateTime: dateTime,
              result: result,
              totalAmount: amount,
            ));
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 2, left: 8, right: 8),
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
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text("Date: $date"),
                  const Gap(3),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        "Total Invoice",
                        style: style,
                      ),
                      Text(
                        invoiceLen,
                        style: style,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Quantity",
                        style: style,
                      ),
                      Text(
                        quantitty,
                        style: style,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Amount",
                        style: style,
                      ),
                      Text(
                        amount,
                        style: style,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle style = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
}
