import 'package:flutter/material.dart';
import 'package:guide_up/services/firebase_firestore.dart';
import 'package:guide_up/screens/editProfile_mentor.dart';
import 'package:url_launcher/url_launcher.dart';

class MentorProfile extends StatefulWidget {
  const MentorProfile({super.key});

  @override
  State<MentorProfile> createState() => _MentorProfileState();
}

class _MentorProfileState extends State<MentorProfile> {
  final UserInfo profileData = UserInfo();
  Map<String, dynamic>? mentorData;
  bool isLoading = true;
  bool isAvailable = true;

   @override
  void initState() {
    super.initState();
    _loadMentorData();
  }

  void _loadMentorData() async{
     String? mentorId = profileData.currentUserID();
    if (mentorId != null) {
      Map<String, dynamic>? data = await profileData.getMentorProfile(mentorId);
      setState(() {
        mentorData = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("No mentor is logged in.");
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : mentorData == null
                ? const Center(child: Text("Mentor data not found"))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        //profile header
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Material(
                              elevation: 8,
                              shadowColor: Colors.black45,
                              child: Container(
                                height: 150,
                                color: Color(0xFF0288D1),
                              ),
                            ),
                            Positioned(
                              bottom: -50,
                              left: MediaQuery.of(context).size.width / 2 - 50,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: mentorData?['profilePicture'] != null
                                    ? NetworkImage(mentorData!['profilePicture'])
                                    : const NetworkImage('https://via.placeholder.com/150'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 60),

                        // Profile Details
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mentorData?['name'] ?? 'Full Name',
                                style: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),

                              // Email
                              Row(
                                children: [
                                  const Icon(Icons.mail, size: 22),
                                  const SizedBox(width: 5),
                                  Text(
                                    mentorData?['email'] ?? 'No email provided',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              //linkedin link
                               if (mentorData?['linkedinUrl'] != null && mentorData!['linkedinUrl'].toString().isNotEmpty)
                                  InkWell(
                                    onTap: () async {
                                      final url = mentorData!['linkedinUrl'];
                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(Uri.parse(url));
                                      } else {
                                        // Handle invalid URL
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Could not open LinkedIn profile')),
                                        );
                                      }
                                    },
                                     child: Row(
                                        children: [
                                          const Icon(Icons.link, size: 22),
                                          const SizedBox(width: 5),
                                          Text(
                                            'View LinkedIn Profile',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.blue[700],
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ),

                              //location
                              Row(
                                children: [
                                  const Icon(Icons.location_pin, size: 22),
                                  const SizedBox(width: 5),
                                  Text(
                                    mentorData?['location'] ?? 'No location set',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // About Me
                              const Text(
                                'About Me',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              _infoBox(mentorData?['aboutMe'] ?? 'No description provided'),

                              const SizedBox(height: 20),

                              // Education
                              const Text(
                                'Education',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                             Container(
                                padding: const EdgeInsets.all(8),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                        Row(
                                          children: [
                                            Icon(Icons.school, size: 20, color: Colors.black),
                                            SizedBox(width: 8),
                                            Text(mentorData?['education'] ?? 'No education provided',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                        padding: const EdgeInsets.only(left: 28),
                                        child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children:  [
                                          Text(
                                            mentorData?['university'] ??'No university details provided',
                                            style: TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                          SizedBox(height: 3),
                                          Text(
                                            mentorData?['gradYear'] ??'No graduation year provided',
                                            style: TextStyle(fontSize: 12, color: Colors.black38),
                                          ),
                                        ],
                                      ),
                                      )
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Work Experience
                              const Text(
                                'Work Experience',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                               Container(
                                  padding: const EdgeInsets.all(8),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                              Row(
                                children: [
                                  Icon(Icons.apartment, size: 20, color: Colors.black),
                                  SizedBox(width: 8),
                                  Text(mentorData?['workExperience'] ?? 'No work experiance',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Padding(
                               padding: const EdgeInsets.only(left: 28),
                               child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:  [
                                Text(
                                  mentorData?['company'] ??'No company details provided',
                                  style: TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
                            )
                        ],
                      ),
                    ),

                              const SizedBox(height: 20),

                              // Mentorship Status
                              const Text(
                                'Mentorship Status',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
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
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 14,
                                      color: mentorData?['isAvailable'] == true ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      mentorData?['isAvailable'] == true
                                          ? 'Available for Mentorship'
                                          : 'Not Available',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: mentorData?['isAvailable'] == true ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 25),

                              // Edit Profile Button
                              Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final updatedData = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => editprofileMentor(mentorData: mentorData!),
                                        ),
                                      );
                                      if (updatedData != null) {
                                        setState(() {
                                          mentorData = updatedData;
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      backgroundColor: const Color(0xFF0288D1),
                                    ),
                                    child: const Text(
                                      'EDIT PROFILE',
                                      style: TextStyle(fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
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
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}
