import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:odms/src/screens/home/delivery_remaining/models/deliver_remaining_model.dart';
import 'package:odms/src/screens/home/invoice_list/controller/invoice_list_controller.dart';
import 'package:odms/src/screens/overdue/controller.dart';
import 'package:odms/src/widgets/common_widgets_function.dart';

import '../../theme/text_scaler_theme.dart';
import '../../widgets/loading/loading_text_controller.dart';

class OverdueProductList extends StatefulWidget {
  final DateTime? dateOfDelivery;
  final InvoiceList invoice;
  final String invoiceNo;
  final String totalAmount;
  final int index;
  const OverdueProductList({
    super.key,
    required this.invoice,
    required this.invoiceNo,
    required this.totalAmount,
    required this.index,
    this.dateOfDelivery,
  });

  @override
  State<OverdueProductList> createState() => _OverdueProductListState();
}

class _OverdueProductListState extends State<OverdueProductList> {
  final invoiceListController = Get.put(InvoiceListController());
  final LoadingTextController loadingTextController = Get.find();

  late List<ProductList> productList;
  final formKey = GlobalKey<FormState>();

  final OverdueCollectController deliveryRemainingController = Get.find();

  @override
  void initState() {
    productList = widget.invoice.productList ?? [];
    super.initState();
  }

  Widget divider = const Divider(
    color: Colors.white,
    height: 1,
  );

  @override
  Widget build(BuildContext context) {
    if (widget.dateOfDelivery != null) {
      DateTime now = DateTime.now();
      DateTime dateOfDelivery = widget.dateOfDelivery!;
      if (dateOfDelivery.day != now.day ||
          dateOfDelivery.month != now.month ||
          dateOfDelivery.year != now.year) {}
    }

    double totalAmount = 0;

    widget.invoice.productList?.forEach((element) {
      totalAmount += (element.netVal ?? 0) + (element.vat ?? 0);
    });

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScalerValue)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Overdue Product List",
            style: const TextStyle(fontSize: 20),
          ),
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
                                  "Customer Name",
                                  widget.invoice.customerName ?? "",
                                ),
                                divider,
                                getRowWidgetForDetailsBox(
                                  "Customer Address",
                                  widget.invoice.customerAddress ?? "",
                                ),
                                divider,
                                getRowWidgetForDetailsBox(
                                  "Customer Mobile",
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
                                  totalAmount.toStringAsFixed(2),
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
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "ID: ${productList[index].matnr}",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const Gap(20),
                                      Text(
                                        "Batch: ${productList[index].batch}",
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
                                            .toPrecision(2)
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
                                                (productList[index].netVal ??
                                                    0))
                                            .toPrecision(2)
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
                          ],
                        ),
                      );
                    },
                  )),
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
