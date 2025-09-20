import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CartNumberPage.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class PhoneEntryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/ig.jpg'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to ZuppCart',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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
                      final GoogleSignInAuthentication googleAuth =
                          await googleUser!.authentication;
                      final AuthCredential credential =
                          GoogleAuthProvider.credential(
                        accessToken: googleAuth.accessToken,
                        idToken: googleAuth.idToken,
                      );
                      final UserCredential authResult = await FirebaseAuth
                          .instance
                          .signInWithCredential(credential);
                      final User user = authResult.user!;

                      // Navigate to the SecondPage with a leftward swipe transition
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation,
                                  secondaryAnimation) =>
                              SecondPage(
                                  user), // Replace SecondPage() with your SecondPage
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
                    primary: Color(0xFFFF914D),
                    padding: EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5.0, // Add a shadow
                  ),
                  child: Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
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

class SecondPage extends StatefulWidget {
  final User user;

  SecondPage(this.user);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check if user data already exists in Firestore
    getUserDataFromFirestore(widget.user.uid).then((userData) {
      if (userData != null) {
        // Data exists, populate the fields
        nameController.text = userData['name'];
        phoneNumberController.text = userData['phone_number'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                final phoneNumber = phoneNumberController.text;

                // Store user data in Cloud Firestore
                final firestore = FirebaseFirestore.instance;
                await firestore.collection('users').doc(widget.user.uid).set({
                  'name': name,
                  'phone_number': phoneNumber,
                });

                // Navigate to CartNumberPage after saving
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CartNumberPage(), // Replace CartNumberPage() with your CartNumberPage
                    ));
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>?> getUserDataFromFirestore(String uid) async {
  final firestore = FirebaseFirestore.instance;
  final docSnapshot = await firestore.collection('users').doc(uid).get();

  if (docSnapshot.exists) {
    return docSnapshot.data() as Map<String, dynamic>;
  } else {
    return null;
  }
}
