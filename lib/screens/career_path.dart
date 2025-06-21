import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guide_up/services/api_service.dart';
import 'package:guide_up/services/firebase_firestore.dart';
import 'package:guide_up/utils/utils.dart';
import 'package:guide_up/models/careerStep.dart';
import 'package:url_launcher/url_launcher.dart';

class CareerPath extends StatefulWidget {
  @override
  _CareerPathState createState() => _CareerPathState();
}
class _CareerPathState extends State<CareerPath>{
  final Api apiService=Api();//api class instance
  final UserInfo profileData=UserInfo();//userinfo class instance
  String career = ""; //store career title
  List<CareerStep> careerPath=[];//store career path
  String loggedInUser="";//id of loggedin user
  bool isLoading=false;
  String menteeId="";

  @override
  void initState() {
    super.initState();
    //fetchCareer(); //call API when screen loads
    // fetchCareer();
    // fetchMenteeId();
    _initializeData();
  }

  void _initializeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      loggedInUser = profileData.currentUserID()!;
      menteeId = loggedInUser;

      await profileData.sendAndSaveCareerData(loggedInUser);
      final path = await profileData.fetchCareerPath(loggedInUser);
      final doc = await FirebaseFirestore.instance
          .collection('CareerPaths')
          .doc(loggedInUser)
          .get();
      final predCareer = doc.data()?['predictedCareer'] ?? "";

      setState(() {
        career = predCareer;
        careerPath = path;
      });
      print("Career inside set state: $career");
    } catch (e) {
      final errorMsg = e.toString();
      print("Error: $errorMsg");

      if (errorMsg.contains('Skills, education, and interests are required.')) {
        Utils().toastMessage("Skills, education, and interests are required.");
      } else {
        Utils().toastMessage("Something went wrong. Try again.");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isLocked(int index) {
  if (index == 0) return false; // First step is always unlocked

  // Check if the previous step has all its projects completed
  final previousStep = careerPath[index - 1];
  return previousStep.projects.any((p) => !p.completed);
}

 /* void fetchMenteeId() async {
    menteeId = profileData.currentUserID()!;
    setState(() {
      isLoading = false;
    });
  }

  //get user id of the user currently logged in
  void fetchCareer() async {
    setState(() {
      isLoading = true; 
    });
    try{
      loggedInUser = profileData.currentUserID()!; //fetch current user ID
      await profileData.sendAndSaveCareerData(loggedInUser);
      final path=await profileData.fetchCareerPath(loggedInUser);
      final doc = await FirebaseFirestore.instance.collection('CareerPaths').doc(loggedInUser).get();
      final predCareer = doc.data()?['predictedCareer'] ?? "";

      setState(() {
        career = predCareer;
        careerPath = path;
      });
       print("Career inside set state: $career");
    } catch(e){
        final errorMsg = e.toString();
        print("Error: $errorMsg");

        if (errorMsg.contains('Skills, education, and interests are required.')) {
          Utils().toastMessage("Skills, education, and interests are required.");
        } else {
          Utils().toastMessage("Something went wrong. Try again.");
        }
      }finally{
        setState(() {
        isLoading = false;
      });
    }
  }*/

  

  Future<void> _loadCareerPath() async {
    final user=profileData.currentUserID();
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('Mentees').doc(user).get();
    if (doc.exists) {
      final data = doc.data();
      final pathData = data?['careerPath'] ?? [];
      setState(() {
        careerPath = (pathData as List)
            .map((step) => CareerStep.fromMap(step as Map<String, dynamic>))
            .toList();
      });
    }
  }
  

  @override
    Widget build(BuildContext context) {
      return Scaffold(
         backgroundColor: Color(0xFFF0F4F8),
         body: isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Fetching career path...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            )
          :SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                  Text('Career Path', style: TextStyle( fontSize: 26,fontWeight: FontWeight.bold, color: Colors.blueAccent, ), ),
                  SizedBox(height: 25,),
                  Text("Your selected career path is:",style: TextStyle(fontSize: 18,),),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueAccent, width: 2)
                    ), 
                    child: Text(career,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),),
                  ),
                  SizedBox(height: 20),
                  Text("Explore these steps to achieve your goals:",style: TextStyle(fontSize: 18,),),
                  SizedBox(height: 10),
                   ...careerPath.asMap().entries.map((entry) {
                      int index = entry.key;
                      CareerStep step = entry.value;

                       bool nextStepDone = index < careerPath.length - 1
                        ? careerPath[index + 1].projects.every((p) => (p as Project).completed)
                        : false;
                      return CareerStepWidget(
                        step: step,
                        stepIndex: index,
                        isNextStepCompleted: nextStepDone,
                        isLastStep: index == careerPath.length - 1,
                        fullCareerPath: careerPath,
                        menteeId: menteeId,
                        onUpdate: (updatedStep) async {
                            setState(() {
                              careerPath[index] = updatedStep; 
                            });
                            final user = profileData.currentUserID();
                             if (user != null) {
                                final userDoc = FirebaseFirestore.instance.collection('Mentees').doc(user);
                                await userDoc.set({
                                  'careerPath': careerPath.map((step) => step.toMap()).toList(),
                                }, SetOptions(merge: true));
                              }
                        },
                         isLocked: isLocked(index),
                        
                      );
                   }).toList(),
                ],
              ),
              ),
          )
      );
    }
}

