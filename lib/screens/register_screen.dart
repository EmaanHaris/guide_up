import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:guide_up/services/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:guide_up/utils/utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Uint8List? _image;
  String? selectedRole;
  bool isLoading=false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  
  void selectImage() async {
    Uint8List img=await pickImage(ImageSource.gallery);
    setState(() {
      _image=img;
    });
  }
  void signupUser() async{
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });


      String res=await AuthMethods().signupUser(
        username: nameController.text, 
        email: emailController.text, 
        password: passwordController.text, 
        role: selectedRole ?? "",
        //file: _image!,
      );
      setState(() {
        isLoading=false;
      });
      if(res!='sucess'){
        showSnackBar(res, context);
      }
      else{
        if (mounted) {
          showSnackBar("Registration successful!", context);
        }
      }
    }
  }
  
  // File? _image;
  // final ImagePicker _picker = ImagePicker();

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Container(
          color: const Color(0xFF0288D1),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 30), 
              child: Text(
                'WELCOME',
                style: TextStyle(
                  color: Color(0xFFF2F2F2),
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    //Profile Image Picker
                    GestureDetector(
                      onTap: selectImage,
                      child: _image!=null?CircleAvatar(
                        radius: 50,
                        backgroundImage:MemoryImage(_image!) ,
                      )
                      :const CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          'https://t3.ftcdn.net/jpg/00/64/67/80/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.webp'
                          ),
                      )
                    ),
                    const SizedBox(height: 10),
                    const Text("Tap to select a profile picture"),
                    const SizedBox(height: 20),

                    //Full Name
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Full Name',
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
                            color: Color(0xFF0288D1), 
                            width: 2.5,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    //email
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Email',
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
                            color: Color(0xFF0288D1), 
                            width: 2.5,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                     validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address.';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    //role Selection
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Select Role"),
                            SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Role Guide"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: const TextSpan(
                                              style: TextStyle(color: Colors.black),
                                              children: [
                                                TextSpan(
                                                  text: '• Mentor: ',
                                                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19),
                                                ),
                                                TextSpan(
                                                  text:
                                                      'A professional or senior student offering guidance and support based on their experience.',
                                                      style: TextStyle(fontSize: 19),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          RichText(
                                            text: TextSpan(
                                              style: TextStyle(color: Colors.black),
                                              children: [
                                                TextSpan(
                                                  text: '• Mentee: ',
                                                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19),
                                                ),
                                                TextSpan(
                                                  text:
                                                      'A student seeking career guidance, support, or mentorship for professional growth.',
                                                       style: TextStyle(fontSize: 19),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text("Close"),
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Icon(Icons.help_outline, size: 20, color: Colors.grey[600]),
                            ),
                          ],
                        ),
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
                            color: Color(0xFF0288D1),
                            width: 2.5,
                          ),
                        ),
                      ),
                      value: selectedRole,
                      items: <String>['Mentor', 'Mentee']
                          .map((String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedRole = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select your role!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    //password
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
                          return 'Enter your password!';
                        }
                        if (value.length < 7) {
                          return 'Password must be at least 7 characters!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),


                    //login Link
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Already have an account?",
                          style: TextStyle(fontSize: 20, color: Color(0xFFe63946)),
                          children: [
                            TextSpan(
                              text: ' Log in',
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

                    //sign Up Button
                    ElevatedButton(
                     onPressed: () {
                        if(_formKey.currentState!.validate()) {
                          signupUser();
                        }
                      },
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
                        'SIGN UP',
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


