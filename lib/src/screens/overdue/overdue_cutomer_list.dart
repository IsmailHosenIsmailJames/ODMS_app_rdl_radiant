import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:odms/src/screens/home/delivery_remaining/models/deliver_remaining_model.dart';
import 'package:odms/src/screens/overdue/controller.dart';
import 'package:odms/src/screens/overdue/overdue_invoice_list.dart';
import 'package:odms/src/theme/text_scaler_theme.dart';

class OverdueCustomerList extends StatefulWidget {
  const OverdueCustomerList({super.key});

  @override
  State<OverdueCustomerList> createState() => _OverdueCustomerListState();
}

class _OverdueCustomerListState extends State<OverdueCustomerList> {
  DateTime dateTime = DateTime.now();
  final OverdueCollectController deliveryRemainingController = Get.find();
  // String pageType = "";

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScalerValue)),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Overdue"),
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
                    log(deliveryRemainingController
                        .constOverdueRemaining.value.result!.length
                        .toString());
                    List<Result> filter = [];
                    for (Result element in deliveryRemainingController
                        .constOverdueRemaining.value.result!) {
                      if (element
                          .toJson()
                          .toLowerCase()
                          .contains(value.toLowerCase())) {
                        filter.add(element);
                      }
                    }

                    setState(() {
                      deliveryRemainingController
                          .overdueRemaining.value.result = filter;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: deliveryRemainingController
                      .overdueRemaining.value.result!.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "No overdue found",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  : Obx(
                      () {
                        List<Result> results = deliveryRemainingController
                            .overdueRemaining.value.result!;
                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 10),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            String name = results[index].customerName ?? "";
                            String address =
                                results[index].customerAddress ?? "";
                            double quantity = 0;
                            double amount = 0;
                            double dueAmount = 0;
                            List<InvoiceList> invoiceList =
                                results[index].invoiceList ?? [];
                            for (InvoiceList invoice in invoiceList) {
                              List<ProductList> productList =
                                  invoice.productList ?? [];
                              dueAmount += invoice.dueAmount ?? 0;
                              for (ProductList product in productList) {
                                quantity += product.quantity ?? 0;
                                amount += product.netVal ?? 0;
                                amount += product.vat ?? 0;
                              }
                            }
                            return card(
                              index: index,
                              name: name,
                              address: address,
                              invoiceLen: invoiceList.length.toString(),
                              quantity: quantity.toInt().toString(),
                              amount: amount,
                              dueAmount: dueAmount,
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

  Widget card({
    required int index,
    required String name,
    required String address,
    required String invoiceLen,
    required String quantity,
    required double amount,
    double? dueAmount,
    required String date,
    required Result result,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        final tem =
            deliveryRemainingController.constOverdueRemaining.value.toMap();
        deliveryRemainingController.overdueRemaining.value =
            DeliveryRemaining.fromMap(tem);
        final overdueInvoiceListController =
            Get.put(OverdueInvoiceListController());
        overdueInvoiceListController.invoiceList.value =
            result.invoiceList ?? <InvoiceList>[];
        await Get.to(() => OverdueInvoiceList(
              dateTime: dateTime,
              result: result,
              totalAmount: amount.toString(),
            ));
        deliveryRemainingController.constOverdueRemaining.value =
            DeliveryRemaining.fromMap(tem);
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
                children: [
                  Text(
                    "Due amount:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Gap(7),
                  Text(
                    (dueAmount ?? 0).toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward,
                    size: 18,
                  ),
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
