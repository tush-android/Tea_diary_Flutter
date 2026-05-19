import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teadiary/order/orderdash.dart';
import 'package:teadiary/provider/OrderProvider.dart' as o;

class Updateorder extends StatefulWidget {
  final Map<String, dynamic> orderData;
  const Updateorder({super.key, required this.orderData});

  @override
  State<Updateorder> createState() => _UpdateorderState();
}

class _UpdateorderState extends State<Updateorder> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final orderpro = Provider.of<o.Orderpro>(context, listen: false);
      orderpro.selectedCustomer = widget.orderData["customer"];
      orderpro.selectedItems = (widget.orderData["items"] as List)
          .map((i) => {
                "id": i["id"],
                "item_name": i["item_name"],
                "item_price":
                    double.tryParse(i["item_price"].toString()) ?? 0.0,
                "qty": i["qty"] ?? 0,
                "total": double.tryParse(i["total"].toString()) ?? 0.0,
              })
          .toList();
      orderpro.grandTotal =
          double.tryParse(widget.orderData["grand_total"].toString()) ?? 0.0;
      orderpro.notifyListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderpro = Provider.of<o.Orderpro>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Order"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Edit",
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Colors.lightBlueAccent,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      orderpro.selectedCustomer?["name"] ?? "",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orderpro.selectedItems.length,
                itemBuilder: (context, index) {
                  return OrderItemRow(itemIndex: index);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                child: Row(
                  children: [
                    const Text(
                      "Final Total: ",
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "${orderpro.grandTotal.toStringAsFixed(2)}",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final opro =
                        Provider.of<o.Orderpro>(context, listen: false);
                    final newdata = {
                      "customer": opro.selectedCustomer,
                      "items": opro.selectedItems,
                      "grand_total": opro.grandTotal,
                      "createdAt": FieldValue.serverTimestamp(),
                    };
                    orderpro.updateOrder(
                        widget.orderData["id"], context, newdata);
                  },
                  label: Text(
                    "Update Order",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: const Icon(Icons.update),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class selectedItemsrow extends StatefulWidget {
  const selectedItemsrow({super.key});

  @override
  State<selectedItemsrow> createState() => _selectedItemsrowState();
}

class _selectedItemsrowState extends State<selectedItemsrow> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
