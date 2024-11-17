import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uni_camp/src/screens/signin_page.dart';
import 'package:google_fonts/google_fonts.dart';

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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "ERROR 401: Unauthorized Access",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.jost().fontFamily,
                  ),
                ),
                const Text(
                  "You Do Not Have Access To This Page.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 185, 185, 185),
                    fontWeight: FontWeight.normal,
                    // fontFamily: GoogleFonts.jost().fontFamily,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  height: 30,
                  child: Stack(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignInPage()),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              const Color.fromARGB(255, 255, 255, 255)),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          fixedSize: WidgetStateProperty.all(
                            const Size(200, 30),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Return to sign-in page',
                              style: TextStyle(
                                color: Color.fromARGB(255, 22, 22, 22),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
