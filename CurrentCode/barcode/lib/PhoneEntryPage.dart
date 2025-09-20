// ignore_for_file: file_names, prefer_const_constructors, use_key_in_widget_constructors, use_build_context_synchronously, avoid_print, deprecated_member_use, prefer_const_constructors_in_immutables, library_private_types_in_public_api, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'CartNumberPage.dart';
import 'GlobalData.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class PhoneEntryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'To get started, press the below button',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final GoogleSignInAccount? googleUser =
                          await googleSignIn.signIn();
                      await googleSignIn.requestScopes(
                          ['https://www.googleapis.com/auth/userinfo.profile']);

                      final GoogleSignInAuthentication googleAuth =
                          await googleUser!.authentication;
                      final AuthCredential credential =
                          GoogleAuthProvider.credential(
                        accessToken: googleAuth.accessToken,
                        idToken: googleAuth.idToken,
                      );

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

                        // Now you can use 'name', 'email', and 'photoUrl' as needed
                        print('Name: $name');
                        print('Email: $email');
                      }

                      // Navigate to the SecondPage with a leftward swipe transition
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation,
                                  secondaryAnimation) =>
                              ThirdPage(), // Replace SecondPage() with your SecondPage
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
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
                      print(error);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // Use Google's brand blue color
                    padding: EdgeInsets.all(0),

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
                        SizedBox(
                            width:
                                10), // Add some spacing between the logo and text
                        Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue, // Use white text color
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
    );
  }
}

class ThirdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle the back button press here
        // You can use Navigator.pop to navigate to the previous page
        Navigator.pop(context);
        return false; // Return false to allow the back gesture
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        // Navigate back when the back button is pressed
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.60, // Adjust the height as needed
              child: Image.asset('assets/sq.jpg'),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                // Add SingleChildScrollView to allow scrolling
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Scan QR on your Cart',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Press on the below button to Scan QR',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the new page here
                      // You can use Navigator.push to navigate to the new page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartNumberPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      primary: Colors.orange[900], // Change the color as needed
                    ),
                    child: SizedBox(
                      width: 60, // Adjust the width of the circular button
                      height: 60, // Adjust the height of the circular button
                      child: Center(
                        child: Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
