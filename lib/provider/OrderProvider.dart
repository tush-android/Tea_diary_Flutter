import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class Orderpro with ChangeNotifier {
  Map<String, dynamic>? selectedCustomer;

  void setCustomer(Map<String, dynamic> customer) {
    selectedCustomer = {
      "id": customer["id"],
      "name": customer["name"],
      "mobile": customer["mobile"],
      "address": customer["address"],
    };
    notifyListeners();
  }

  // -------------------------
  // ITEMS
  // -------------------------
  List<Map<String, dynamic>> originalItems = [];
  List<Map<String, dynamic>> selectedItems = [];
  bool itemsLoaded = false;

  /// Reset item data when seller logs in/out
  void resetItemData() {
    itemsLoaded = false;
    originalItems = [];
    selectedItems = [];
    notifyListeners();
  }

  /// Load seller items (calls every login)
  void loadItems(List<Map<String, dynamic>> items) {
    itemsLoaded = true;
    originalItems = items;

    selectedItems = items.map((i) {
      return {
        "id": i["id"],
        "item_name": i["Itemname"],
        "item_price": double.tryParse(i["ItemPrice"].toString()) ?? 0.0,
        "qty": 0,
        "total": 0.0,
      };
    }).toList();

    _computeGrandTotal();
    notifyListeners();
  }

  // -------------------------
  // QTY + TOTAL
  // -------------------------
  double grandTotal = 0.0;

  void updateQty(int index, int qty) {
    if (index < 0 || index >= selectedItems.length) return;

    if (qty < 0) qty = 0;

    selectedItems[index]["qty"] = qty;
    selectedItems[index]["total"] = selectedItems[index]["item_price"] * qty;

    _computeGrandTotal();
    notifyListeners();
  }

  void _computeGrandTotal() {
    grandTotal =
        selectedItems.fold(0.0, (sum, item) => sum + (item["total"] as double));
  }

  double sumForCusomer(String customerID, {DateTime? start, DateTime? end}) {
    final List<Map<String, dynamic>> list = allOrders.where((order) {
      final orderCustomer = order["customer"]?["id"]?.toString();
      if (orderCustomer != customerID) return false;
      if (start != null && end != null) {
        final ts = order["createdAt"];
        if (ts == null) return false;
        final date = ts.toDate();
        return date.isAfter(start.subtract(const Duration(days: 1))) &&
            date.isBefore(end.add(const Duration(days: 1)));
      }
      return true;
    }).toList();
    double sum = 0.0;
    for (var l in list) {
      final t = l["grand_total"];
      if (t == null) continue;
      if (t is num)
        sum += t.toDouble();
      else
        sum += double.tryParse(t.toString()) ?? 0.0;
    }
    return sum;
  }

  /* Future<String> generateCustomerBillPDF({
    required String customerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final sellerDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final sellerData = sellerDoc.data() ?? {};
      final storename = (sellerData['shopname' ?? 'Tea Diary']).toString();
      final sellername = (sellerData['name'] ?? 'No Name').toString().trim();
      final sellerMobile = (sellerData['mobile'] ?? "0").toString();
      final customerOrders = filteredOrders.where((order) {
        if (order["customer"]?["id"]?.toString() != customerId) return false;
        //   if (order['sellerID']?.toString() != uid) return false;
        // only pending / active orders (as you requested no Y->N update for now)
        /// if (order['status']?.toString() != 'Y') return false;

        final ts = order['createdAt'];
        if (ts == null) return false;
        final orderDate = (ts as Timestamp).toDate();
        //DateTime orderDate = order["createdAt"].toDate();
        if (startDate != null && orderDate.isBefore(startDate)) return false;
        if (endDate != null && orderDate.isAfter(endDate)) return false;

        return true;
      }).toList();

      if (customerOrders.isEmpty) {
        return "NO_ORDERS";
      }
      final regularFont = pw.Font.ttf(
          await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
      final boldFont =
          pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));
      final pdf = pw.Document();
      double finalamount = 0.0;
      String fmtDate(DateTime d) =>
          "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
      pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(12),
          build: (context) {
            final List<pw.Widget> widget = [];
            widget.add(pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(storename,
                            style: pw.TextStyle(fontSize: 22, font: boldFont)),
                        if (sellername.isNotEmpty)
                          pw.Text("Seller Name: ${sellername}",
                              style: pw.TextStyle(fontSize: 16)),
                        if (sellerMobile.isNotEmpty)
                          pw.Text("Seller Mobileno: $sellerMobile",
                              style: pw.TextStyle(fontSize: 16)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("Customer Bill",
                            style: pw.TextStyle(fontSize: 14, font: boldFont)),
                        pw.SizedBox(height: 4),
                        pw.Text("Date: ${fmtDate(DateTime.now())}",
                            style: pw.TextStyle(fontSize: 10)),
                      ]),
                ]));
            widget.add(pw.SizedBox(height: 12));

            final customer =
                customerOrders.first["customer"] as Map<String, dynamic> ?? {};
            final custoname = (customer["name" ?? ""]).toString();
            final cusmob = (customer["phone" ?? ""]).toString();

            widget.add(pw.Text("Customer Name: $custoname",
                style: pw.TextStyle(font: boldFont, fontSize: 12)));
            widget.add(pw.Text("Customer Mobileno : $cusmob",
                style: pw.TextStyle(font: boldFont, fontSize: 12)));
            widget.add(pw.SizedBox(height: 8));

            if (startDate != null || endDate != null) {
              final s = startDate != null ? fmtDate(startDate) : "Any";
              final e = endDate != null ? fmtDate(endDate) : "Any";
              widget.add(pw.Text("Period: $s to $e",
                  style: pw.TextStyle(fontSize: 10)));
              widget.add(pw.SizedBox(height: 8));
            }

            for (var order in customerOrders) {
              final ts = order['createdAt'] as Timestamp;
              final orderdate = ts.toDate();
              final orderdatestr = fmtDate(orderdate);

              final List items = (order['items'] ?? []) as List;
              final tableHeaders = ['Item', 'Qty', 'Price', 'Total'];
              final List<List<String>> tableData = items.map((it) {
                final name =
                    (it['item_name'] ?? it['Itemname'] ?? '').toString();
                final qty = double.tryParse(it['qty']?.toString() ?? '0') ?? 0;
                // prefer item_price field (your structure uses item_price)
                final price = double.tryParse(it['item_price']?.toString() ??
                        it['price']?.toString() ??
                        '0') ??
                    0;
                // sometimes you already store item total; fallback to qty*price
                final itemTotal =
                    double.tryParse(it['total']?.toString() ?? '') ??
                        (qty * price);

                return [
                  name,
                  qty % 1 == 0 ? qty.toInt().toString() : qty.toString(),
                  "Rs ${price.toStringAsFixed(2)}",
                  "Rs ${itemTotal.toStringAsFixed(2)}",
                ];
              }).toList();
              double orderTotal = 0.0;
              final gt = order['grand_total'];
              if (gt != null) {
                if (gt is num)
                  orderTotal = gt.toDouble();
                else
                  orderTotal = double.tryParse(gt.toString()) ?? 0.0;
              } else {
                // sum item totals if grand_total missing
                for (var r in tableData) {
                  final tStr = r[3].replaceAll('Rs ', '');
                  orderTotal += double.tryParse(tStr) ?? 0.0;
                }
              }
              finalamount += orderTotal;
              widget.add(pw.SizedBox(height: 10));
              widget.add(pw.Text("order date: $orderdatestr",
                  style: pw.TextStyle(fontSize: 12, font: regularFont)));
              widget.add(pw.SizedBox(height: 6));

              widget.add(
                pw.Table.fromTextArray(
                  headers: tableHeaders,
                  data: tableData,
                  headerStyle: pw.TextStyle(font: boldFont),
                  headerDecoration:
                      pw.BoxDecoration(color: PdfColors.blueGrey800),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellPadding:
                      const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  columnWidths: {
                    0: pw.FlexColumnWidth(4), // Item
                    1: pw.FlexColumnWidth(1), // Qty
                    2: pw.FlexColumnWidth(2), // Price
                    3: pw.FlexColumnWidth(2), // Total
                  },
                  cellStyle: pw.TextStyle(font: boldFont, fontSize: 10),
                ),
              );
              widget.add(pw.SizedBox(height: 6));
              widget.add(
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                  pw.Text("Order Total: ",
                      style: pw.TextStyle(font: boldFont, fontSize: 16)),
                  pw.SizedBox(width: 6),
                  pw.Text("Rs .${orderTotal.toStringAsFixed(2)}",
                      style: pw.TextStyle(fontSize: 16, font: regularFont)),
                ]),
              );
              widget.add(pw.Divider());
            }
            widget.add(
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                pw.Text("Total Payble Amount: ",
                    style: pw.TextStyle(fontSize: 14, font: boldFont)),
                pw.Text("Rs ${finalamount.toStringAsFixed(2)}",
                    style: pw.TextStyle(fontSize: 16, font: regularFont))
              ]),
            );
            widget.add(pw.SizedBox(height: 10));
            widget.add(pw.Text("Thank You For Your BuisnessR",
                style: pw.TextStyle(fontSize: 16, font: boldFont)));
            return widget;
          }));

      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          "${dir.path}/TeaBill_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      final billsID = FirebaseFirestore.instance.collection('bills').doc().id;
      final customerMap =
          customerOrders.first["customer"] as Map<String, dynamic>;
      final custoname = customerMap["name"] ?? "";
      final cusmob = customerMap["mobile"] ?? "";
      final billsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('bills')
          .doc(billsID);
      await billsCollection.set({
        'billID': billsID,
        'customerId': customerId,
        'customerName': custoname,
        'customerMobile': cusmob,
        'sellerId': uid,
        'sellerName': sellername,
        'sellerMobile': sellerMobile,
        'filePath': filePath,
        'finalAmount': finalamount,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'generatedAt': DateTime.now().toIso8601String(),
      });

      for (var order in customerOrders) {
        final docId = order['docId'];
        if (docId != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .collection("orders")
              .doc(docId)
              .update({"status": "N"});
        }
      }
      return filePath;
    } catch (e) {
      print("PDF ERROR: $e");
      return "ERROR";
    }
  }
*/
  Future<String> generateCustomerBillPDF({
    required String customerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch seller data
      final sellerDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final sellerData = sellerDoc.data() ?? {};
      final storename = (sellerData['shopname'] ?? 'Tea Diary').toString();
      final sellername = (sellerData['name'] ?? 'No Name').toString().trim();
      final sellerMobile = (sellerData['mobile'] ?? "0").toString();

      // Filter orders for this customer + date range
      final customerOrders = filteredOrders.where((order) {
        if (order["customer"]?["id"]?.toString() != customerId) return false;

        final ts = order['createdAt'];
        if (ts == null) return false;
        final orderDate = (ts as Timestamp).toDate();
        if (startDate != null && orderDate.isBefore(startDate)) return false;
        if (endDate != null && orderDate.isAfter(endDate)) return false;

        return true;
      }).toList();

      if (customerOrders.isEmpty) return "NO_ORDERS";

      // Ensure each order has a docId
      for (var order in customerOrders) {
        if (!order.containsKey('docId')) {
          order['docId'] = order['id'];
        }
      }

      final regularFont = pw.Font.ttf(
          await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
      final boldFont =
          pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));

      final pdf = pw.Document();
      double finalAmount = 0.0;
      final customer = customerOrders.first["customer"] as Map<String, dynamic>;
      final custoname = customer["name"] ?? "";
      final cusmob = customer["mobile"] ?? "";

      String fmtDate(DateTime d) =>
          "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(12),
        build: (context) {
          final List<pw.Widget> widget = [];

          // Header
          widget.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(storename,
                        style: pw.TextStyle(fontSize: 22, font: boldFont)),
                    if (sellername.isNotEmpty)
                      pw.Text("Seller Name: $sellername",
                          style: pw.TextStyle(fontSize: 16)),
                    if (sellerMobile.isNotEmpty)
                      pw.Text("Seller Mobile: $sellerMobile",
                          style: pw.TextStyle(fontSize: 16)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Customer Bill",
                        style: pw.TextStyle(fontSize: 14, font: boldFont)),
                    pw.SizedBox(height: 4),
                    pw.Text("Date: ${fmtDate(DateTime.now())}",
                        style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          );
          widget.add(pw.SizedBox(height: 12));

          widget.add(pw.Text("Customer Name: $custoname",
              style: pw.TextStyle(font: boldFont, fontSize: 12)));
          widget.add(pw.Text("Customer Mobile: $cusmob",
              style: pw.TextStyle(font: boldFont, fontSize: 12)));
          widget.add(pw.SizedBox(height: 8));

          if (startDate != null || endDate != null) {
            final s = startDate != null ? fmtDate(startDate) : "Any";
            final e = endDate != null ? fmtDate(endDate) : "Any";
            widget.add(
                pw.Text("Period: $s to $e", style: pw.TextStyle(fontSize: 10)));
            widget.add(pw.SizedBox(height: 8));
          }

          for (var order in customerOrders) {
            final ts = order['createdAt'] as Timestamp;
            final orderDateStr = fmtDate(ts.toDate());

            final List items = (order['items'] ?? []) as List;
            final tableHeaders = ['Item', 'Qty', 'Price', 'Total'];
            final tableData = items.map((it) {
              final name = (it['item_name'] ?? it['Itemname'] ?? '').toString();
              final qty = double.tryParse(it['qty']?.toString() ?? '0') ?? 0;
              final price = double.tryParse(it['item_price']?.toString() ??
                      it['price']?.toString() ??
                      '0') ??
                  0;
              final itemTotal =
                  double.tryParse(it['total']?.toString() ?? '') ??
                      (qty * price);
              return [
                name,
                qty % 1 == 0 ? qty.toInt().toString() : qty.toString(),
                "Rs ${price.toStringAsFixed(2)}",
                "Rs ${itemTotal.toStringAsFixed(2)}",
              ];
            }).toList();

            double orderTotal = 0.0;
            final gt = order['grand_total'];
            if (gt != null) {
              orderTotal = gt is num
                  ? gt.toDouble()
                  : double.tryParse(gt.toString()) ?? 0.0;
            } else {
              for (var r in tableData) {
                orderTotal +=
                    double.tryParse(r[3].replaceAll('Rs ', '')) ?? 0.0;
              }
            }
            finalAmount += orderTotal;

            widget.add(pw.SizedBox(height: 10));
            widget.add(pw.Text("Order Date: $orderDateStr",
                style: pw.TextStyle(fontSize: 12, font: regularFont)));
            widget.add(pw.SizedBox(height: 6));

            widget.add(
              pw.Table.fromTextArray(
                headers: tableHeaders,
                data: tableData,
                headerStyle: pw.TextStyle(font: boldFont),
                headerDecoration:
                    pw.BoxDecoration(color: PdfColors.blueGrey800),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding:
                    const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                columnWidths: {
                  0: pw.FlexColumnWidth(4),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                },
                cellStyle: pw.TextStyle(font: boldFont, fontSize: 10),
              ),
            );

            widget.add(pw.SizedBox(height: 6));
            widget.add(
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                pw.Text("Order Total: ",
                    style: pw.TextStyle(font: boldFont, fontSize: 16)),
                pw.SizedBox(width: 6),
                pw.Text("Rs ${orderTotal.toStringAsFixed(2)}",
                    style: pw.TextStyle(fontSize: 16, font: regularFont)),
              ]),
            );
            widget.add(pw.Divider());
          }

          // Final Total
          widget.add(
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
              pw.Text("Total Payable Amount: ",
                  style: pw.TextStyle(fontSize: 14, font: boldFont)),
              pw.Text("Rs ${finalAmount.toStringAsFixed(2)}",
                  style: pw.TextStyle(fontSize: 16, font: regularFont))
            ]),
          );
          widget.add(pw.SizedBox(height: 10));
          widget.add(pw.Text("Thank You For Your Business",
              style: pw.TextStyle(fontSize: 16, font: boldFont)));

          return widget;
        },
      ));

      // Save PDF file
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          "${dir.path}/TeaBill_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Save bill record in Firestore
      final billsID = FirebaseFirestore.instance.collection('bills').doc().id;
      final billsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('bills')
          .doc(billsID);

      await billsCollection.set({
        'billID': billsID,
        'customerId': customerId,
        'customerName': custoname,
        'customerMobile': cusmob,
        'sellerId': uid,
        'sellerName': sellername,
        'sellerMobile': sellerMobile,
        'filePath': filePath,
        'finalAmount': finalAmount,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'generatedAt': DateTime.now().toIso8601String(),
      });

      // Update all orders to status N
      for (var order in customerOrders) {
        final docId = order['docId'];
        if (docId != null) {
          try {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .collection("orders")
                .doc(docId)
                .update({"status": "N"});
            print('Order $docId status updated to N');
          } catch (e) {
            print('Failed to update order $docId: $e');
          }
        }
      }

      return filePath;
    } catch (e) {
      print("PDF ERROR: $e");
      return "ERROR";
    }
  }

  String? validateOrder() {
    if (selectedCustomer == null) return "Please select a customer!";
    if (grandTotal <= 0) return "Please add item quantities!";
    return null;
  }

  //add order
  Future<void> addOrder(BuildContext c) async {
    final error = validateOrder();
    if (error != null) {
      ScaffoldMessenger.of(c).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("orders")
          .add({
        "sellerID": uid,
        "customer": selectedCustomer,
        "items": selectedItems,
        "grand_total": grandTotal,
        "createdAt": FieldValue.serverTimestamp(),
        "status": "Y",
      });

      ScaffoldMessenger.of(c).showSnackBar(const SnackBar(
        content: Text("Order Placed Successfully ✔"),
        backgroundColor: Colors.green,
      ));

      resetOrder();
    } catch (e) {
      ScaffoldMessenger.of(c).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  /// Reset after placing order
  void resetOrder() {
    selectedCustomer = null;

    selectedItems = originalItems.map((i) {
      return {
        "id": i["id"],
        "item_name": i["Itemname"],
        "item_price": double.tryParse(i["ItemPrice"].toString()) ?? 0.0,
        "qty": 0,
        "total": 0.0,
      };
    }).toList();

    grandTotal = 0.0;
    notifyListeners();
  }

  // -------------------------
  // FETCH ALL ORDERS
  // -------------------------
  List<Map<String, dynamic>> allOrders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  bool orderLoading = false;

  Future<void> fetchAllOrder() async {
    try {
      orderLoading = true;
      notifyListeners();

      final uid = FirebaseAuth.instance.currentUser!.uid;

      final snap = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("orders")
          .where("status", isEqualTo: "Y")
          .orderBy("createdAt", descending: true)
          .get();

      allOrders = snap.docs.map((d) => {"id": d.id, ...d.data()}).toList();
      //filteredOrders = List.from(allOrders);
      /*filteredOrders = snap.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        d['docId'] = doc.id;
        return d;
      }).toList();*/
      filteredOrders = snap.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        d['docId'] = doc.id;
        return d;
      }).toList();

      orderLoading = false;
      notifyListeners();
    } catch (e) {
      orderLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // -------------------------
  // FILTERS
  // -------------------------
  void filterByCustomer(String customerID) {
    filteredOrders = allOrders
        .where((o) => o["customer"]["id"].toString() == customerID)
        .toList();

    notifyListeners();
  }

  void filterByDate(DateTime start, DateTime end) {
    filteredOrders = allOrders.where((order) {
      final ts = order["createdAt"];
      if (ts == null) return false;

      final date = ts.toDate();
      return date.isAfter(start.subtract(const Duration(days: 1))) &&
          date.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    notifyListeners();
  }

  /// Combined filter: apply customer + date together
  void filter({String? customerID, DateTime? start, DateTime? end}) {
    filteredOrders = allOrders.where((order) {
      final orderCustomer = order["customer"]["id"].toString();

      bool customerMatch = customerID == null || customerID == orderCustomer;

      final ts = order["createdAt"];
      if (ts == null) return false;
      final date = ts.toDate();

      bool dateMatch = true;
      if (start != null && end != null) {
        dateMatch = date.isAfter(start.subtract(const Duration(days: 1))) &&
            date.isBefore(end.add(const Duration(days: 1)));
      }

      return customerMatch && dateMatch;
    }).toList();

    notifyListeners();
  }

  /// Reset all filters
  void resetFilters() {
    filteredOrders = List.from(allOrders);
    notifyListeners();
  }

  Future<void> deleteOrder(String orderId, BuildContext c) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("orders")
          .doc(orderId)
          .delete();

      allOrders.removeWhere((o) => o["id"] == orderId);
      filteredOrders.removeWhere((o) => o["id"] == orderId);
      notifyListeners();
      ScaffoldMessenger.of(c).showSnackBar(
          const SnackBar(content: Text("Order deleted successfully!")));
    } catch (e) {
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String docId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("orders")
        .doc(docId)
        .update({"status": "N"});
  }

  Future<void> updateOrder(
      String orderId, BuildContext c, Map<String, dynamic> newData) async {
    final error = validateOrder();
    if (error != null) {
      ScaffoldMessenger.of(c).showSnackBar(SnackBar(
        content: Text(error),
      ));
      return;
    }
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      /*final Map<String, dynamic> newData = {
        "customer": selectedCustomer,
        "items": selectedItems,
        "grand_total": grandTotal,
        "createdAt": FieldValue.serverTimestamp(),
      };*/
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("orders")
          .doc(orderId)
          .update(newData);

      /// Update in local list
      int index = allOrders.indexWhere((o) => o["id"] == orderId);
      if (index != -1) {
        allOrders[index] = {...allOrders[index], ...newData};
      }
      notifyListeners();
      ScaffoldMessenger.of(c).showSnackBar(
        SnackBar(content: Text("Order Updated SuccessFully")),
      );
      Navigator.pop(c, true);
    } catch (e) {
      print("Update error: $e");
    }
  }
}
