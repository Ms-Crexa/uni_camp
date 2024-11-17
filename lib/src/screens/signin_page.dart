import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'unauthorized_page.dart';

class SignInPage extends StatelessWidget {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  SignInPage({super.key});

  Future<void> signInWithGoogle(BuildContext context) async {
    isLoading.value = true;
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = await firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Save the user information in Firestore if they don't exist
          await firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'role': 'student',
          });
        }

        // Retrieve the user's role after saving their data
        final updatedUserDoc =
            await firestore.collection('users').doc(user.uid).get();
        final role = updatedUserDoc['role'];

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UnauthorizedPage()),
          );
        }
      }
    } catch (error) {
      print('Sign in failed: $error');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = firebaseAuth.currentUser;

    if (currentUser != null) {
      // Check the user's role
      return FutureBuilder<DocumentSnapshot>(
        future: firestore.collection('users').doc(currentUser.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            final role = snapshot.data?['role'];
            if (role == 'admin') {
              return HomePage();
            } else {
              // Automatically log out if not an admin
              firebaseAuth.signOut();
              return const UnauthorizedPage();
            }
          }

          return const Scaffold(
            body: Center(child: Text("Error retrieving user role.")),
          );
        },
      );
    }

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                            "The school's official university campus finder",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            height: 1,
                            width: 310,
                            color: const Color.fromARGB(255, 93, 97, 133),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: isLoading,
                            builder: (context, loading, child) {
                              return loading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : SizedBox(
                                      width: 300,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            signInWithGoogle(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          fixedSize: const Size(150, 40),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image(
                                              image: AssetImage(
                                                  'assets/images/google.png'),
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
                                        ),
                                      ),
                                    );
                            },
                          ),
                        ],
                      ),
                    ],
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
