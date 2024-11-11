import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uni_camp/src/screens/signin_page.dart';


final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

Future<void> signOut(BuildContext context) async {
    await firebaseAuth.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  final User? user;
  const MyAppBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      iconTheme: const IconThemeData(color: Colors.black),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${user?.displayName}'),
              const SizedBox(width: 10),
              SizedBox(
                height: 40,
                width: 40,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user?.photoURL ?? ''),
                  radius: 40,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => signOut(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
