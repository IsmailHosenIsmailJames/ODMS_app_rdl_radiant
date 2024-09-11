import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rdl_radiant/src/apis/apis.dart';
import 'package:rdl_radiant/src/screens/coustomer_location/model/coustomer_details_model.dart';

import '../../widgets/coomon_widgets_function.dart';

class CustomerDetailsPage extends StatefulWidget {
  final String paternerID;
  const CustomerDetailsPage({super.key, required this.paternerID});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  CoustomerDetailsModel? coustomerDetailsModel;
  bool isUnsuccessful = false;

  Future<void> getData() async {
    String paternerID = widget.paternerID;
    http.Response response = await http
        .get(Uri.parse("$base$getCoustomerDetailsByPartnerID/$paternerID"));
    if (response.statusCode == 200) {
      Map decodedData = jsonDecode(response.body);
      if (decodedData['success'] == true) {
        coustomerDetailsModel = CoustomerDetailsModel.fromMap(
            Map<String, dynamic>.from(decodedData['result']));
        setState(() {});
        return;
      }
    }
    setState(() {
      isUnsuccessful = true;
    });
  }

  Widget dividerWhite = const Divider(
    color: Colors.white,
    height: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Details"),
      ),
      body: coustomerDetailsModel == null || isUnsuccessful
          ? Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                color: Colors.green,
                size: 40,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      getRowWidgetForDetailsBox(
                          "Partner ID", coustomerDetailsModel?.partner),
                      dividerWhite,
                      getRowWidgetForDetailsBox(
                          "Pharmacy Name", coustomerDetailsModel?.name1),
                      dividerWhite,
                      getRowWidgetForDetailsBox("Customer Name",
                          coustomerDetailsModel?.contactPerson),
                      dividerWhite,
                      getRowWidgetForDetailsBox(
                        "Coustomer Mobile",
                        coustomerDetailsModel?.mobileNo,
                        optionalWidgetsAtLast: SizedBox(
                          height: 23,
                          width: 90,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              FlutterClipboard.copy(
                                coustomerDetailsModel?.mobileNo ?? "",
                              ).then((value) {
                                Fluttertoast.showToast(
                                    msg: coustomerDetailsModel?.mobileNo ?? "");
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
                          "Street", coustomerDetailsModel?.street),
                      if ((coustomerDetailsModel?.street1 ?? "").isNotEmpty)
                        const Divider(
                          color: Colors.white,
                          height: 1,
                        ),
                      if ((coustomerDetailsModel?.street1 ?? "").isNotEmpty)
                        getRowWidgetForDetailsBox(
                            "Street 1", coustomerDetailsModel?.street1),
                      if ((coustomerDetailsModel?.street2 ?? "").isNotEmpty)
                        const Divider(
                          color: Colors.white,
                          height: 1,
                        ),
                      if ((coustomerDetailsModel?.street2 ?? "").isNotEmpty)
                        getRowWidgetForDetailsBox(
                            "Street 2", coustomerDetailsModel?.street2),
                      dividerWhite,
                      getRowWidgetForDetailsBox(
                          "District", coustomerDetailsModel?.district),
                      dividerWhite,
                      getRowWidgetForDetailsBox(
                          "Upazilla", coustomerDetailsModel?.upazilla),
                      dividerWhite,
                      getRowWidgetForDetailsBox(
                          "Trans. P. zone", coustomerDetailsModel?.transPZone),
                      dividerWhite,
                      getRowWidgetForDetailsBox(
                          "Latitude",
                          (coustomerDetailsModel?.latitude ?? "Not Data Found")
                              .toString()),
                      dividerWhite,
                      getRowWidgetForDetailsBox(
                          "Longitude",
                          (coustomerDetailsModel?.longitude ?? "Not Data Found")
                              .toString()),
                    ],
                  ),
                ),
                const Gap(30),
                if (coustomerDetailsModel?.longitude == null ||
                    coustomerDetailsModel?.latitude == null)
                  const Center(
                    child: Text(
                      "Location data not found.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                if (!(coustomerDetailsModel?.longitude == null ||
                    coustomerDetailsModel?.latitude == null))
                  const Center(
                    child: Text(
                      "Already have location data.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                const Gap(50),
                if (coustomerDetailsModel?.longitude == null ||
                    coustomerDetailsModel?.latitude == null)
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.location_on),
                      label: const Text(
                        "Set Location now!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                if (!(coustomerDetailsModel?.longitude == null ||
                    coustomerDetailsModel?.latitude == null))
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.location_on),
                      label: const Text(
                        "Update Location now!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
