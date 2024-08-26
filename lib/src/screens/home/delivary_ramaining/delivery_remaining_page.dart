import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rdl_radiant/src/screens/home/delivary_ramaining/models/deliver_remaing_model.dart';

class DeliveryRemainingPage extends StatefulWidget {
  final DeliveryRemaing deliveryRemaing;
  const DeliveryRemainingPage({super.key, required this.deliveryRemaing});

  @override
  State<DeliveryRemainingPage> createState() => _DeliveryRemainingPageState();
}

class _DeliveryRemainingPageState extends State<DeliveryRemainingPage> {
  List<Result> listOfReamingDelivery = [];
  @override
  void initState() {
    listOfReamingDelivery = widget.deliveryRemaing.result ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Delivery Remaining"),
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(height: 50, child: CupertinoSearchTextField()),
            ),
            Expanded(
              child: listOfReamingDelivery.isEmpty
                  ? const Center(
                      child: Text("Empty"),
                    )
                  : ListView.builder(
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
                        );
                      },
                    ),
            )
          ],
        ));
  }

  Widget card(
      {required int index,
      required String name,
      required String address,
      required String invoiceLen,
      required String quantitty,
      required String amount}) {
    return Container(
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
                      "Total Invoice",
                      style: style,
                    ),
                    Text(
                      invoiceLen,
                      style: style,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle style = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
}
