import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() => runApp(const SignInApp());

class SignInApp extends StatelessWidget {
  const SignInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SignInScreen(),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: 3, // Number of images
              itemBuilder: (context, index) {
                List<String> imageFilenames = [
                  'image0.jpg',
                  'image1.jpg',
                  'image2.jpg'
                ]; // Replace with your image filenames
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/${imageFilenames[index]}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20.0),
          TextLiquidFill(
            text: 'Welcome!',
            waveColor: Colors.blueAccent,
            boxBackgroundColor: Colors.transparent,
            textStyle: const TextStyle(
              fontSize: 48.0,
              fontWeight: FontWeight.bold,
            ),
            boxHeight: 100.0,
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              if (_currentPage == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NextScreen()),
                );
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Text(_currentPage == 2 ? 'Get Started' : 'Next'),
          ),
        ],
      ),
    );
  }
}

class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Screen'),
      ),
      body: const Center(
        child: Text('This is the next screen!'),
      ),
    );
  }
}
