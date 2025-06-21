import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:guide_up/screens/login_screen.dart';
import 'package:guide_up/screens/menteeHome_screen.dart';
import 'package:guide_up/screens/menteeProfile.dart';
import 'package:guide_up/screens/mentorVewProfile.dart';
import 'package:guide_up/screens/register_screen.dart';
import 'package:guide_up/screens/splash_screen.dart';
import 'package:guide_up/screens/mentorHome_screen.dart';
import 'package:guide_up/screens/mentorProfile.dart';
import 'package:guide_up/screens/viewRequests.dart';
import 'package:guide_up/screens/yourMentees.dart';


void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings= const Settings(
    persistenceEnabled: true
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      //initialRoute: '/register',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/MentorScreen': (context) => MentorScreen(),
        '/MenteeScreen': (context) => MenteeScreen(),
        '/MenteeProfile': (context) => MenteeProfile(),
        '/MentorProfile':(context) => MentorProfile(),
        '/MentorViewProfile':(context) => MentorViewProfile(),
        '/ViewRequests':(context) => ViewRequests(),
        '/YourMentees':(context)  => YourMentees(),
      },
      home: SplashScreen()
      /*StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context,snapshot){
          //if firebase has returned any data
          if(snapshot.connectionState==ConnectionState.active){
            //if the user is logged in
            if(snapshot.hasData){
              return const ResponsiveLayout( mobileScreenLayout:MobileScreenLayout());
            }
            //error
            else if(snapshot.hasError){
              return Center(
                child: Text('${snapshot.error}'),
              );
            }
          }
          //if firebase is still fetching user date
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(color: Colors.white,),
            );
          }
          return const LoginScreen();
        }
        ),*/
    ); 
  }
}

/*class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(),
      ),
      body: Center( 
      ),
    );
  }
}*/
