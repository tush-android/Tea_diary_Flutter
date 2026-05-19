import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teadiary/Dashboard/UserDash.dart';
import 'package:teadiary/Dashboard/Login.dart';

class AuthProvider with ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressControllr = TextEditingController();
  final shpcontroller = TextEditingController();
  bool isLoading = false;
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Map<String, dynamic>? cudata;

  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Enter your name';
    if (value.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Enter your email';
    final emailRegex = RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Enter phone number';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value))
      return 'Enter 10 digit phone number';
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) return 'Enter Address';
    if (value.length <= 3) {
      return ("Enter At Least 3 Letters....!");
    }
    return null;
  }

  String? validateshopname(String? value) {
    if (value == null || value.isEmpty) return 'Enter Shop Name First...!';
    if (value.length <= 3) {
      return "Enter At Least 3 Letters....!";
    }
    return null;
  }

  void submitSignup(BuildContext context) async {
    /*if (formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form submitted successfully 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix errors before submitting ❌'),
          backgroundColor: Colors.red,
        ),
      );
    }*/
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Please fix errors before submitting ❌',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 234, 109, 100),
      ));
      return;
    }

    notifyListeners();
    try {
      setLoading(true);
      final auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressControllr.text.trim(),
        'shopname': shpcontroller.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      await getuserdata();
      clearForm();
      setLoading(false);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const Dashboard()));
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      String errorMessage = 'Something went wrong';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> LoginUser(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    try {
      setLoading(true);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await getuserdata();
      setLoading(false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Dashboard()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (r) {
      setLoading(false);
      String message = "Invalid Credentials";
      if (r.code == 'wrong-password') {
        message = "Wrong-Password!!!";
      } else if (r.code == "user-not-found") {
        message = "User Not Found...!";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  // Clear controllers if needed
  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
    addressControllr.clear();
    shpcontroller.clear();
  }

  Future<void> getuserdata() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        cudata = doc.data();
        notifyListeners();
      }
    }
  }

  //Login
}
