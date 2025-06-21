  import 'package:flutter/material.dart';
  import 'package:guide_up/services/firebase_firestore.dart';
  import 'package:url_launcher/url_launcher.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

  class MentorViewProfile extends StatefulWidget {
    const MentorViewProfile({super.key});

    @override
    State<MentorViewProfile> createState() => _MentorViewProfileState();
  }

  class _MentorViewProfileState extends State<MentorViewProfile> {

    final UserInfo profileData = UserInfo();
    final RequestService requestService = RequestService();
    Map<String, dynamic>? mentorData;
    String? menteeId;
    bool isLoading = true;
    bool isAvailable = true;
    bool isRequestSent = false;
    List<Map<String, dynamic>> endorsements = [];

    void fetchEndorsements() async {
      final mentorId = await profileData.getAssignedMentorId(profileData.currentUserID()!);
      if (mentorId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('mentors')
            .doc(mentorId)
            .get();

        final data = doc.data();
        if (data != null && data['endorsements'] != null) {
          setState(() {
            endorsements = List<Map<String, dynamic>>.from(data['endorsements']);
          });
        }
      }
    }

  //Get logged-in user's ID
    @override
    void initState() {
      super.initState();
      menteeId = profileData.currentUserID(); 
      fetchEndorsements();

      Future.delayed(Duration.zero, () {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      setState(() {
        mentorData = arguments;
      });
      _checkIfRequestSent();
    } else {
      print("Error: Arguments are not in the expected format");
    }
  });
    }

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      
      final arguments = ModalRoute.of(context)?.settings.arguments;
      //print("Received arguments in MentorViewProfile: $arguments");

      if (arguments is Map<String, dynamic>) {
        setState(() {
          mentorData = arguments;
        });
        _checkIfRequestSent();
      } else {
        print("Error: Arguments are not in the expected format");
      }
    }

    // Check if the mentee has already sent a request
    Future<void> _checkIfRequestSent() async {
      String? menteeId = profileData.currentUserID();
      String? mentorId = mentorData?['id'];

      if (menteeId != null && mentorId != null) {
        bool alreadySent = await requestService.isRequestSent(menteeId, mentorId);
        setState(() {
          isRequestSent = alreadySent;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
    //send request to the mentor
    Future<void> sendRequest() async{
      if (menteeId == null || mentorData == null){
        return;
      } 
      try{
        await requestService.sendRequest(menteeId!, mentorData!['id']);
        setState(() {
          isRequestSent = true; 
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mentor request sent successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send request: $e")),
        );
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
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150',
                        ),
                        radius: 50,
                        backgroundColor: Colors.white,
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
                      Text(mentorData?['name'] ?? 'Full Name', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      //Email
                      Row(
                        children: [
                          Icon(Icons.mail, size: 22),
                          SizedBox(width: 5),
                          Text(mentorData?['email'] ?? 'No email provided', style: TextStyle(fontSize: 14)),
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

                      //Location
                      Row(
                        children: [
                          Icon(Icons.location_pin, size: 22),
                          SizedBox(width: 5),
                          Text(mentorData?['location'] ?? 'No location set', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      //SEND REQUEST BUTTON 
                      Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8, 
                        child: ElevatedButton(
                          //disble the button if the request is already sent
                          onPressed:  (isRequestSent||mentorData?['isAvailable']==false) ? null : sendRequest,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            //change the color and text to show that the button is disabled
                            backgroundColor: (isRequestSent||mentorData?['isAvailable']==false) 
                                  ? Colors.grey
                                  : const Color(0xFF0288D1),
                          ),
                          child: Text(
                                      isRequestSent
                                          ? 'Request Sent'
                                          : mentorData?['isAvailable'] == false
                                              ? 'Not Available'
                                              : 'Send Request',
                                      style: const TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                      //About 
                      const Text('About Me', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                        child:  Text(
                          mentorData?['aboutMe'] ??'No description provided',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //Education 
                      const Text('Education', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                          children:  [
                                Row(
                                  children: [
                                    Icon(Icons.school, size: 20, color: Colors.black),
                                    SizedBox(width: 8),
                                    Text(
                                      mentorData?['education'] ??'No education details provided',
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
                      //work experiance
                      const Text('Work Experiance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                                    Icon(Icons.work, size: 20, color: Colors.black),
                                    SizedBox(width: 8),
                                    Text(
                                      mentorData?['workExperience'] ??'No work experience provided',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Padding(
                                padding: const EdgeInsets.only(left: 28),
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mentorData?['company'] ??'No organizaton provided',
                                    style: TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                ],
                              ),
                                )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      //endorsemetns
                      const Text('Endorsements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      
                      endorsements.isEmpty?const Text('No endorsements yet.',style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)):
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: endorsements.length,
                          itemBuilder: (context, index) {
                            final endorsement = endorsements[index];
                            final menteeName = endorsement['menteeName'];
                            final message = endorsement['message'] ?? '';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: Icon(Icons.person),
                                title: Text(menteeName),
                                subtitle: Text(message),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                      //Mentorship Status
                      const Text('Mentorship Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                              color: mentorData?['isAvailable']==true? Colors.green : Colors.red, //Green if available, Red if not
                            ),
                            const SizedBox(width: 8),
                            Text(
                              mentorData?['isAvailable']==true? 'Available for Mentorship' : 'Not Available',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:mentorData?['isAvailable'] == true ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
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

 
