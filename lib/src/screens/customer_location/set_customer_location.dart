import 'dart:convert';
import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:odms/src/apis/apis.dart';
import 'package:odms/src/screens/customer_location/customer_details.dart';
import 'package:odms/src/screens/customer_location/model/customer_list_model.dart';
import 'package:http/http.dart' as http;

import '../../theme/text_scaler_theme.dart';
import '../../widgets/common_widgets_function.dart';

class SetCustomerLocation extends StatefulWidget {
  const SetCustomerLocation({super.key});

  @override
  State<SetCustomerLocation> createState() => _SetCustomerLocationState();
}

class _SetCustomerLocationState extends State<SetCustomerLocation> {
  ScrollController scrollController = ScrollController();
  bool isLoadingMore = false;
  String? searchName;
  String? searchPartner;

  @override
  void initState() {
    loadListOfCustomer(
      searchName: searchName,
      searchPartner: searchPartner,
    );
    super.initState();
  }

  List<CustomerListModel>? customerListModel;

  Future<void> loadListOfCustomer({
    String? searchName,
    String? searchPartner,
  }) async {
    try {
      String queryParams = "";
      if (searchName != null && searchPartner != null) {
        queryParams += "?name1=$searchName &partner=$searchPartner";
      } else if (searchName != null) {
        queryParams += "?name1=$searchName";
      } else if (searchPartner != null) {
        queryParams += "?partner=$searchPartner";
      }
      setState(() {
        isLoadingMore = true;
      });
      http.Response response = await http.get(Uri.parse(
          "$base$getCustomerList/${Hive.box("info").get("sap_id")}$queryParams"));
      setState(() {
        isLoadingMore = false;
      });
      // removed
      // ${page == null ? "" : "?page=$page"}${searchName == null ? "" : "&name1=$searchName"}${searchPartner == null ? "" : "&partner=$searchPartner"}${limit == null ? "" : "&limit=$limit"}
      customerListModel = customerListModel ?? [];
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          List<Map> listOfResult = List<Map>.from(decodedData['results']);
          for (Map result in listOfResult) {
            customerListModel!.add(
              CustomerListModel.fromMap(
                Map<String, dynamic>.from(result),
              ),
            );
          }
        }
      }
      setState(() {});
    } catch (e) {
      log(e.toString());
    }
  }

  Widget dividerWhite = const Divider(
    color: Colors.white,
    height: 1,
  );

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScalerValue)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Set Customer Location"),
        ),
        body: customerListModel == null
            ? Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: Colors.green,
                  size: 40,
                ),
              )
            : Column(children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 247, 244, 244),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          offset: Offset(0, 3)),
                    ],
                  ),
                  child: CupertinoSearchTextField(
                    onSubmitted: (value) async {
                      await onSearch(value);
                    },
                  ),
                ),
                if (customerListModel!.isEmpty && isLoadingMore == false)
                  const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                      child: Text("No Data found"),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: customerListModel!.length + 1,
                    itemBuilder: (context, index) {
                      if (index == customerListModel!.length) {
                        if (isLoadingMore) {
                          return Center(
                            child: LoadingAnimationWidget.threeArchedCircle(
                              color: Colors.green,
                              size: 40,
                            ),
                          );
                        }
                        return null;
                      }
                      final current = customerListModel?[index];
                      if (current == null) return null;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            getRowWidgetForDetailsBox(
                                "Partner ID", current.partner),
                            dividerWhite,
                            getRowWidgetForDetailsBox(
                                "Pharmacy Name", current.name1),
                            dividerWhite,
                            getRowWidgetForDetailsBox(
                                "Customer Name", current.contactPerson),
                            dividerWhite,
                            getRowWidgetForDetailsBox(
                              "Customer Mobile",
                              current.mobileNo,
                              optionalWidgetsAtLast: SizedBox(
                                height: 23,
                                width: 50,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    FlutterClipboard.copy(
                                      current.mobileNo ?? "",
                                    ).then((value) {
                                      Fluttertoast.showToast(
                                          msg: current.mobileNo ?? "");
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.copy,
                                    size: 17,
                                  ),
                                ),
                              ),
                            ),
                            dividerWhite,
                            getRowWidgetForDetailsBox("Street", current.street),
                            if ((current.street1 ?? "").isNotEmpty)
                              const Divider(
                                color: Colors.white,
                                height: 1,
                              ),
                            if ((current.street1 ?? "").isNotEmpty)
                              getRowWidgetForDetailsBox(
                                  "Street 1", current.street1),
                            if ((current.street2 ?? "").isNotEmpty)
                              const Divider(
                                color: Colors.white,
                                height: 1,
                              ),
                            if ((current.street2 ?? "").isNotEmpty)
                              getRowWidgetForDetailsBox(
                                  "Street 2", current.street2),
                            dividerWhite,
                            getRowWidgetForDetailsBox(
                                "District", current.district),
                            dividerWhite,
                            getRowWidgetForDetailsBox(
                                "Upazila", current.upazilla),
                            dividerWhite,
                            getRowWidgetForDetailsBox(
                                "Trans. P. zone", current.transPZone),
                            const Gap(10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Get.to(
                                    () => CustomerDetailsPage(
                                        partnerID: current.partner.toString()),
                                  );
                                },
                                icon: const Icon(
                                  Icons.location_on,
                                ),
                                label: const Text(
                                  "Set Location",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ]),
      ),
    );
  }

  Future<void> onSearch(String value) async {
    value = value.trim();
    if (value.isNotEmpty && int.tryParse(value) != null) {
      setState(() {
        searchPartner = value;
        searchName = null;
        customerListModel = [];
      });
      loadListOfCustomer(searchName: searchName, searchPartner: searchPartner);
    } else if (value.isNotEmpty) {
      setState(() {
        searchPartner = null;
        searchName = value.toLowerCase();
        customerListModel = [];
      });
      loadListOfCustomer(searchName: searchName, searchPartner: searchPartner);
    }
  }
}
