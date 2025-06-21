import 'package:flutter/material.dart';
import 'package:guide_up/screens/login_screen.dart';
import 'package:guide_up/services/firebase_auth.dart';
import 'package:guide_up/services/firebase_firestore.dart';

class MentorScreen extends StatefulWidget {
  const MentorScreen({super.key});

  @override
  State<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends State<MentorScreen> {
  AuthMethods authMethods = AuthMethods();
  UserInfo userInfo = UserInfo();
  String? userName;

  final List<Map<String, dynamic>> dashboardItems = [
    {'image': 'lib/assets/profile.png', 'label': 'Profile'},
    {'image': 'lib/assets/requests.png', 'label': 'View Requests'},
    {'image': 'lib/assets/chat.png', 'label': 'My Mentees'},
    {'image': 'lib/assets/About.png', 'label': 'About Us'},
  ];

  final Color backgroundColor = Color(0xFFF0F4F8);
  final Color cardBorderColor = Color(0xFF01579B);
  final Color titleColor = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  void fetchUserName() async {
    final user = await userInfo.currentUserID();
    if(user != null) {
      final userDoc = await userInfo.getMentorProfile(user);
      setState(() {
        userName = userDoc?['name'];
      });
    }
  }

  void handleLogout() async {
    await authMethods.logoutUser();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent, size: 28),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Do you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                handleLogout();
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Hello, ${userName ?? 'Mentor'} 👋',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: GridView.builder(
                  itemCount: dashboardItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final item = dashboardItems[index];
                    return GestureDetector(
                      onTap: () {
                        switch (index) {
                          case 0:
                            Navigator.pushNamed(context, '/MentorProfile');
                            break;
                          case 1:
                            Navigator.pushNamed(context, '/ViewRequests');
                            break;
                          case 2:
                            Navigator.pushNamed(context, '/YourMentees');
                            break;
                          case 3:
                            
                            break;
                        }
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                        shadowColor: Colors.grey.withOpacity(0.3),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.blueAccent, width: 2),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    topRight: Radius.circular(18),
                                  ),
                                  image: DecorationImage(
                                    image: AssetImage(item['image']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  item['label'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF004D40),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