//custom widget to display the path
class CareerStepWidget extends StatefulWidget {
   final String menteeId;
  final CareerStep step;
  final int stepIndex;
  final bool isNextStepCompleted;
  final bool isLastStep;
  final List<CareerStep> fullCareerPath;
  final Function(CareerStep) onUpdate;
  final bool isLocked;

  CareerStepWidget({ required this.menteeId,required this.step, required this.stepIndex, required this.isNextStepCompleted,required this.isLastStep,required this.fullCareerPath,  required this.onUpdate,Key? key, required this.isLocked,}) : super(key: key);
   @override
  _CareerStepWidgetState createState() => _CareerStepWidgetState();
}
class _CareerStepWidgetState extends State<CareerStepWidget> {
  bool isExpanded = false;
  final UserInfo profileData=UserInfo();//userinfo class instance

  Future<void> _saveCareerPath() async {
    final user=profileData.currentUserID();
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('CareerPaths').doc(user);
    final data = {
     'careerPath': widget.fullCareerPath.map((step) => step.toMap()).toList(),
    };
    await userDoc.set(data, SetOptions(merge: true));
  }

   @override
  Widget build(BuildContext context) {
    bool stepCompleted = widget.step.projects.every((p) => (p as Project).completed);
    bool nextStepCompleted = false;
    bool isLocked = false;
    if (!widget.isLastStep) {
      final nextStep = widget.fullCareerPath[widget.stepIndex + 1];
      nextStepCompleted = nextStep.projects.every((p) => (p as Project).completed);
    }
    if (widget.stepIndex > 0) {
      for (int i = 0; i < widget.stepIndex; i++) {
        if (!widget.fullCareerPath[i].projects.every((p) => p.completed)) {
          isLocked = true;
          break;
        }
      }
    }
    return Padding(
              padding:const EdgeInsets.only(bottom: 20.0), 
              child: Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                  //icon and line
                  Column(
                    children:[
                      Icon(
                        isLocked?Icons.lock:
                        stepCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isLocked? const Color.fromARGB(255, 252, 168, 11):stepCompleted ? Colors.green : Colors.grey,
                        size: 40,
                      ),
                      if (!isExpanded && !widget.isLastStep)
                        Container(
                          width: 4,
                          height: 60,
                          color: nextStepCompleted ? Colors.green : Colors.grey,
                        ),
                    ],
                  ),
                  SizedBox(width: 10),
                  //contaier with step
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.grey[350] : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isLocked?Colors.grey: Colors.blueAccent, width: 2),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                "Step ${widget.stepIndex + 1}: ${widget.step.title}",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isLocked ? Colors.grey[600] : Colors.black,),
                              ),
                              trailing: IconButton(
                              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                              onPressed: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                            )
                          ),
                          //view mentor comments
                            /*if(!isExpanded)
                             FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('Mentees')
                                  .doc(widget.menteeId) 
                                  .collection('careerPathComments')
                                  .doc(widget.step.title) 
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                 return Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ); 
                                }
                                if (!snapshot.hasData || !snapshot.data!.exists) {
                                  return SizedBox(); //when there are no comments made
                                }
                                final data = snapshot.data!.data() as Map<String, dynamic>;
                                final String comment = data['comment'] ?? '';
                                return Container(
                                margin: EdgeInsets.only(left: 8, right: 8, bottom: 4),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.yellow[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.comment, size: 18, color: Colors.grey[800]),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        comment,
                                        style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),*/
                          if (isExpanded)
                          Padding(
                            padding:const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(),
                                  //skills
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text("Skills Required:",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 32.0, top: 4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: widget.step.skills.map((s) => Text("• $s")).toList(),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  //projects
                                  Row(
                                    children: [
                                      Icon(Icons.build, color: Colors.orange),
                                      SizedBox(width: 8),
                                      Text("Build these Projects:",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Column(
                                    children: widget.step.projects.asMap().entries.map((entry){
                                      int projIndex = entry.key;
                                      Project project = entry.value;
                                      return CheckboxListTile(
                                        contentPadding: EdgeInsets.only(left: 32),
                                        controlAffinity: ListTileControlAffinity.leading,
                                        title: Text(project.title, style: TextStyle(fontSize: 14)),
                                        value: project.completed,
                                        onChanged: widget.isLocked?null  : (bool? value) {
                                          final updatedProjects = [...widget.step.projects];  
                                          updatedProjects[projIndex] =project.copyWith(completed: value ?? false);
                                           final updatedStep = CareerStep(
                                              title: widget.step.title,
                                              skills: widget.step.skills,
                                              projects: updatedProjects,
                                              resources: widget.step.resources,
                                            );
                                             widget.onUpdate(updatedStep);
                                            _saveCareerPath();
                                        }
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 10),
                                  //resources
                                  Row(
                                    children: [
                                      Icon(Icons.link, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text("Resources:",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 32.0, top: 4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:  widget.step.resources.map((r) {
                                        return GestureDetector(
                                          onTap: () async {
                                            final Uri url = Uri.parse(r);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url, mode: LaunchMode.externalApplication);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Could not launch $r")),
                                              );
                                            }
                                          },
                                          child: Text(
                                            "• $r",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ]
                            ),
                          )
                        ],
                      ),
                    )
                  )
                 ]
              ),
            );
  }
}

