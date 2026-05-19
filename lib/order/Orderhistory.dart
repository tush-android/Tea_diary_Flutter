/*import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:teadiary/order/updateOrder.dart';
import 'package:teadiary/provider/OrderProvider.dart';
import 'package:teadiary/provider/Customerpro.dart';

class Orderhistory extends StatefulWidget {
  const Orderhistory({super.key});

  @override
  State<Orderhistory> createState() => _OrderhistoryState();
}

class _OrderhistoryState extends State<Orderhistory> {
  DateTime? startdate;
  DateTime? enddate;
  String? selectedCustomerID;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<Orderpro>(context, listen: false).fetchAllOrder();
      Provider.of<Cusmanage>(context, listen: false).fetchcustomers();
    });
  }

  void applyFilters(Orderpro o) {
    o.filter(
      customerID: selectedCustomerID,
      start: startdate,
      end: enddate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = Provider.of<Orderpro>(context);
    final cus = Provider.of<Cusmanage>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text("Order History"),
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),
        body: o.orderLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await Provider.of<Orderpro>(context, listen: false)
                      .fetchAllOrder();
                  applyFilters(o);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // ------------------------
                      // CUSTOMER DROPDOWN
                      // ------------------------
                      DropdownButtonFormField<String>(
                        value: selectedCustomerID,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Select Customer",
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text("All Customers")),
                          ...cus.customers.map((c) {
                            return DropdownMenuItem(
                                value: c["id"].toString(),
                                child: Text(c["name"]));
                          })
                        ],
                        onChanged: (val) {
                          setState(() => selectedCustomerID = val);
                          applyFilters(o);
                        },
                      ),

                      const SizedBox(height: 15),
                      Row(
                        children: [
                          if (selectedCustomerID != null &&
                              o.filteredOrders.isNotEmpty)
                            SizedBox(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    final pdfPath =
                                        await o.generateCustomerBillPDF(
                                      customerID: selectedCustomerID!,
                                      start: startdate,
                                      end: enddate,
                                    );

                                    if (pdfPath == null || pdfPath.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text("No bill generated")));
                                      return;
                                    }

                                    final result = await OpenFile.open(pdfPath);

                                    if (result.type != ResultType.done) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Cannot open PDF: ${result.message}")));
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Error: $e")));
                                  }
                                },
                                label: Text(
                                  "Genrate Bill",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (d != null) {
                                  setState(() => startdate = d);
                                  applyFilters(o);
                                }
                              },
                              child: Text(startdate == null
                                  ? "Start Date"
                                  : startdate.toString().split(" ")[0]),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (d != null) {
                                  setState(() => enddate = d);
                                  applyFilters(o);
                                }
                              },
                              child: Text(enddate == null
                                  ? "End Date"
                                  : enddate.toString().split(" ")[0]),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ------------------------
                      // RESET FILTERS
                      // ------------------------
                      ElevatedButton(
                        onPressed: () {
                          o.resetFilters();
                          setState(() {
                            startdate = null;
                            enddate = null;
                            selectedCustomerID = null;
                          });
                        },
                        child: const Text("Reset Filters"),
                      ),

                      const SizedBox(height: 20),

                      // ------------------------
                      // ORDER LIST DISPLAY
                      // ------------------------
                      Expanded(
                        child: o.filteredOrders.isEmpty
                            ? const Center(
                                child: Text(
                                  "No Orders Found",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.redAccent),
                                ),
                              )
                            : ListView.builder(
                                itemCount: o.filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = o.filteredOrders[index];
                                  /*return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 3,
                                child: ListTile(
                                  title: Text(
                                    order["customer"]["name"],
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  subtitle: Text(
                                    "Total: ₹${order['grand_total']}\n"
                                    "Date: ${order['createdAt']?.toDate().toString().split('.')[0]}",
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),
                                  trailing: IconButton(
                                    alignment: Alignment.topRight,
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.cyan,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              );
                            */
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 3,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: ListTile(
                                            title: Text(
                                              order["customer"]["name"],
                                              style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue),
                                            ),
                                            subtitle: Text(
                                              "Total: ₹${order['grand_total']}\n"
                                              "Date: ${order['createdAt']?.toDate().toString().split('.')[0]}",
                                              style: TextStyle(
                                                  color: Colors.grey.shade700),
                                            ),
                                          ),
                                        ),
                                        /*IconButton(
                                      alignment: Alignment.topRight,
                                      icon: const Icon(Icons.edit,
                                          color: Colors.cyan),
                                      onPressed: () {},
                                    )*/
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == "edit") {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Updateorder(
                                                              orderData: order),
                                                    ));
                                                //to bo decided
                                              }
                                              if (value == "delete") {
                                                showDialog(
                                                    context: context,
                                                    builder: (c) => AlertDialog(
                                                          title: Text(
                                                            "Are You Sure You Want To Delete This Order?",
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      c);
                                                                },
                                                                child: Text(
                                                                    "Cancel")),
                                                            TextButton(
                                                                onPressed: () {
                                                                  Provider.of<Orderpro>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .deleteOrder(
                                                                          order[
                                                                              "id"],
                                                                          context);
                                                                  Navigator.pop(
                                                                      c);
                                                                },
                                                                child: Text(
                                                                  "Delete",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                          ],
                                                        ));
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.edit,
                                                        color: Colors.cyan,
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text("Edit Order"),
                                                    ],
                                                  )),
                                              const PopupMenuItem(
                                                  value: "delete",
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text("Delete Order"),
                                                    ],
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ));
  }
}

