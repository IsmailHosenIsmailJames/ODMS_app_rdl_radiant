import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:rdl_radiant/src/screens/home/delivary_ramaining/models/deliver_remaing_model.dart';

class ProdouctListPage extends StatefulWidget {
  final InvoiceList invoice;
  final String invioceNo;
  final String totalAmount;
  const ProdouctListPage({
    super.key,
    required this.invoice,
    required this.invioceNo,
    required this.totalAmount,
  });

  @override
  State<ProdouctListPage> createState() => _ProdouctListPageState();
}

class _ProdouctListPageState extends State<ProdouctListPage> {
  late List<ProductList> productList;
  List<TextEditingController> receiveTextEditingControllerList = [];
  List<TextEditingController> returnTextEditingControllerList = [];
  List<double> receiveAmountList = [];
  List<double> returnAmountList = [];

  @override
  void initState() {
    productList = widget.invoice.productList ?? [];
    for (int i = 0; i < productList.length; i++) {
      receiveTextEditingControllerList.add(TextEditingController());
      receiveAmountList.add(0);
      returnTextEditingControllerList.add(TextEditingController());
      returnAmountList.add(0);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double totalReceiveAmmount = 0;
    for (var e in receiveAmountList) {
      totalReceiveAmmount += e;
    }
    double totalRetrunAmmount = 0;
    for (var e in returnAmountList) {
      totalRetrunAmmount += e;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Product List",
        ),
      ),
      body: ListView(
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                  (productList[index].quantity ?? 0).toString(),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      int? recQuentaty =
                                          int.tryParse(value ?? "");
                                      if (recQuentaty != null) {
                                        int? retQuentaty = int.tryParse(
                                            returnTextEditingControllerList[
                                                    index]
                                                .text);
                                        retQuentaty ??= 0;
                                        int totalQuentaty =
                                            recQuentaty + retQuentaty;
                                        if (totalQuentaty >
                                            (productList[index].quantity ??
                                                0)) {
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
                                      int? recQuentaty = int.tryParse(value);
                                      if (recQuentaty != null) {
                                        int? retQuentaty = int.tryParse(
                                            returnTextEditingControllerList[
                                                    index]
                                                .text);
                                        retQuentaty ??= 0;
                                        int totalQuentaty =
                                            recQuentaty + retQuentaty;
                                        if (totalQuentaty >
                                            (productList[index].quantity ??
                                                0)) {
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
                                                perProduct * (retQuentaty ?? 0);
                                            receiveAmountList[index] =
                                                perProduct * recQuentaty;
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
                                        receiveTextEditingControllerList[index],
                                    decoration: InputDecoration(
                                      hintText: "Received Qty.",
                                      labelText: "Received Qty.",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const Gap(20),
                                Expanded(
                                  child: TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      int? retQuentaty =
                                          int.tryParse(value ?? "");
                                      if (retQuentaty != null) {
                                        int? recQuentaty = int.tryParse(
                                            receiveTextEditingControllerList[
                                                    index]
                                                .text);
                                        recQuentaty ??= 0;
                                        int totalQuentaty =
                                            retQuentaty + recQuentaty;
                                        if (totalQuentaty >
                                            (productList[index].quantity ??
                                                0)) {
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
                                        if (totalQuentaty >
                                            (productList[index].quantity ??
                                                0)) {
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
                                ),
                              ],
                            ),
                            const Gap(5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ) +
            <Widget>[
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(100),
                        bottomLeft: Radius.circular(100),
                      ),
                      color: Colors.blue.shade200,
                    ),
                    width: MediaQuery.of(context).size.width * .45,
                    height: 40,
                    child: Center(
                      child: Text(
                          "Total Rec.: ${totalReceiveAmmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                      ),
                      color: Colors.red.shade200,
                    ),
                    width: MediaQuery.of(context).size.width * .45,
                    height: 40,
                    child: Center(
                      child: Text(
                        "Total Ret.: ${totalRetrunAmmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(30),
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
                      onPressed: () {},
                      child: const Text("Delivered"),
                    ),
                  ),
                ],
              ),
            ],
      ),
    );
  }

  TextStyle style = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);

  TextStyle topContainerTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}