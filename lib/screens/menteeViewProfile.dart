import 'package:flutter/material.dart';
import 'package:guide_up/services/firebase_firestore.dart';

class MenteeViewProfile extends StatefulWidget {
  final String menteeId;
  const MenteeViewProfile({super.key, required this.menteeId});

  @override
  State<MenteeViewProfile> createState() => _MenteeViewProfileState();
}
class _MenteeViewProfileState extends State<MenteeViewProfile> {
  final UserInfo profileData = UserInfo();
  Map<String, dynamic>? menteeData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenteeData();
  }

  void _loadMenteeData() async {
    String? menteeId = widget.menteeId;
    if (menteeId != null) {
      Map<String, dynamic>? data = await profileData.getMenteeProfile(menteeId);
      setState(() {
        menteeData = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("No mentee is logged in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : menteeData == null
                ? const Center(child: Text("Mentee data not found"))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile header
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Material(
                              elevation: 8,
                              shadowColor: Colors.black45,
                              child: Container(
                                height: 150,
                                color: const Color(0xFF0288D1),
                              ),
                            ),
                            Positioned(
                              bottom: -50,
                              left: MediaQuery.of(context).size.width / 2 - 50,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                  menteeData?['profilePicture'] ?? 'https://via.placeholder.com/150', // Assuming a profile picture URL field
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 60),

                        // Profile details
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(menteeData?['name'] ?? 'Full Name',
                                  style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),

                              // Email
                              Row(
                                children: [
                                  const Icon(Icons.mail, size: 22),
                                  const SizedBox(width: 5),
                                  Text(menteeData?['email'] ?? 'No email provided',
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Location
                              Row(
                                children: [
                                  const Icon(Icons.location_pin, size: 22),
                                  const SizedBox(width: 5),
                                  Text(menteeData?['location'] ?? 'No location set',
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Interests
                              const Text('My Interests',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const Text('Required for generating AI career paths.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                                child: menteeData?['interests'] != null && menteeData!['interests'] is List
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: List.generate(
                                          (menteeData!['interests'] as List).length,
                                          (index) => Text('• ${menteeData!['interests'][index]}',
                                              style: const TextStyle(fontSize: 14)),
                                        ),
                                      )
                                    : const Text('No interests provided', style: TextStyle(fontSize: 14)),
                              ),
                              const SizedBox(height: 20),

                              // Skills
                              const Text('Skills',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const Text('Required for generating AI career paths.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                                child: menteeData?['skills'] != null && menteeData!['skills'] is List
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: List.generate(
                                          (menteeData!['skills'] as List).length,
                                          (index) => Text('• ${menteeData!['skills'][index]}',
                                              style: const TextStyle(fontSize: 14)),
                                        ),
                                      )
                                    : const Text('No skills added', style: TextStyle(fontSize: 14)),
                              ),
                              const SizedBox(height: 20),

                              // Education
                              const Text('Education',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const Text('Required for generating AI career paths.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                                        const Icon(Icons.school, size: 20, color: Colors.black),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            menteeData?['education'] ?? 'No education provided',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            softWrap: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 28),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            menteeData?['university'] ?? 'No university details provided',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            menteeData?['gradYear'] ?? 'No graduation year provided',
                                            style: const TextStyle(fontSize: 12, color: Colors.black38),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Experience
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
                                        const Icon(Icons.apartment, size: 20, color: Colors.black),
                                        const SizedBox(width: 8),
                                        Text(
                                          menteeData?['workExperience'] ?? 'No work experience',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 28),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            menteeData?['company'] ?? 'No company details provided',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              // Mentorship requirement
                              const SizedBox(height: 20),
                              const Text('Mentorship Requirement',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                                child: Text(
                                  menteeData?['requirment'] ?? 'No mentorship requirement provided',
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
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
}