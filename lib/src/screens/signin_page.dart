import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uni_camp/src/screens/home_page.dart';

class SignInPage extends StatelessWidget {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  SignInPage({super.key});

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await firebaseAuth.signInWithCredential(credential);

      // Navigate to HomePage if sign-in succeeds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (error) {
      print('Sign in failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image.asset(
                      'assets/images/adduwhiteseal.png',
                      height: 240,
                    ),
                    const SizedBox(width: 70),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome to",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const Text(
                          "UniCamp",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 55,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "The school's official unversity campus finder",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        // line, like hr
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          height: 1,
                          width: 310,
                          color: const Color.fromARGB(255, 93, 97, 133),
                        ),

                        SizedBox(
                          width: 310,
                          child: ElevatedButton(
                              onPressed: () => signInWithGoogle(context),
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.white),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                fixedSize: WidgetStateProperty.all(
                                  const Size(150, 40),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image:
                                        AssetImage('assets/images/google.png'),
                                    height: 25,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Log in with Google',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
