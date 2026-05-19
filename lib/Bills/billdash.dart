import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../provider/BillProvider.dart';

class BillHistoryScreen extends StatefulWidget {
  @override
  _BillHistoryScreenState createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends State<BillHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<Billprovider>(context, listen: false).fetchAllBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Bills")),
      body: Consumer<Billprovider>(
        builder: (context, p, _) {
          if (p.isbillLoad) {
            return Center(child: CircularProgressIndicator());
          }

          if (p.allBills.isEmpty) {
            return Center(child: Text("No Bills Found"));
          }

          return ListView.builder(
            itemCount: p.allBills.length,
            itemBuilder: (context, index) {
              final bill = p.allBills[index];

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  onTap: () {
                    OpenFilex.open(bill['filePath']);
                  },
                  title: Text(
                    "₹${bill['finalAmount']}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Customer: ${bill['customerName']}\nDate: ${bill['generatedAt']}",
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.share, color: Colors.green),
                    onPressed: () {
                      Share.shareXFiles([XFile(bill['filePath'])]);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
