// ignore: file_names

// ignore_for_file: unused_local_variable, duplicate_ignore, file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'GlobalData.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ThirdPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PhoneEntryPage extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  PhoneEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          // Use ListView for scrolling
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.60, // Adjust the height as needed
              child: Image.asset('assets/ig.jpg'),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome to ZuppCart',
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            // color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'To get started, press the below button',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final GoogleSignInAccount? googleUser =
                            await googleSignIn.signIn();
                        await googleSignIn.requestScopes([
                          'https://www.googleapis.com/auth/userinfo.profile'
                        ]);

                        final GoogleSignInAuthentication googleAuth =
                            await googleUser!.authentication;
                        // ignore: unused_local_variable
                        final AuthCredential credential =
                            GoogleAuthProvider.credential(
                          accessToken: googleAuth.accessToken,
                          idToken: googleAuth.idToken,
                        );
                        final UserCredential authResult =
                            await _auth.signInWithCredential(credential);
                        final User? user = authResult.user;
                        final String userToken = authResult.user!.uid;

                        final FlutterSecureStorage storage =
                            FlutterSecureStorage();
                        await storage.write(
                            key: 'auth_token', value: userToken);
                        // Fetch user profile information
                        final GoogleSignInAccount? currentUser =
                            googleSignIn.currentUser;

                        // Access the user's profile data
                        if (currentUser != null) {
                          // Access the user's profile data
                          final String? name = currentUser.displayName;
                          final String email = currentUser.email;

                          // Set 'userName' and 'userEmail' in GlobalData
                          GlobalData.setUserProfile(name, email);
                        }

                        // Navigate to the SecondPage with a leftward swipe transition
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                const ThirdPage(), // Replace SecondPage() with your SecondPage
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(
                                CurveTween(curve: curve),
                              );
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      } catch (error) {
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          SnackBar(
                            content: Text(
                                'Error: $error'), // Display the error message
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.white, // Use Google's brand blue color
                      padding: const EdgeInsets.all(0),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 5.0,
                      alignment: Alignment.center,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20), // Adjust padding as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/g.jpg', // Replace with your Google logo image asset
                            height: 40, // Adjust the height to fit your design
                            width: 40, // Adjust the width to fit your design
                          ),
                          const SizedBox(
                              width:
                                  10), // Add some spacing between the logo and text
                          Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue[800], // Use white text color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
