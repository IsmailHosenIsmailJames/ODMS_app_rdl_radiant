import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:odms/src/screens/home/delivery_remaining/models/deliver_remaining_model.dart';
import 'package:odms/src/screens/home/invoice_list/controller/invoice_list_controller.dart';
import 'package:odms/src/screens/home/page_sate_definition.dart';
import 'package:odms/src/screens/home/product_list/product_list_page.dart';
import 'package:odms/src/screens/home/product_list/cash_collection/product_list_cash_collection.dart';
import 'package:odms/src/screens/maps/map_view.dart';
import 'package:odms/src/screens/overdue/controllers/overdue_controller_getx.dart';
import 'package:odms/src/screens/overdue/models/overdue_response_model.dart'
    as overdue;
import 'package:odms/src/screens/overdue/overdue_invoice_list.dart';
import 'package:simple_icons/simple_icons.dart';

import '../../../apis/apis.dart';
import '../../../theme/text_scaler_theme.dart';
import '../../../widgets/common_widgets_function.dart';
import '../../../widgets/loading/loading_popup_widget.dart';
import '../../../widgets/loading/loading_text_controller.dart';
import '../delivery_remaining/controller/delivery_remaining_controller.dart';

class InvoiceListPage extends StatefulWidget {
  final DateTime dateTime;
  final Result result;
  const InvoiceListPage({
    super.key,
    required this.dateTime,
    required this.result,
  });

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  final invoiceListController = Get.put(InvoiceListController());
  final DeliveryRemainingController deliveryRemainingController = Get.find();
  final LoadingTextController loadingTextController = Get.find();
  late final routeName = invoiceListController.invoiceList[0].routeName ?? '';
  late final daName = invoiceListController.invoiceList[0].daName ?? '';
  late final partner = invoiceListController.invoiceList[0].partner ?? '';
  late final customerName =
      invoiceListController.invoiceList[0].customerName ?? '';
  late final customerAddress =
      invoiceListController.invoiceList[0].customerAddress ?? '';

  String pageType = '';
  late double due = invoiceListController.invoiceList[0].previousDueAmount ?? 0;
  late final customerMobile =
      invoiceListController.invoiceList[0].customerMobile ?? '';
  late final gatePassNo = invoiceListController.invoiceList[0].gatePassNo ?? '';

