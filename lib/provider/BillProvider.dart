import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/*class Billprovider with ChangeNotifier {
  bool _isbillLoad = false;
  bool get isbillLoad => _isbillLoad;
  List<Map<String, dynamic>> _customerBills = [];
  List<Map<String, dynamic>> get customerBills => _customerBills;
  Future<void> fetchCustomerBills(String customerID) async {
    try {
      _isbillLoad = true;
      notifyListeners();
      final snap = await FirebaseFirestore.instance
          .collection("bills")
          .where("customerID", isEqualTo: customerID)
          .orderBy("generatedAt", descending: true)
          .get();
      _customerBills = snap.docs.map((doc) {
        final d = doc.data();
        d['docId'] = doc.id;
        return d;
      }).toList();
      _isbillLoad = false;
      notifyListeners();
    } catch (e) {
      _isbillLoad = false;
      notifyListeners();
      print("FETCH BILL ERROR: $e");
    }
  }
}

Future<void> fetchAllBills() async {
  try {
    billLoading = true;
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("bills")
        .orderBy("createdAt", descending: true)
        .get();

    bills = snap.docs.map((doc) {
      return {
        "billId": doc.id,
        ...doc.data(),
      };
    }).toList();

    billLoading = false;
    notifyListeners();
  } catch (e) {
    billLoading = false;
    notifyListeners();
    print("Error fetching bills: $e");
  }
}*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Billprovider with ChangeNotifier {
  bool isbillLoad = false;
  List<Map<String, dynamic>> allBills = [];

  Future<void> fetchAllBills() async {
    try {
      isbillLoad = true;
      notifyListeners();
      final user = FirebaseAuth.instance.currentUser;

      final snap = await FirebaseFirestore.instance
          /** .collection('users')
          .doc(user!.uid)
          .collection('customers') */
          .collection("users")
          .doc(user!.uid)
          .collection('bills')
          .orderBy("generatedAt", descending: true)
          .get();

      allBills = snap.docs.map((doc) {
        final d = doc.data();
        d['docId'] = doc.id;
        return d;
      }).toList();

      isbillLoad = false;
      notifyListeners();
    } catch (e) {
      isbillLoad = false;
      notifyListeners();
      print("FETCH ALL BILLS ERROR: $e");
    }
  }
}
