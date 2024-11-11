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
              height: 300,
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [


                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/adduwhiteseal.png', height: 110,),
                      const SizedBox(width: 10,),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('University', style: TextStyle(
                            color: Color.fromARGB(255, 156, 156, 156),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Campus', style: TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Finder', style: TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // line, like hr
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    height: 1,
                    width: 250,
                    color: const Color.fromARGB(255, 93, 97, 133),
                  ),

                  const Text('Welcome back!', style: TextStyle(
                    color: Color.fromARGB(255, 228, 228, 228),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),
                  const Text('Login to', style: TextStyle(
                    color: Color.fromARGB(255, 109, 109, 109),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () => signInWithGoogle(context),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.white),
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
                        Image(image: AssetImage('assets/images/google.png'), height: 25,),
                        SizedBox(width: 10),
                        Text('Google', style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),),
                      ],
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}