  @override
  void initState() {
    pageType = deliveryRemainingController.pageType.value;
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
          title: deliveryRemainingController.pageType.value != ''
              ? Text('${deliveryRemainingController.pageType.value} Details')
              : const Text('Delivery Details'),
        ),
        floatingActionButton: widget.result.customerLatitude != null &&
                widget.result.customerLongitude != null
            ? FloatingActionButton(
                onPressed: () async {
                  log('Lat:${widget.result.customerLatitude} ');
                  log('Lat:${widget.result.customerLongitude} ');
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
                        'Route Name',
                        routeName,
                      ),

                      divider,
                      getRowWidgetForDetailsBox(
                        'Da Name',
                        daName,
                      ),
                      divider,
                      getRowWidgetForDetailsBox(
                        'Partner ID',
                        partner,
                      ),
                      divider,
                      getRowWidgetForDetailsBox(
                        'Customer Name',
                        customerName,
                      ),
                      divider,
                      getRowWidgetForDetailsBox(
                        'Customer Address',
                        customerAddress,
                      ),
                      // divider,
                      // getRowWidgetForDetailsBox(
                      //   "Customer lat.",
                      //   invoiceListController.invoiceList[0].latitude.toString(),
                      // ),
                      // divider,
                      // getRowWidgetForDetailsBox(
                      //   "Customer lon.",
                      //   invoiceListController.invoiceList[0].longitude.toString(),
                      // ),
                      divider,
                      getRowWidgetForDetailsBox(
                        'Customer Mobile',
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
                                Fluttertoast.showToast(msg: 'Number Copied');
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
                        gatePassNo,
                      ),
                      divider,
                      getRowWidgetForDetailsBox(
                        'Total Amount',
                        calculateTotalAmount()
                            .toPrecision(2)
                            .toStringAsFixed(2),
                      ),
                      divider,

                      getRowWidgetForDetailsBox(
                        'Previous Due',
                        due.toStringAsFixed(2),
                        optionalWidgetsAtLast: Row(
                          children: [
                            SizedBox(
                              height: 25,
                              width: 100,
                              child: ElevatedButton(
                                onPressed: due == 0
                                    ? null
                                    : () async {
                                        onPreviousDueCollectButtonPressed(
                                            context);
                                      },
                                child: const Text('Collect'),
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
          const Gap(15),
          Obx(
            () {
              List<InvoiceList> invoiceList =
                  invoiceListController.invoiceList.value;
              return Column(
                children: List.generate(
                  invoiceList.length,
                  (index) {
                    double invoiceAmount = 0;
                    int returnQty = 0;
                    double returnAmount = 0;
                    int deliveryQty = 0;
                    double deliveryAmount = 0;
                    for (final ProductList productList
                        in invoiceList[index].productList ?? []) {
                      invoiceAmount +=
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
                        (pageType == pagesState[2] ||
                                pageType == pagesState[3] ||
                                pageType == pagesState[4])
                            ? await Get.to(
                                () => ProductListCashCollection(
                                  invoice: invoiceList[index],
                                  invoiceNo:
                                      (invoiceList[index].billingDocNo ?? 0)
                                          .toString(),
                                  totalAmount:
                                      (invoiceAmount - returnAmount).toString(),
                                  index: index,
                                ),
                              )
                            : await Get.to(
                                () => ProductListPage(
                                  invoice: invoiceList[index],
                                  invoiceNo:
                                      (invoiceList[index].billingDocNo ?? 0)
                                          .toString(),
                                  totalAmount:
                                      (invoiceAmount - returnAmount).toString(),
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
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Invoice No:',
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
                                        invoiceList[index].deliveryStatus ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                      )
                                    ],
                                  ),
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
                                      color: Colors.grey.withOpacity(0.2),
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
                                            'Type',
                                            style: style,
                                          ),
                                        ),
                                        SizedBox(
                                          width: width / 3.5,
                                          child: Text(
                                            'Quantity',
                                            style: style,
                                          ),
                                        ),
                                        SizedBox(
                                          width: width / 3.5,
                                          child: Text(
                                            'Amount',
                                            style: style,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.2),
                                      borderRadius: !(returnQty == 0 &&
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
                                            'Invoice',
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
                                            invoiceAmount.toStringAsFixed(2),
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
                                        color: Colors.green.withOpacity(0.2),
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
                                              'Delivered',
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
                                              deliveryAmount.toStringAsFixed(2),
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
                                              'Returned',
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

  Future<void> onPreviousDueCollectButtonPressed(BuildContext context) async {
    final String? partnerPrev = invoiceListController.invoiceList[0].partner;
    OverdueDocsListController overdueInvoiceListController =
        Get.put(OverdueDocsListController());

    //Call api for due list
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$getOverdueListV2/${box.get('sap_id')}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCustomPopUpLoadingDialog(context, isCupertino: true);

    final response = await get(url);

    log('Got Overdue List');
    log(response.statusCode.toString());
    log(response.body);

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';

      final modelFormHTTPResponse =
          overdue.OverdueResponseModel.fromJson(response.body);
      final controller = Get.put(
        OverdueControllerGetx(modelFormHTTPResponse),
      );

      controller.overdueRemaining.value = modelFormHTTPResponse;
      controller.constOverdueRemaining.value = modelFormHTTPResponse;
      controller.overdueRemaining.value.result ??= [];
      controller.constOverdueRemaining.value.result ??= [];
      await Future.delayed(const Duration(milliseconds: 100));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      //  Go to invoice directly
      final results = controller.constOverdueRemaining.value.result!;
      overdue.Result? result;
      for (var r in results) {
        if (r.partnerId == partnerPrev && r.billingDocs?.isEmpty == false) {
          result = r;
        }
      }

      if (result != null) {
        overdueInvoiceListController.docsList.value =
            result.billingDocs ?? <overdue.BillingDoc>[];
        await showModalBottomSheet(
          scrollControlDisabledMaxHeightRatio: 0.8,
          context: context,
          builder: (context) => OverdueInvoiceList(
            dateTime: widget.dateTime,
            result: result!,
            dueAmount: due,
          ),
        );

        // reload data
        try {
          final box = Hive.box('info');
          final url = Uri.parse(
            "$base${(pageType == pagesState[0] || pageType == pagesState[1]) ? getDeliveryList : cashCollectionList}/${box.get('sap_id')}?type=${(pageType == pagesState[1] ? "Done" : "Remaining")}&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
          );

          final response = await get(url);

          if (response.statusCode == 200) {
            log('Got Delivery Remaining List');
            log(response.body);

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
          log('Failed when try to reload the data');
        }
      }

      // back
    } else {
      loadingTextController.currentState.value = -1;
      loadingTextController.loadingText.value = 'Something went wrong';
    }

    // calculate Due
    double nowDue = 0;
    for (var invoice in overdueInvoiceListController.docsList.value) {
      nowDue += invoice.dueAmount ?? 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        due = nowDue;
      });
    });
  }

  double calculateTotalAmount() {
    double totalAmount = 0;
    for (final invoice in invoiceListController.invoiceList) {
      final productList = invoice.productList;

      if (productList != null) {
        for (int i = 0; i < productList.length; i++) {
          totalAmount +=
              (productList[i].netVal ?? 0) + (productList[i].vat ?? 0);
        }
      }
    }
    return totalAmount;
  }

  TextStyle style = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
  TextStyle topContainerTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
