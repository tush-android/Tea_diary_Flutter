import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teadiary/provider/Itempro.dart' as ask;

class AddItem extends StatelessWidget {
  const AddItem({super.key});

  @override
  Widget build(BuildContext context) {
    final authprovider = Provider.of<ask.Itempro>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Item"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: authprovider.formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                    controller: authprovider.itemnamecontroller,
                    validator: authprovider.validateItemName,
                    decoration: InputDecoration(
                      hintText: "Enter Item Name ",
                      prefixIcon: Icon(
                        Icons.shopping_bag,
                        color: Colors.green,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    )),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: authprovider.itempricecontroller,
                  validator: authprovider.validateItemPrice,
                  decoration: InputDecoration(
                      hintText: "Enter Item Price",
                      prefixIcon: Icon(
                        Icons.currency_rupee,
                        color: Colors.green,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton.icon(
                  onPressed: () => authprovider.addItem(context),
                  label: Text(
                    "Add New Item",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: Icon(Icons.done),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
