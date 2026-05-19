import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teadiary/Dashboard/Login.dart';
import 'package:teadiary/provider/authProvider.dart';
import 'package:teadiary/auth/signup.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tea Diary',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Welcome Texts
            const Text(
              "Welcome to",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 22, 69, 108),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Tea Diary 2.0",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.green,
                letterSpacing: 1.1,
              ),
            ),

            const SizedBox(height: 25),

            // Animated GIF Card
            Container(
              width: screenWidth * 0.8,
              height: screenHeight * 0.35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/logo/kettle.gif',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Info text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'A smart way to manage your customers, items, and daily sales — all in one place!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Buttons Row
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  },
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupScreen()));
                  },
                  label: Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  icon: Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    minimumSize: Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
