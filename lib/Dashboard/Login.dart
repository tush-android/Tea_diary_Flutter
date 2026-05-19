import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teadiary/provider/authProvider.dart' as asp;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final password = TextEditingController();
  final formkey = GlobalKey<FormState>();
  bool ioLoading = false;
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<asp.AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: authProvider.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Login...!',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.blue),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: authProvider.emailController,
                decoration: InputDecoration(
                  labelText: "Enter Your Email Address....!",
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.green,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: authProvider.validateEmail,
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: authProvider.passwordController,
                validator: authProvider.validatePassword,
                decoration: InputDecoration(
                  labelText: "Enter Your Password",
                  prefixIcon: Icon(Icons.lock, color: Colors.green),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.orange,
                      )
                    : ElevatedButton.icon(
                        onPressed: () => authProvider.LoginUser(context),
                        icon: Icon(Icons.check),
                        label: const Text(
                          'Login',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
