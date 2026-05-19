// orderdash.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:teadiary/provider/Customerpro.dart' as c;
import 'package:teadiary/provider/Itempro.dart' as i;
import 'package:teadiary/provider/OrderProvider.dart' as o;

class Orderdash extends StatefulWidget {
  const Orderdash({super.key});

  @override
  State<Orderdash> createState() => _OrderdashState();
}

class _OrderdashState extends State<Orderdash> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final cusPro = Provider.of<c.Cusmanage>(context, listen: false);
      final itemPro = Provider.of<i.Itempro>(context, listen: false);
      final orderPro = Provider.of<o.Orderpro>(context, listen: false);

      await cusPro.fetchcustomers();
      await itemPro.fetchItems();

      // load items into order provider only once
      orderPro.loadItems(itemPro.Items);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cus = Provider.of<c.Cusmanage>(context);
    final orderPro = Provider.of<o.Orderpro>(context);

    // when items still empty show loader (itemPro used only in init)
    if (!orderPro.itemsLoaded) {
      return Scaffold(
        appBar: AppBar(
            title: const Text("Order Dashboard"),
            backgroundColor: Colors.orange),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Dashboard"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Add Order",
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              // CUSTOMER DROPDOWN
              DropdownSearch<String>(
                selectedItem: orderPro.selectedCustomer == null
                    ? null
                    : orderPro.selectedCustomer!["name"],
                items: cus.customers.map((e) => e["name"].toString()).toList(),
                popupProps: const PopupProps.menu(showSearchBox: true),
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Select Customer",
                    border: OutlineInputBorder(),
                  ),
                ),
                onChanged: (value) {
                  final found = cus.customers.firstWhere(
                      (cc) => cc["name"] == value,
                      orElse: () => {});
                  if (found.isNotEmpty) {
                    orderPro.setCustomer(found);
                  }
                },
              ),

              const SizedBox(height: 30),

              // ITEM LIST
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orderPro.selectedItems.length,
                itemBuilder: (context, index) {
                  return OrderItemRow(itemIndex: index);
                },
              ),

              const SizedBox(height: 40),

              // FINAL TOTAL
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Final Total: ",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  Text(
                    "₹ ${orderPro.grandTotal.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // PLACE ORDER BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => orderPro.addOrder(context),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    "Place Order",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderItemRow extends StatefulWidget {
  final int itemIndex;
  const OrderItemRow({super.key, required this.itemIndex});

  @override
  State<OrderItemRow> createState() => _OrderItemRowState();
}

class _OrderItemRowState extends State<OrderItemRow> {
  late TextEditingController qtyController;

  @override
  void initState() {
    super.initState();
    final orderPro = Provider.of<o.Orderpro>(context, listen: false);
    final row = orderPro.selectedItems[widget.itemIndex];
    qtyController = TextEditingController(text: row["qty"].toString());
  }

  @override
  void didUpdateWidget(covariant OrderItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final orderPro = Provider.of<o.Orderpro>(context, listen: false);
    if (widget.itemIndex < orderPro.selectedItems.length) {
      final row = orderPro.selectedItems[widget.itemIndex];
      // keep controller in sync if qty was changed elsewhere
      if (qtyController.text != row["qty"].toString()) {
        qtyController.text = row["qty"].toString();
      }
    }
  }

  @override
  void dispose() {
    qtyController.dispose();
    super.dispose();
  }

  void _onQtyChanged(String v) {
    final orderPro = Provider.of<o.Orderpro>(context, listen: false);
    final qty = int.tryParse(v) ?? 0;
    orderPro.updateQty(widget.itemIndex, qty);
  }

  void _incDec(int delta) {
    final orderPro = Provider.of<o.Orderpro>(context, listen: false);
    final current = int.tryParse(qtyController.text) ?? 0;
    final next = (current + delta) < 0 ? 0 : (current + delta);
    qtyController.text = next.toString();
    orderPro.updateQty(widget.itemIndex, next);
  }

  @override
  Widget build(BuildContext context) {
    final orderPro = Provider.of<o.Orderpro>(context);
    // safety: if provider list shrank, don't crash
    if (widget.itemIndex >= orderPro.selectedItems.length)
      return const SizedBox.shrink();
    final row = orderPro.selectedItems[widget.itemIndex];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    row["item_name"],
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                Text("₹ ${row["item_price"]}")
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // MINUS
                InkWell(
                  onTap: () => _incDec(-1),
                  child: Container(
                    width: 35,
                    height: 40,
                    alignment: Alignment.center,
                    color: Colors.orange,
                    child:
                        const Text("-", style: TextStyle(color: Colors.white)),
                  ),
                ),

                // QTY TEXT FIELD
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: _onQtyChanged,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),

                // PLUS
                InkWell(
                  onTap: () => _incDec(1),
                  child: Container(
                    width: 35,
                    height: 40,
                    alignment: Alignment.center,
                    color: Colors.orange,
                    child:
                        const Text("+", style: TextStyle(color: Colors.white)),
                  ),
                ),

                const Spacer(),

                Text(
                  "₹ ${(row["total"] as double).toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
