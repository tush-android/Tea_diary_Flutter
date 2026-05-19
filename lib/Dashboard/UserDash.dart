import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teadiary/Items/itemdash.dart';
import 'package:teadiary/dashmenu/addcustomer.dart';
import 'package:teadiary/order/Orderhistory.dart';
import 'package:teadiary/order/orderdash.dart';
import 'package:teadiary/Bills/billdash.dart';
import 'package:teadiary/provider/authProvider.dart' as myAuth;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    final authProvider =
        Provider.of<myAuth.AuthProvider>(context, listen: false);
    authProvider.getuserdata();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<myAuth.AuthProvider>(context);
    final userName = authProvider.cudata?['name'] ?? '';
    final shpname = authProvider.cudata?['shopname'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🟩 Welcome Card
            Card(
              color: Colors.orange.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Welcome, $userName 👋',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is your Tea Diary Dashboard!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Image.asset(
                      'assets/logo/employee.gif',
                      height: 100,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.store, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          shpname,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 🟦 Menu Section
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                dashboardMenu(
                    context, "Customer's", 'assets/logo/add user.gif'),
                dashboardMenu(context, "Item's", 'assets/logo/additem1.gif'),
                dashboardMenu(context, "Order's", 'assets/logo/neworder.gif'),
                dashboardMenu(context, "History & Billing",
                    'assets/logo/history-book.gif'),
                dashboardMenu(context, 'Bills', 'assets/logo/invoice-bill.gif'),
                //dashboardMenu(context, 'Settings', 'assets/gifs/settings.gif'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔶 Reusable Dashboard Card Widget with GIF on right side
  Widget dashboardMenu(BuildContext context, String title, String gifPath) {
    return InkWell(
      onTap: () {
        if (title == "Customer's") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const cusdash()));
        }
        if (title == "Item's") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Itemdash()));
        }
        if (title == "Order's") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Orderdash()));
        }
        if (title == "History & Billing") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Orderhistory()));
        }
        if (title == "Bills") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => BillHistoryScreen()));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          /*gradient: const LinearGradient(
            colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),*/
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  gifPath,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
