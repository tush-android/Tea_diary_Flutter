import 'package:flutter/material.dart';
import 'package:teadiary/provider/Customerpro.dart' as csk;
import 'package:provider/provider.dart';

class addnewcus extends StatelessWidget {
  const addnewcus({super.key});

  @override
  Widget build(BuildContext context) {
    final ask = Provider.of<csk.Cusmanage>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'ADD NEW Customer',
          ),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: ask.formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  controller: ask.namecontroller,
                  validator: ask.validateName,
                  decoration: InputDecoration(
                    hintText: "Enter New Customer Name",
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.green,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: ask.mobilecontroller,
                  validator: ask.validateMobile,
                  decoration: InputDecoration(
                    hintText: "Enter Customer Mobile No ",
                    prefixIcon: Icon(
                      Icons.phone,
                      color: Colors.green,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: ask.addresscontroller,
                  validator: ask.validateAddress,
                  decoration: InputDecoration(
                    hintText: "Enter Customer Address",
                    prefixIcon: Icon(
                      Icons.home,
                      color: Colors.green,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => ask.addCustomer(context),
                    icon: Icon(Icons.done),
                    label: const Text(
                      "Add Customer",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        )),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
