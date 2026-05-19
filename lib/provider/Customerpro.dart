import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:teadiary/provider/authProvider.dart' as myAuth;

class Cusmanage with ChangeNotifier {
  List<Map<String, dynamic>> customers = [];
  String erm = "";
  bool isLoading = false;

  final formkey = GlobalKey<FormState>();
  final namecontroller = TextEditingController();
  final mobilecontroller = TextEditingController();
  final addresscontroller = TextEditingController();

  // ------------------ VALIDATIONS ------------------

  String? validateName(String? value) {
    if (value == null || value.isEmpty) return "Enter Customer Name";
    if (value.length < 3) return "Name must contain 3 letters";
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Enter mobile no";
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return "Enter 10 digit number";
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) return "Enter address";
    if (value.length < 3) return "Address too short";
    return null;
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // ------------------ ADD CUSTOMER ------------------

  Future<void> addCustomer(BuildContext context) async {
    if (!formkey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fix errors first ❌'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    _setLoading(true);

    try {
      final authProvider =
          Provider.of<myAuth.AuthProvider>(context, listen: false);
      final sellerData = authProvider.cudata;

      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('customers')
          .add({
        'name': namecontroller.text.trim(),
        'mobile': mobilecontroller.text.trim(),
        'address': addresscontroller.text.trim(),
        'seller_uid': sellerData!['uid'],
        'seller_name': sellerData['name'],
        'shop_name': sellerData['shopname'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Customer added successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );

      clearForm();

      // ⭐ IMPORTANT: Reload list
      await fetchcustomers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      _setLoading(false);
    }
  }

  // ------------------ FETCH CUSTOMERS ------------------

  Future<void> fetchcustomers() async {
    try {
      isLoading = true;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        customers = [];
        erm = "User not logged in";
        return;
      }

      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('customers')
          .orderBy('createdAt', descending: true)
          .get();

      customers = query.docs.map((doc) {
        return {
          "id": doc.id,
          "name": doc["name"],
          "mobile": doc["mobile"],
          "address": doc["address"],
        };
      }).toList();

      erm = "";
    } catch (e) {
      erm = e.toString();
      customers = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearForm() {
    namecontroller.clear();
    mobilecontroller.clear();
    addresscontroller.clear();
  }
}
