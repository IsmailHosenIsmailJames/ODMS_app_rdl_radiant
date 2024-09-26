import 'package:bottom_picker/bottom_picker.dart';
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
import 'package:rdl_radiant/src/screens/home/invoice_list/controller/invoice_list_controller.dart';
import 'package:rdl_radiant/src/screens/home/invoice_list/invoice_list_page.dart';
import 'package:rdl_radiant/src/theme/text_scaler_theme.dart';

import '../../../apis/apis.dart';
import '../page_sate_defination.dart';
import 'controller/delivery_remaning_controller.dart';

class DeliveryRemainingPage extends StatefulWidget {
  const DeliveryRemainingPage({super.key});

  @override
  State<DeliveryRemainingPage> createState() => _DeliveryRemainingPageState();
}

class _DeliveryRemainingPageState extends State<DeliveryRemainingPage> {
  DateTime dateTime = DateTime.now();
  final DeliveryRemaningController deliveryRemaningController = Get.find();
  String pageType = '';

  @override
  void initState() {
    super.initState();
    pageType = deliveryRemaningController.pageType.value;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScalerValue)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(pageType),
          actions: [
            if (pageType == pagesState[0] ||
                pageType == pagesState[1] ||
                pageType == pagesState[2])
              IconButton(
                onPressed: () async {
                  await pickDateTimeAndFilter(context);
                },
                icon: const Icon(
                  Icons.filter_alt_sharp,
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
                    for (Result element in deliveryRemaningController
                        .constDeliveryRemaing.value.result!) {
                      if (element
                          .toJson()
                          .toLowerCase()
                          .contains(value.toLowerCase())) {
                        filter.add(element);
                      }
                    }
                    deliveryRemaningController.deliveryRemaing.value.result =
                        filter;
                    setState(() {});
                  },
                ),
              ),
            ),
            Expanded(
              child: deliveryRemaningController
                      .deliveryRemaing.value.result!.isEmpty
                  ? Center(
                      child: Text(
                        "There is no delivery available on this date : ${dateTime.toIso8601String().split('T')[0]}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Obx(
                      () {
                        List<Result> results = deliveryRemaningController
                            .deliveryRemaing.value.result!;
                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 10),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            String name = results[index].customerName ?? "";
                            String address =
                                results[index].customerAddress ?? "";
                            double quantitty = 0;
                            double amount = 0;
                            List<InvoiceList> invoiceList =
                                results[index].invoiceList ?? [];
                            for (InvoiceList invoice in invoiceList) {
                              List<ProductList> droductList =
                                  invoice.productList ?? [];
                              for (ProductList product in droductList) {
                                quantitty += product.quantity ?? 0;
                                amount += product.netVal ?? 0;
                                amount += product.vat ?? 0;
                              }
                            }
                            String floating2Amount = amount.toStringAsFixed(2);

                            return card(
                              index: index,
                              name: name,
                              address: address,
                              invoiceLen: invoiceList.length.toString(),
                              quantitty: quantitty.toInt().toString(),
                              amount: floating2Amount,
                              date:
                                  (results[index].billingDate ?? DateTime.now())
                                      .toIso8601String()
                                      .split('T')[0],
                              result: results[index],
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickDateTimeAndFilter(
    BuildContext context,
  ) async {
    DateTime? pickedDateTime;
    String? filterBy;
    await showModalBottomSheet(
      context: context,
      builder: (context) => BottomPicker.date(
        height: 500,
        pickerTitle: pageType == pagesState[2]
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Pick a Date",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(30),
                  DropdownMenu(
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    label: const Text("Filter by"),
                    onSelected: (value) {
                      filterBy = value ?? "";
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: "All",
                        label: "All",
                      ),
                      DropdownMenuEntry(
                        value: "GatePass",
                        label: "GatePass",
                      ),
                      DropdownMenuEntry(
                        value: "Return",
                        label: "Return",
                      ),
                      DropdownMenuEntry(
                        value: "Due",
                        label: "Due",
                      ),
                      DropdownMenuEntry(
                        value: "Remaining",
                        label: "Remaining",
                      ),
                    ],
                  ),
                ],
              )
            : const Text(
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
        "$base${(pageType == pagesState[0] || pageType == pagesState[1]) ? getDelivaryList : cashCollectionList}/${box.get('sap_id')}?type=${filterBy ?? ((pageType == pagesState[1]) ? "Done" : "Remaining")}&date=${DateFormat('yyyy-MM-dd').format(pickedDateTime!)}",
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

        deliveryRemaningController.deliveryRemaing.value =
            DeliveryRemaing.fromJson(response.body);
        deliveryRemaningController.constDeliveryRemaing.value =
            DeliveryRemaing.fromJson(response.body);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            dateTime = pickedDateTime!;
          });
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
      behavior: HitTestBehavior.translucent,
      onTap: () {
        deliveryRemaningController.deliveryRemaing.value =
            deliveryRemaningController.constDeliveryRemaing.value;
        final invoiceListController = Get.put(InvoiceListController());
        invoiceListController.invoiceList.value =
            result.invoiceList ?? <InvoiceList>[];
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
                  ),
                  if (pageType == pagesState[3])
                    Column(
                      children: [
                        Text(
                          "Due",
                          style: style,
                        ),
                        Text(
                          (double.parse(amount) -
                                  (result.invoiceList?[0].cashCollection ?? 0))
                              .toStringAsFixed(2),
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
