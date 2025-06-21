import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guide_up/screens/login_screen.dart';
import 'package:guide_up/screens/menteeHome_screen.dart';
import 'package:guide_up/screens/mentorHome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    //delay role check to let the animation play
    Future.delayed(Duration(seconds: 3), () => checkLoginState());
  }

  void checkLoginState() async {
    User? user = FirebaseAuth.instance.currentUser;
    print("User: ${user?.uid}");

    if (user != null) {
      try {
        //check if user is a mentor
        DocumentSnapshot mentorDoc = await FirebaseFirestore.instance
            .collection('Mentors')
            .doc(user.uid)
            .get();

        if (mentorDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MentorScreen()),
          );
          return;
        }

        // Check if user is a mentee
        DocumentSnapshot menteeDoc = await FirebaseFirestore.instance
            .collection('Mentees')
            .doc(user.uid)
            .get();

        if (menteeDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MenteeScreen()),
          );
          return;
        }

        // Not mentor or mentee
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } catch (e) {
        print("Error checking user role: $e");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } else {
      //no user logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Text(
              'GuideUp',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color:  Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
