import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'unauthorized_page.dart';
import 'package:google_fonts/google_fonts.dart';

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
              return const HomePage();
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
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image.asset(
                      'assets/images/LOGOMARK.png',
                      height: 330,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome to",
                          style: TextStyle(
                            color: Color.fromARGB(255, 153, 153, 153),
                            fontSize: 20,
                            fontFamily: 'LeagueSpartan',
                            fontVariations: [
                              FontVariation('wght', 300),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "UniCamp",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontFamily: 'LeagueSpartan',
                            fontVariations: [
                              FontVariation('wght', 900),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "AdDU’s Official University Campus Finder",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 153, 153, 153),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: GoogleFonts.jost().fontFamily),
                        ),
                        // line, like hr
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 1,
                          width: 260,
                          color: const Color.fromARGB(255, 93, 97, 133),
                        ),

                        SizedBox(
                          width: 260,
                          height: 40,
                          child: Stack(
                            children: [
                              ElevatedButton(
                                onPressed: () => signInWithGoogle(context),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      const Color.fromARGB(255, 255, 255, 255)),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  fixedSize: WidgetStateProperty.all(
                                    const Size(260, 40),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Image(
                                      image: AssetImage('assets/images/google.png'),
                                      height: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Sign-in with Google',
                                      style: TextStyle(
                                        color: const Color.fromARGB(255, 22, 22, 22),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                        fontFamily: GoogleFonts.jost().fontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Overlay when isLoading is active
                              ValueListenableBuilder<bool>(
                                valueListenable: isLoading,
                                builder: (context, loading, child) {
                                  if (!loading) return const SizedBox.shrink();

                                  return Container(
                                    width: 260,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20, // Smaller size
                                        height: 20, // Smaller size
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2, // Optional: Make the stroke thinner
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Color.fromARGB(255, 255, 255, 255),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
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
