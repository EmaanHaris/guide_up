import 'package:flutter/material.dart';
import 'package:guide_up/screens/chat.dart';
import 'package:guide_up/screens/menteeViewProfile.dart';
import 'package:guide_up/services/firebase_firestore.dart';
import 'package:guide_up/screens/CareerPathView.dart';

class YourMentees extends StatefulWidget {
  const YourMentees({super.key});

  @override
  State<YourMentees> createState() => _YourMenteesState();
}

class _YourMenteesState extends State<YourMentees> {
  final UserInfo profileData = UserInfo();
  String? loggedInUser;
  List<Map<String, dynamic>> mentees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getMentees();
    fetchUserId();
  }

  void getMentees() async {
    try {
      List<Map<String, dynamic>> fetchedMentees = await profileData.getAllMentees();
      setState(() {
        mentees = fetchedMentees;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching mentees: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchUserId() async {
    loggedInUser = profileData.currentUserID(); //fetch current user ID
    setState(() {
      isLoading = false; //stop loading
    });
  }

  bool isCurrentUserMentor() {
    for (var mentee in mentees) {
      if (mentee["mentor"] == loggedInUser) {
        return true; 
      }
    }
    return false; //not found as mentor
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: const EdgeInsets.only(left: 10,top:10, bottom: 50),
                    child: const Text(
                            'Your Mentees',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                  ),
                  mentees.isEmpty
                      ? const Center(child: Text("No mentees available"))
                      : Expanded(
                        child: ListView.builder(
                            itemCount: mentees.length,
                            itemBuilder: (context, index) {
                              final mentee = mentees[index];
                                          
                              final nameStyle = mentee["nameStyle"] ?? const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              );
                                          
                              final avatarRadius = mentee["avatarRadius"] ?? 30.0;
                              //final chatTime = mentee["chatTime"] ?? "12:00 PM";
                              final imageUrl = mentee["imageUrl"] ?? "https://via.placeholder.com/150";
                                          
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blueAccent, width: 2),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(imageUrl),
                                    radius: avatarRadius,
                                  ),
                                  title: Text(
                                    mentee["name"] ?? "No Name",
                                    style: nameStyle,
                                  ),
                                  trailing: PopupMenuButton<String>(
                                     icon: const Icon(Icons.more_vert, color: Colors.grey, size: 35),
                                     onSelected: (String choice) {
                                       if (choice == 'chat') {
                                          Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              currentUserId: loggedInUser!,
                                              otherUserId: mentee["id"],
                                              isCurrentUserMentor: isCurrentUserMentor(),
                                              otherUserName: mentee["name"],
                                            ),
                                          ),
                                        );
                                       }
                                       else if(choice=='View career path'){
                                         print("Mentee ID being passed: ${mentee["id"]}");
                                           Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CareerPathView(
                                                menteeId: mentee["id"],
                                              ),
                                            ),
                                          );
                                       }
                                       else if(choice=='View profile'){
                                         print("Mentee ID being passed: ${mentee["id"]}");
                                           Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MenteeViewProfile( menteeId: mentee["id"],)
                                            ),
                                          );
                                       }
                                     },
                                      itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem<String>(
                                            value: 'chat',
                                            child: Text('Chat'),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'View career path',
                                            child: Text('View career path'),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'View profile',
                                            child: Text('View profile'),
                                          ),
                                        ],
                                   )
                                ),
                              );
                            },
                          ),
                      ),
                ],
              ),
            ),
          )

    );
  }
}

                        