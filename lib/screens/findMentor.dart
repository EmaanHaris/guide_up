import 'package:flutter/material.dart';
import 'package:guide_up/services/firebase_auth.dart';
import 'package:guide_up/services/firebase_firestore.dart';

class FindMentor extends StatefulWidget {
  final String menteeId; //mentee's id

  const FindMentor({super.key, required this.menteeId});

  @override
  State<FindMentor> createState() => _FindMentorState();
}

class _FindMentorState extends State<FindMentor> {
  final UserInfo profileData = UserInfo();
  List<Map<String, dynamic>> mentors = [];
  Map<String, dynamic>? assignedMentor; 
  String filter='All';
  final List<String> options= ['All', 'Software Engineer', 'Data Scientist', 'Quality Assurance','Cyber Security','Mobile App Develope','Web developer'];
  bool isLoading = true;

  AuthMethods authMethods = AuthMethods();
  String? userName;
  String? menteeId;
  List<dynamic> mentor = [];

  @override
  void initState() {
    super.initState();
    print("InitState called");
    getMentorData();
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

  void addEndorsement() {
    TextEditingController endorsementController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Endorse Your Mentor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: endorsementController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your endorsement...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  final endorsementText = endorsementController.text.trim();
                  if (endorsementText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please write something.')),
                    );
                    return;
                  }

                  if (menteeId == null || userName == null || mentor.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User info not available.')),
                    );
                    return;
                  }

                  try {
                    await profileData.addEndorsementToMentor(
                      mentorId: mentor[0],
                      menteeName: userName!,
                      endorsement: endorsementText,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Endorsement added successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add endorsement.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0288D1),
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void getMentorData() async {
    try {
      // Fetch Mentee Profile to check if a mentor is assigned
      Map<String, dynamic>? menteeData = await profileData.getMenteeProfile(widget.menteeId);

      if (menteeData != null &&menteeData["mentor"] != null && menteeData["mentor"] is List &&(menteeData["mentor"] as List).isNotEmpty) {
      String assignedMentorId = menteeData["mentor"][0];
      Map<String, dynamic>? mentorData = await profileData.getMentorProfile(assignedMentorId);

      if (mentorData != null) {
        mentorData["id"] = assignedMentorId;
        assignedMentor = mentorData;
      }
    } else {
      // Fetch all mentors only if no mentor is assigned
      mentors = await profileData.getAllMentors();
      print("Available mentors: $mentors");
    }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching mentor data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Expanded(
                    child: isLoading? const Center(child: CircularProgressIndicator()): assignedMentor != null
                     ? _buildAssignedMentorSection()//show the assigned mentorr only
                     :Column(
                        children: [
                           const Padding(
                              padding: EdgeInsets.fromLTRB(16, 40, 16, 30), 
                              child: Text(
                                'Find Mentor',
                                style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Color(0xFF0288D1),
                                ),
                              ),
                            ),
                           _buildFilterBar(),
                           SizedBox(height: 15,),
                           Expanded(child: _buildAvailableMentorsSection()),//show available mentors only if no mentor is assigned
                        ],
                     ),
                  )                      
                ],
              ),
      ), 
          );
        }

  //Section to show the assigned mentor
  Widget _buildAssignedMentorSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SafeArea(
        child: const Padding(
          padding: EdgeInsets.fromLTRB(16, 40, 16, 30), 
          child: Text(
            "Your Mentor",
            style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Color(0xFF0288D1),),
          ),
        ),
      ),
      Card(
        color: Color(0xFFF0F4F8),
        elevation: 3,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Color(0xFF0288D1),
            width: 2.5,
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              assignedMentor?["image"] ?? "https://via.placeholder.com/150",
            ),
            radius: 25,
          ),
          title: Text(
            assignedMentor?["name"] ?? "No Name",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle:
              Text(assignedMentor?["workExperience"] ?? "No profession listed"),
          trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey, size: 35),
                      onSelected: (String choice) {
                        if (choice == 'delete') {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Remove'),
                              content: const Text('Do you want to remove this mentor?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('No'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await UserInfo().removeAssignedMentor(widget.menteeId);
                                    Navigator.of(context).pop();
                                    setState(() {
                                      assignedMentor = null;
                                      getMentorData();
                                    });
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            ),
                          );
                        }
                        else if(choice=='endorse'){
                           addEndorsement();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'endorse',
                          child: Text('Endorse'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Remove Mentor'),
                        ),
                      ],
                    ),

          onTap: () {},
        ),
      ),
    ],
  );
}


  //Section to show available mentors if no mentor is assigned
  Widget _buildAvailableMentorsSection() {
    return mentors.isEmpty
        ? const Center(child: Text("No mentors available"))
        : ListView.builder(
            itemCount: mentors.length,
            itemBuilder: (context, index) {
              final mentor = mentors[index];
              return Card(
                color: Colors.white,
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Color(0xFF0288D1), 
                    width: 2.5,                   
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(mentor["image"] ?? "https://via.placeholder.com/150"),
                    radius: 25,
                  ),
                  title: Text(
                    mentor["name"] ?? "No Name",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(mentor["workExperience"] ?? "No profession listed"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.pushNamed(context, '/MentorViewProfile', arguments: mentor);
                  },
                ),
              );
            },
          );
  }

 //drop down widget to filter mentors
  Widget _buildFilterBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: DropdownButtonFormField<String>(
      value: filter,
      decoration: InputDecoration(
        labelText: 'Filter by Career',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: options.map((career) {
        return DropdownMenuItem<String>(
          value: career,
          child: Text(career),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          filter= value!;
        });
        getMentorData(); 
      },
    ),
  );
}
}
