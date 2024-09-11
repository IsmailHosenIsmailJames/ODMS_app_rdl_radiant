import 'dart:convert';
import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rdl_radiant/src/apis/apis.dart';
import 'package:rdl_radiant/src/screens/coustomer_location/customer_details.dart';
import 'package:rdl_radiant/src/screens/coustomer_location/model/coustomer_list_model.dart';
import 'package:http/http.dart' as http;

import '../../widgets/coomon_widgets_function.dart';

class SetCustomerLocation extends StatefulWidget {
  const SetCustomerLocation({super.key});

  @override
  State<SetCustomerLocation> createState() => _SetCustomerLocationState();
}

class _SetCustomerLocationState extends State<SetCustomerLocation> {
  ScrollController scrollController = ScrollController();
  bool isLoadingMore = false;
  int page = 1;
  String? searchName;
  String? searchPartner;
  int? limit;

  @override
  void initState() {
    scrollController.addListener(
      () {
        final maxScroll = scrollController.position.maxScrollExtent;
        final currentScroll = scrollController.position.pixels;

        if (currentScroll == maxScroll) {
          loadMoreData();
        }
      },
    );
    loadListOfCoustomer(
      page: page,
      searchName: searchName,
      limit: limit,
      searchPartner: searchPartner,
    );
    super.initState();
  }

  loadMoreData() async {
    if (isLoadingMore == false) {
      log("Loading More...");
      setState(() {
        isLoadingMore = true;
      });
      page++;
      await loadListOfCoustomer(
        page: page,
        searchName: searchName,
        searchPartner: searchPartner,
        limit: limit,
      );
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  List<CoustomerListModel>? customerListModel;

  Future<void> loadListOfCoustomer(
      {int? page,
      String? searchName,
      String? searchPartner,
      int? limit}) async {
    try {
      http.Response response = await http.get(Uri.parse(
          "$base$getCoustomerList${page == null ? "" : "?page=$page"}${searchName == null ? "" : "&name1=$searchName"}${searchPartner == null ? "" : "&partner=$searchPartner"}${limit == null ? "" : "&limit=$limit"}"));
      customerListModel = customerListModel ?? [];
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          List<Map> listOfResult = List<Map>.from(decodedData['results']);
          for (Map result in listOfResult) {
            customerListModel!.add(
              CoustomerListModel.fromMap(
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
    return Scaffold(
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
                            "Coustomer Mobile",
                            current.mobileNo,
                            optionalWidgetsAtLast: SizedBox(
                              height: 23,
                              width: 90,
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
                              "Upazilla", current.upazilla),
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
                                      paternerID: current.partner.toString()),
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
    );
  }

  Future<void> onSearch(String value) async {
    value = value.trim();
    if (value.isNotEmpty && int.tryParse(value) != null) {
      page = 1;
      setState(() {
        searchPartner = value;
        searchName = null;
        customerListModel = [];
      });
      await loadMoreData();
    } else if (value.isNotEmpty) {
      page = 1;
      setState(() {
        searchPartner = null;
        searchName = value.toLowerCase();
        customerListModel = [];
      });
      await loadMoreData();
    }
  }
}