*/

/** if (orderPro.selectedCustomer != null)
                SizedBox(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final res = await orderPro.generateCustomerBillPDF(
                          customerId: orderPro.selectedCustomer!["id"]);
                      if (res == "NO_ORDERS") {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No orders found!")));
                      } else if (res != "ERROR") {
                        OpenFile.open(res); // show PDF
                      }
                    },
                    label: Text(
                      "Genrate Bill",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                )
 */
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:teadiary/order/updateOrder.dart';
import 'package:teadiary/provider/OrderProvider.dart';
import 'package:teadiary/provider/Customerpro.dart';

class Orderhistory extends StatefulWidget {
  const Orderhistory({super.key});

  @override
  State<Orderhistory> createState() => _OrderhistoryState();
}

class _OrderhistoryState extends State<Orderhistory> {
  DateTime? startdate;
  DateTime? enddate;
  String? selectedCustomerID;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<Orderpro>(context, listen: false).fetchAllOrder();
      Provider.of<Cusmanage>(context, listen: false).fetchcustomers();
    });
  }

  void applyFilters(Orderpro o) {
    o.filter(
      customerID: selectedCustomerID,
      start: startdate,
      end: enddate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = Provider.of<Orderpro>(context);
    final cus = Provider.of<Cusmanage>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: o.orderLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await Provider.of<Orderpro>(context, listen: false)
                    .fetchAllOrder();
                applyFilters(o);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Customer Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedCustomerID,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Select Customer",
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text("All Customers")),
                        ...cus.customers.map(
                          (c) => DropdownMenuItem(
                            value: c["id"].toString(),
                            child: Text(c["name"]),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => selectedCustomerID = val);
                        applyFilters(o);
                      },
                    ),
                    const SizedBox(height: 15),
                    // Start & End Date Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (d != null) {
                                setState(() => startdate = d);
                                applyFilters(o);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                                startdate == null
                                    ? "Start Date"
                                    : startdate.toString().split(" ")[0],
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (d != null) {
                                setState(() => enddate = d);
                                applyFilters(o);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                                enddate == null
                                    ? "End Date"
                                    : enddate.toString().split(" ")[0],
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              o.resetFilters();
                              setState(() {
                                startdate = null;
                                enddate = null;
                                selectedCustomerID = null;
                              });
                              ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightBlue,
                                  foregroundColor: Colors.white);
                            },
                            child: const Text("Reset Filters"),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        if (selectedCustomerID != null &&
                            o.filteredOrders.isNotEmpty)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  final pdfpath =
                                      await o.generateCustomerBillPDF(
                                          customerId: selectedCustomerID!,
                                          startDate: startdate,
                                          endDate: enddate);
                                  if (pdfpath == null || pdfpath.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "No Bill Generated....!")));
                                    return;
                                  }
                                  /*final result = await OpenFilex.open(pdfpath);
                                  if (result.type != ResultType.done) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Cannot open PDF: ${result.message}")),
                                    );
                                  }*/
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Bill Generated Successfully...!",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  await Provider.of<Orderpro>(context,
                                          listen: false)
                                      .fetchAllOrder();
                                  // Re-apply filters
                                  o.filter(
                                    customerID: selectedCustomerID,
                                    start: startdate,
                                    end: enddate,
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e")),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.picture_as_pdf,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Generate Bill",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Reset Filter
                    const SizedBox(height: 20),
                    // Order List Display
                    Expanded(
                      child: o.filteredOrders.isEmpty
                          ? const Center(
                              child: Text("No Orders Found",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.redAccent)),
                            )
                          : ListView.builder(
                              itemCount: o.filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = o.filteredOrders[index];
                                /*return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 3,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: ListTile(
                                            title: Text(
                                              order["customer"]["name"],
                                              style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue),
                                            ),
                                            subtitle: Text(
                                              "Total:Rs. ${order['grand_total']}\n"
                                              "Date: ${order['createdAt']?.toDate()?.toString().split('.')[0]}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: PopupMenuButton<String>(
                                              onSelected: (value) {
                                                if (value == "edit") {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Updateorder(
                                                              orderData: order),
                                                    ),
                                                  );
                                                }
                                                if (value == "delete") {
                                                  showDialog(
                                                      context: context,
                                                      builder:
                                                          (c) => AlertDialog(
                                                                title: Text(
                                                                  "Are You Sure You Want To Delete This Order?",
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator
                                                                            .pop(c);
                                                                      },
                                                                      child: Text(
                                                                          "Cancel")),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Provider.of<Orderpro>(context, listen: false).deleteOrder(
                                                                            order["id"],
                                                                            context);
                                                                        Navigator
                                                                            .pop(c);
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        "Delete",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red),
                                                                      ))
                                                                ],
                                                              ));
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                    const PopupMenuItem(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.edit,
                                                              color:
                                                                  Colors.cyan,
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text("Edit Order"),
                                                          ],
                                                        )),
                                                    const PopupMenuItem(
                                                        value: "delete",
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                                "Delete Order"),
                                                          ],
                                                        ))
                                                  ]),
                                        )
                                      ],
                                    ));
                                */
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 3,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            order["customer"]["name"],
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "Total: ₹${order['grand_total']}\n"
                                            "Date: ${order['createdAt']?.toDate().toString().split('.')[0]}",
                                            style: TextStyle(
                                                color: Colors.grey.shade700),
                                          ),
                                        ),
                                      ),

                                      // ---------------------
                                      // FIXED POPUP MENU
                                      // ---------------------
                                      PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          // ----- EDIT ORDER -----
                                          if (value == "edit") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    Updateorder(
                                                        orderData: order),
                                              ),
                                            );
                                          }

                                          // ----- DELETE ORDER -----
                                          else if (value == "delete") {
                                            showDialog(
                                              context: context,
                                              builder: (c) => AlertDialog(
                                                title:
                                                    const Text("Delete Order"),
                                                content: const Text(
                                                    "Are you sure you want to delete this order?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(c),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.pop(
                                                          c); // close dialog first

                                                      try {
                                                        await Provider.of<
                                                                    Orderpro>(
                                                                context,
                                                                listen: false)
                                                            .deleteOrder(
                                                                order["id"],
                                                                context);

                                                        // Refresh after delete
                                                        await Provider.of<
                                                                    Orderpro>(
                                                                context,
                                                                listen: false)
                                                            .fetchAllOrder();
                                                        applyFilters(Provider
                                                            .of<Orderpro>(
                                                                context,
                                                                listen: false));

                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                "Order deleted successfully"),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                "Delete failed: $e"),
                                                            backgroundColor:
                                                                Colors
                                                                    .redAccent,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: const Text(
                                                      "Delete",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: "edit",
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit,
                                                    color: Colors.blue),
                                                SizedBox(width: 10),
                                                Text("Edit Order"),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: "delete",
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete,
                                                    color: Colors.red),
                                                SizedBox(width: 10),
                                                Text("Delete Order"),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
