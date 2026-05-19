import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teadiary/provider/authProvider.dart' as myAuth;

class Itempro with ChangeNotifier {
  String erm = "";
  List<Map<String, dynamic>> Items = [];
  bool isLoading = false;

  final formkey = GlobalKey<FormState>();
  final itemnamecontroller = TextEditingController();
  final itempricecontroller = TextEditingController();

  // ------------------ VALIDATIONS ------------------

  String? validateItemName(String? value) {
    if (value == null || value.isEmpty) return "Enter Item Name!";
    if (value.length < 2) return "Enter at least 2 letters!";
    return null;
  }

  String? validateItemPrice(String? value) {
    if (value == null || value.isEmpty) return "Enter Item Price!";
    final price = double.tryParse(value);
    if (price == null || price <= 0 || price >= 100000) {
      return "Price must be between 1 to 10000";
    }
    return null;
  }

  // ------------------ CLEAR FIELDS ------------------

  void clearFields() {
    itemnamecontroller.clear();
    itempricecontroller.clear();
  }

  // ------------------ ADD ITEM ------------------

  Future<void> addItem(BuildContext context) async {
    if (!formkey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors first❌'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final authProvider =
          Provider.of<myAuth.AuthProvider>(context, listen: false);
      final sellerData = authProvider.cudata;

      final currentUser = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('Items')
          .add({
        'Itemname': itemnamecontroller.text.trim(),
        'ItemPrice': itempricecontroller.text.trim(),
        'seller_uid': sellerData!['uid'],
        'seller_name': sellerData['name'],
        'shop_name': sellerData['shopname'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Item Added Successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      clearFields();

      // ⭐ IMPORTANT → Reload list
      await fetchItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ------------------ FETCH ITEMS ------------------

  Future<void> fetchItems() async {
    isLoading = true;
    notifyListeners();

    try {
      final cu = FirebaseAuth.instance.currentUser;

      if (cu == null) {
        erm = "User not logged in!";
        Items = [];
        return;
      }

      final qu = await FirebaseFirestore.instance
          .collection('users')
          .doc(cu.uid)
          .collection('Items')
          .orderBy('createdAt', descending: true)
          .get();

      Items = qu.docs.map((doc) {
        return {
          "id": doc.id,
          "Itemname": doc["Itemname"],
          "ItemPrice": doc["ItemPrice"],
        };
      }).toList();

      erm = "";
    } catch (e) {
      erm = e.toString();
      Items = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
