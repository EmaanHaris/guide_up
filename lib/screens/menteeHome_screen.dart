import 'package:flutter/material.dart';
import 'package:guide_up/screens/career_path.dart';
import 'package:guide_up/screens/chat.dart';
import 'package:guide_up/screens/findMentor.dart';
import 'package:guide_up/screens/login_screen.dart';
import 'package:guide_up/services/firebase_auth.dart';
import 'package:guide_up/services/firebase_firestore.dart';
import 'package:guide_up/utils/utils.dart';

class MenteeScreen extends StatefulWidget {
  const MenteeScreen({super.key});

  @override
  State<MenteeScreen> createState() => _MenteeScreenState();
}

class _MenteeScreenState extends State<MenteeScreen> {
  AuthMethods authMethods = AuthMethods();
  final UserInfo profileData = UserInfo();
  final chatService _chatService = chatService();
  String? userName;
  String? menteeId;
  List<dynamic> mentor = [];
  bool isLoading = true;

  final List<Map<String, dynamic>> dashboardItems = [
    {'image': 'lib/assets/profile.png', 'label': 'Profile'},
    {'image': 'lib/assets/find.png', 'label': 'My Mentor'},
    {'image': 'lib/assets/chat.png', 'label': 'Chat'},
    {'image': 'lib/assets/career.png','label': 'Path Finder'},
  ];

  final Color backgroundColor = Color(0xFFF0F4F8);
  final Color cardGradientStart = Color(0xFFB3E5FC);
  final Color cardGradientEnd = Color(0xFF81D4FA);
  final Color iconColor = Color(0xFF005792);
  final Color titleColor = Color(0xFF333333);
  final Color appBarColor = Color(0xFF0288D1);

  @override
  void initState() {
    super.initState();
    fetchMenteeId();
  }

  void fetchMenteeId() async {
    menteeId = profileData.currentUserID();
    if (menteeId != null) {
      final userDoc = await profileData.getMenteeProfile(menteeId!);
      setState(() {
        userName = userDoc?['name'];
        mentor = userDoc?['mentor'] ?? [];
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void handleLogout() async {
    await authMethods.logoutUser();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
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
                      'Hello, ${userName ?? 'User'} 👋',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: dashboardItems.length,
                        itemBuilder: (context, index) {
                          final item = dashboardItems[index];
                          return GestureDetector(
                            onTap: () async {
                              switch (index) {
                                case 0:
                                  Navigator.pushNamed(context, '/MenteeProfile');
                                  break;
                                case 1:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FindMentor(menteeId: menteeId!),
                                    ),
                                  );
                                  break;
                                case 2:
                                  if (mentor.isNotEmpty) { 
                                  final mentorId = mentor.first;
                                  final mentorData = await profileData.getMentorProfile(mentorId);
                                  if (mentorData != null) {
                                    final mentorName = mentorData['name'] ?? "Mentor";
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(
                                          currentUserId: menteeId!,
                                          otherUserId: mentorId,
                                          isCurrentUserMentor: false,
                                          otherUserName: mentorName,
                                        ),
                                      ),
                                    );
                                  } else {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      Utils().toastMessage('Assigned mentor profile not found.');
                                    });
                                  }
                                } else {
                                  // This is where 'No mentor assigned yet' will appear
                                  print('No mentor assigned yet');
                                  Future.microtask(() {
                                    Utils().toastMessage('No mentor assigned yet');
                                  });
                                }
                                  break;
                                case 3:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => CareerPath()),
                                  );
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
                                                borderRadius: BorderRadius.only(
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
                                                  fontSize: 16,
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
