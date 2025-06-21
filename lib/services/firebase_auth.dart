import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guide_up/models/user.dart' as model;

class AuthMethods{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  //sign up user
  Future<String> signupUser({
    required String username,
    required String email,
    required String password,
    //required String confirmPassword,
    required String role,
    //required Uint8List file,
  }) async {
    String res='error occured';
    try{
      if(username.isNotEmpty || email.isNotEmpty || password.isNotEmpty ||  role.isNotEmpty /*|| file!=null*/){
          //register user
          UserCredential cred= await _auth.createUserWithEmailAndPassword(email: email, password: password);
          
          //add user to database
          //determine collection in firestore
          String collection=role.toLowerCase()=='mentor'?'Mentors':'Mentees';

          //user obejcet
          model.User user=model.User(
            uid: cred.user!.uid,
            name: username,
            password: password,
            email: email,
            role: role,
            location: '',
            interests:[],
            about: '',
            education: '',
            university: '',
            experience: role.toLowerCase() == 'mentor' ? '' : null,
            company: role.toLowerCase() == 'mentor' ? '' : null,
            mentees: [],
            isAvailable: role.toLowerCase() == 'mentor' ? false : null,
            linkedIn: role.toLowerCase() == 'mentor' ? '' : null,
            msg:'',
            skills: role.toLowerCase() == 'mentee' ? [] : null,
            gradYear: role.toLowerCase() == 'mentee' ? '' : null,
            requirment: role.toLowerCase() == 'mentee' ? '' : null,
            mentor: []
          );

          await _firestore.collection(collection).doc(cred.user!.uid).set(user.toJson(),);
          res='success';
        } else {
      res = 'Please provide all fields';
    }
  } catch (e) {
    res = e.toString();
  }
  return res;
  }

  //logging in user
  Future<Map<String, dynamic>> loginUser({
  required String email,
  required String password,
  }) async {
    Map<String, dynamic> response = {'status': 'error', 'role': ''};

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);

        //Fetch user role from Firestore
        DocumentSnapshot mentorDoc = await _firestore.collection('Mentors').doc(cred.user!.uid).get();
        DocumentSnapshot menteeDoc = await _firestore.collection('Mentees').doc(cred.user!.uid).get();

       if (mentorDoc.exists) {
        response = {'status': 'success', 'role': 'mentor'};
      } else if (menteeDoc.exists) {
        response = {'status': 'success', 'role': 'mentee'};
      } else {
        response = {'status': 'error', 'message': 'User role not found in Firestore'};
      }
    } else {
       response = {'status': 'error', 'message': 'Please provide all the fields'};
      }
  } catch (e) {
     response = {'status': 'error', 'message': e.toString()};
    }
   return response;
  }

  //function to logout the user
   Future<void> logoutUser() async {
    try{
      await _auth.signOut();
      print('User logged out successfully');
    } catch (e) {
       print('Logout failed: $e');
    }
   }

}

