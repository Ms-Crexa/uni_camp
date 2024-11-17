import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uni_camp/src/screens/signin_page.dart';

class UnauthorizedPage extends StatefulWidget {
  const UnauthorizedPage({super.key});

  @override
  State<UnauthorizedPage> createState() => _UnauthorizedPageState();
}

class _UnauthorizedPageState extends State<UnauthorizedPage> {
  @override
  Widget build(BuildContext context) {
    // Log out the user automatically when accessing this page
    FirebaseAuth.instance.signOut();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Access Denied"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "You do not have access to this page.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
              child: const Text("Go to Sign In"),
            ),
          ],
        ),
      ),
    );
  }
}
