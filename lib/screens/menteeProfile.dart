import 'package:flutter/material.dart';
import 'package:guide_up/screens/editProfile_mentee.dart';
import 'package:guide_up/services/firebase_firestore.dart';

class MenteeProfile extends StatefulWidget {
  const MenteeProfile({super.key});

  @override
  State<MenteeProfile> createState() => _MenteeProfileState();
}

class _MenteeProfileState extends State<MenteeProfile> {

  final UserInfo profileData = UserInfo();
  Map<String, dynamic>? menteeData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenteeData();
  }

  void _loadMenteeData() async{
     String? menteeId = profileData.currentUserID();
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
        ?const Center(child: CircularProgressIndicator())
        :menteeData==null
        ?const Center(child: Text("Mentee data not found"))
        :SingleChildScrollView(
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
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150',
                          ),
                        ),
                        Positioned(
                          bottom: 0, 
                          right: 0, 
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.blue, 
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2), 
                            ),
                            child: Icon(
                              Icons.camera_alt, 
                              color: Colors.white,
                              size: 20, 
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60), 

              //Profile starting
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(menteeData?['name'] ?? 'Full Name', style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    //Email
                    Row(
                      children: [
                        Icon(Icons.mail, size: 22),
                        SizedBox(width: 5),
                        Text(menteeData?['email'] ?? 'No email provided', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    //Location
                    Row(
                      children: [
                        Icon(Icons.location_pin, size: 22),
                        SizedBox(width: 5),
                        Text(menteeData?['location'] ?? 'No location set', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    //Interests 
                    const Text('My Interests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Required for generating AI career paths.',style: TextStyle(fontSize: 12, color: Colors.grey),),
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
                                (index) => Text('• ${menteeData!['interests'][index]}', style: TextStyle(fontSize: 14)),
                              ),
                            )
                          : Text('No description provided', style: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(height: 20),

                    //Skills 
                    const Text('Skills', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Required for generating AI career paths.',style: TextStyle(fontSize: 12, color: Colors.grey),),
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
                                (index) => Text('• ${menteeData!['skills'][index]}', style: TextStyle(fontSize: 14)),
                              ),
                            )
                          : Text('No skills added', style: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(height: 20),

                    //Education 
                    const Text('Education', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Required for generating AI career paths.',style: TextStyle(fontSize: 12, color: Colors.grey),),
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
                                  Expanded( 
                                    child: Text(
                                      menteeData?['education'] ?? 'No education provided',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                              children:  [
                                Text(
                                  menteeData?['university'] ??'No university details provided',
                                  style: TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                                SizedBox(height: 3),
                                Text(
                                   menteeData?['gradYear'] ??'No graduation year provided',
                                  style: TextStyle(fontSize: 12, color: Colors.black38),
                                ),
                              ],
                            ),
                            )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    //experience
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
                                  Text(menteeData?['workExperience'] ?? 'No work experiance',
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
                                  menteeData?['company'] ??'No company details provided',
                                  style: TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
                            )
                        ],
                      ),
                    ),
                    //Mentorship requirment
                    const Text('Mentorship requirment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                         menteeData?['requirment'] ??'No graduation year provided',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 25),
                   Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                      child: ElevatedButton(
                        onPressed: () async {
                           final updatedData = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => editprofileMentee(menteeData: menteeData,),
                              ),
                           );
                           if (updatedData != null) {
                                setState(() {
                                  menteeData = updatedData;
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
}
