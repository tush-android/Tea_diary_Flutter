import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teadiary/provider/authProvider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: authProvider.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 30),

              // Full Name
              TextFormField(
                controller: authProvider.nameController,
                validator: authProvider.validateName,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person, color: Colors.green),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: authProvider.emailController,
                validator: authProvider.validateEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email, color: Colors.green),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: authProvider.phoneController,
                validator: authProvider.validatePhone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: Icon(Icons.phone, color: Colors.green),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: authProvider.passwordController,
                validator: authProvider.validatePassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock, color: Colors.green),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              //Shop name
              TextFormField(
                controller: authProvider.shpcontroller,
                validator: authProvider.validateshopname,
                decoration: InputDecoration(
                  labelText: "Enter You Shp Name",
                  prefixIcon: Icon(
                    Icons.local_convenience_store_rounded,
                    color: Colors.green,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              //Address
              TextFormField(
                controller: authProvider.addressControllr,
                validator: authProvider.validateAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.location_on,
                    color: Colors.green,
                  ),
                  labelText: 'Enter Your Address',
                ),
              ),
              SizedBox(
                height: 30,
              ),
              // Signup Button
              Center(
                child: authProvider.isLoading
                    ? CircularProgressIndicator(
                        color: Colors.green,
                      )
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: const Text(
                          "Sign Up",
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
                        onPressed: () => authProvider.submitSignup(context),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
