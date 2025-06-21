import 'package:flutter/material.dart';
import 'package:guide_up/screens/menteeHome_screen.dart';
import 'package:guide_up/screens/mentorHome_Screen.dart';
import 'package:guide_up/services/firebase_auth.dart';
import 'package:guide_up/utils/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  //String? selectedRole;
  bool isLoading = false;

  //final _auth=FirebaseAuth.instance;
 void loginUser() async {
   if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      var result = await AuthMethods().loginUser(email: email, password: password);

      setState(() {
          isLoading=false;
        });

      if (result['status'] == 'success') {
        if (result['role'].toLowerCase() == 'mentor') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MentorScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MenteeScreen()));
        }
      } else {
        showSnackBar(result['message'],context); 
      }
   }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Container(
          color: const Color(0xFF0288D1),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30), 
              child: const Text(
                'WELCOME',
                style: TextStyle(
                  color: Color(0xFFf1faee),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF0F4F8),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey, 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Log In",
                      style: TextStyle(
                        color: Color(0xFF0288D1),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 70),

                    // Email Field
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Email',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Color(0xFF0288D1), 
                           width: 2.5,
                          ),
                        ),
                         enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Color(0xFF0288D1), //blue border
                            width: 2.5,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                     validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email.';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    //Password Field
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Password',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Color(0xFF0288D1), 
                            width: 2.5,
                          )
                        ),
                         enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Color(0xFF0288D1), // Blue border
                            width: 2.5,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter Password!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    //Registration Link
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,'/register' 
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account?",
                          style: TextStyle(fontSize: 20, color: Color(0xFFe63946)),
                          children: [
                            TextSpan(
                              text: ' Register here',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFFe63946),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    //Login Button
                    ElevatedButton(
                      onPressed: loginUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: const Color(0xFF0288D1),
                      ),
                      child: isLoading 
                       ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                      :const Text(
                        'LOG IN',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
