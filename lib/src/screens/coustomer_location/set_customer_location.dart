import 'dart:convert';
import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rdl_radiant/src/apis/apis.dart';
import 'package:rdl_radiant/src/screens/coustomer_location/model/coustomer_list_model.dart';
import 'package:http/http.dart' as http;

import '../../widgets/coomon_widgets_function.dart';

class SetCustomerLocation extends StatefulWidget {
  const SetCustomerLocation({super.key});

  @override
  State<SetCustomerLocation> createState() => _SetCustomerLocationState();
}

class _SetCustomerLocationState extends State<SetCustomerLocation> {
  @override
  void initState() {
    loadListOfCoustomer();
    super.initState();
  }

  List<CoustomerListModel>? customerListModel;

  Future<void> loadListOfCoustomer() async {
    try {
      http.Response response =
          await http.get(Uri.parse(base + getCoustomerList));
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          List<Map> listOfResult = List<Map>.from(decodedData['results']);
          customerListModel = [];
          for (Map result in listOfResult) {
            customerListModel!.add(
              CoustomerListModel.fromMap(
                Map<String, dynamic>.from(result),
              ),
            );
          }
          setState(() {});
        }
      }
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
          : customerListModel!.isEmpty
              ? const Center(
                  child: Text("No Data found"),
                )
              : Column(
                  children: [
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
                      child: const CupertinoSearchTextField(),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: customerListModel!.length,
                        itemBuilder: (context, index) {
                          final current = customerListModel?[index];
                          if (current == null) return const SizedBox();
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
                                getRowWidgetForDetailsBox(
                                    "Street", current.street),
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
                                dividerWhite,
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
