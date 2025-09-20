// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool isInputValid = false; // To track whether the input is valid

  @override
  void initState() {
    super.initState();
    // Check if user data already exists in Firestore
    getUserDataFromFirestore(widget.user.uid).then((userData) {
      if (userData != null) {
        // Data exists, populate the fields
        nameController.text = userData['name'];
        phoneNumberController.text = userData['phone_number'];
        validateInput(); // Check input validity when data is populated
      }
    });
  }

  // Function to validate input and update isInputValid
  void validateInput() {
    final name = nameController.text;
    final phoneNumber = phoneNumberController.text;
    // Check if the name has at least one character and the phone number has exactly 10 digits
    final isValid = name.isNotEmpty && phoneNumber.length == 10;
    setState(() {
      isInputValid = isValid;
    });
  }

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
                  image: AssetImage(
                      'assets/sp.jpg'), // Replace with your image path
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              // Add SingleChildScrollView to allow scrolling
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Great, You\'re Signed in!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Enter the details below to continue',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: TextFormField(
                            controller: nameController,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.indigo[900], // Text color
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                nameController.text =
                                    value[0].toUpperCase() + value.substring(1);
                                nameController.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(
                                      offset: nameController.text.length),
                                );
                              }
                              // Validate input whenever the name changes
                              validateInput();
                            },
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold,
                                color: Colors.indigo[900], // Label text color
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors
                                      .blue, // Border color when not focused
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      Colors.blue, // Border color when focused
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: TextFormField(
                            controller: phoneNumberController,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.indigo[900], // Text color
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter
                                  .digitsOnly, // Allow only digits
                              LengthLimitingTextInputFormatter(
                                  10), // Limit input to 10 characters
                            ],
                            onChanged: (value) {
                              // Validate input whenever the phone number changes
                              validateInput();
                            }, // Set keyboard type to phone
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold,
                                color: Colors.indigo[900], // Label text color
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors
                                      .blue, // Border color when not focused
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      Colors.blue, // Border color when focused
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        if (isInputValid) // Display the icon only when input is valid
                          ElevatedButton.icon(
                            onPressed: () async {
                              final name = nameController.text;
                              final phoneNumber = phoneNumberController.text;

                              // Store user data in Cloud Firestore
                              final firestore = FirebaseFirestore.instance;
                              await firestore
                                  .collection('users')
                                  .doc(widget.user.uid)
                                  .set({
                                'name': name,
                                'phone_number': phoneNumber,
                              });

                              // Navigate to CartNumberPage after saving
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CartNumberPage(),
                                ),
                              );
                            },
                            icon: Icon(Icons.arrow_forward),
                            label: Text(''),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFFFF914D),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              elevation: 5.0,
                            ),
                          ),
                      ],
                    ),
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

Future<Map<String, dynamic>?> getUserDataFromFirestore(String uid) async {
  final firestore = FirebaseFirestore.instance;
  final docSnapshot = await firestore.collection('users').doc(uid).get();

  if (docSnapshot.exists) {
    return docSnapshot.data() as Map<String, dynamic>;
  } else {
    return null;
  }
}
