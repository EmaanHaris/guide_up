import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';
import 'package:guide_up/models/careerStep.dart';

//class for user data funtcions and career path funcitons
class UserInfo{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Api api=Api();

  //get the user id of the user currently logged in
  String? currentUserID(){
    User? user=_auth.currentUser;
    return user?.uid;
  }

  //get mentor's data from firestore
  Future<Map<String,dynamic>?> getMentorProfile(String id) async {
    DocumentSnapshot mentor_profile=await _firestore.collection('Mentors').doc(id).get();
    try{
      if(mentor_profile.exists){
        return mentor_profile.data() as Map<String,dynamic>;
      }else{
        return null; //Mentor not found
      }
    }catch(e){
      return null;
    } 
  }
  //get mentee's data from firestore
  Future<Map<String,dynamic>?> getMenteeProfile(String id) async {
    DocumentSnapshot mentor_profile=await _firestore.collection('Mentees').doc(id).get();
    try{
      if(mentor_profile.exists){
        return mentor_profile.data() as Map<String,dynamic>;
      }else{
        return null; //Mentor not found
      }
    }catch(e){
      return null;
    } 
  }

  //update mentor's data in firestore
  Future<void> updateMentorProfile(String mentorId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('Mentors').doc(mentorId).update(updatedData);
    } catch (e) {
      print("Error updating profile: $e");
    }
  }
  //update mentee's data in firestore
  Future<void> updateMenteeProfile(String menteeId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('Mentees').doc(menteeId).update(updatedData);
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  //get the data of all available mentors
  Future<List<Map<String,dynamic>>> getAllMentors() async{
    try{
       QuerySnapshot querySnapshot = await _firestore.collection('Mentors').get();
       List<Map<String,dynamic>> mentors= querySnapshot.docs.map((doc){
          Map<String, dynamic> mentorData = doc.data() as Map<String, dynamic>;
          mentorData["id"] = doc.id; 
          return mentorData;
        }).toList();

       return mentors;
    } catch(e){
      //print("Error fetching all mentors: $e");
      return [];
    }
  }

  //function to fetch all the mentees of the mentor logged in
 Future<List<Map<String, dynamic>>> getAllMentees() async {
  String? mentorId = _auth.currentUser?.uid;
  try{
    DocumentSnapshot mentorSnapshot = await _firestore.collection('Mentors').doc(mentorId).get();
    //list of all mentees from mentor doc
    List<dynamic> menteeIds= mentorSnapshot['mentees'] ?? [];
    if (menteeIds.isEmpty) return [];
    
    //get details of the mentee
     List<Map<String, dynamic>> mentees = [];
     for(String id in menteeIds){
       DocumentSnapshot menteeSnapshot = await _firestore.collection('Mentees').doc(id).get();

        if (menteeSnapshot.exists) {
        Map<String, dynamic> menteeData = menteeSnapshot.data() as Map<String, dynamic>;
        menteeData['id'] = id;
        mentees.add(menteeData);
      }
    }
    return mentees;

  }  catch(e){
      print("Error fetching mentees: $e");
      return [];
   }
 }
 
 //function to get the id of the mentor assigned to a mentee
 Future<String?> getAssignedMentorId(String menteeId) async {
    final menteeDoc = await FirebaseFirestore.instance
      .collection('Mentees')
      .doc(menteeId)
      .get();

    if (!menteeDoc.exists) return null;
    return menteeDoc.data()?['Mentor'];
  }

//function to remove mentor
Future<void> removeAssignedMentor(String menteeId) async {
  try{
    DocumentReference menteeRef = _firestore.collection('Mentees').doc(menteeId);
    //setting mentor to empty list
      await menteeRef.update({
        'mentor': [],
      });
      print("Mentor unassigned successfully from mentee $menteeId.");
  } catch (e) {
      print("Error removing mentor assignment: $e");
      rethrow;
    }
}

 //function to send mentee's data to flask and get the predicted career an save it
 Future<void> sendAndSaveCareerData(String menteeId) async {
  try{
     var menteeData = await getMenteeProfile(menteeId);
     if(menteeData == null) {
      throw Exception("Mentee profile not found.");
    }
     //extract usefull information from profile
    List<String> skills = List<String>.from(menteeData['skills'] ?? []);
    String education = menteeData['education'] ?? '';
    List<String> interests = List<String>.from(menteeData['interests'] ?? []);
    String experience= menteeData['experience'] ??'';
    if (skills.isEmpty || education.isEmpty || interests.isEmpty) {
      throw Exception('Skills, education, and interests are required.');
    }
    final result = await api.getCareer(skills, education, interests,experience);
    String career = result['career'];
    print("career from function: $career");
    List<dynamic> steps = result['roadmap']['steps'] ?? [];

    final docRef = FirebaseFirestore.instance.collection('CareerPaths').doc(menteeId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists && docSnapshot.data()?['predictedCareer'] != null) {
      print("Career path already exists for this mentee.");
      return;
    }
    await docRef.set({
      'menteeId': menteeId,
      'predictedCareer': career,
      'steps': steps,
      'completedStep':0,
    });
    print("Career and roadmap saved for mentee $menteeId");
  }catch (e) {
    print("Error in sendAndSaveCareerData: $e");
    rethrow;
  }
 }

//funciont to get career path data saved in firestore
 Future<List<CareerStep>> fetchCareerPath(String menteeId) async {
  try{
    final doc = await FirebaseFirestore.instance
      .collection('CareerPaths')
      .doc(menteeId)
      .get();

    if(doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('steps')) {
        final List<dynamic> stepsData = data['steps'];
        
        return stepsData.map((step) => CareerStep.fromMap(step)).toList();
      }
    }
    return [];
  }catch (e) {
    print('Error fetching career path: $e');
    return [];
  }
 }
 
 Future<void> addEndorsementToMentor({required String mentorId, required String menteeName,required String endorsement}) async{
  try{
    final mentorRef = _firestore.collection('Mentors').doc(mentorId);
    await mentorRef.update({ 'endorsements': FieldValue.arrayUnion([
            {
              'menteeName': menteeName,
              'message': endorsement,
            }
          ])
        });
  }catch(e){
      print('Error adding endorsement: $e');
      rethrow;
    }
 }
}


//class for handling requests functionality
class RequestService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //send request to mentor
   Future<void> sendRequest(String menteeId, String mentorId) async {
    try {
      await _firestore.collection('MentorRequests').add({
        'menteeId': menteeId,
        'mentorId': mentorId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      } catch (e) {
        print("Error sending request: $e");
      }
  }

  //check if request already exists
  Future<bool> isRequestSent(String menteeId, String mentorId) async{
    var querySnapshot = await _firestore
        .collection('MentorRequests')
        .where('menteeId', isEqualTo: menteeId)
        .where('mentorId', isEqualTo: mentorId)
        .where('status', isEqualTo: 'pending') 
        .get();
        return querySnapshot.docs.isNotEmpty;
  }

  //function to view requests by mentor 
  Future<List<Map<String, dynamic>>> fetchRequests() async {
     String? mentorId = _auth.currentUser?.uid;
     if (mentorId == null) return [];

     QuerySnapshot mentorRequestsSnapshot = await _firestore.collection('MentorRequests')
        .where('mentorId', isEqualTo: mentorId)
        .where('status', isEqualTo: 'pending')
        .get();

      List<Map<String, dynamic>> tempRequests = [];
      
      for (var request in mentorRequestsSnapshot.docs) {
        
        String menteeId = request['menteeId'];  
        print('Fetching mentee data for ID: $menteeId');
        DocumentSnapshot menteeSnapshot = await _firestore.collection('Mentees').doc(menteeId).get();
        print('Mentee document exists: ${menteeSnapshot.exists}');
        print('Mentee data: ${menteeSnapshot.data()}');
        
         if (menteeSnapshot.exists) {
             Map<String, dynamic> menteeData = menteeSnapshot.data() as Map<String, dynamic>;
             tempRequests.add({
              'requestId': request.id,
              'menteeId': menteeId,
              'name': menteeData['name'] ?? 'Unknown',
              'image': menteeData['image'] ?? '',
              'requirment': menteeData['requirment'] ?? 'No reason provided',
            });
         }
      }
      return tempRequests;
    }

    //function to delete requests if the mentor rejects them
    Future<void> deleteRequest(String requestId) async {
      try{
        await _firestore.collection('MentorRequests').doc(requestId).delete();
      } catch(e){
          print("Error deleting request: $e");
          throw e;
      }
    }


  //function to assign mentee to a mentor and vice versa if they accept the request
  Future<void> assignMentee(String mentorId, String menteeId) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    final mentorRef = FirebaseFirestore.instance.collection('Mentors').doc(mentorId);
    final menteeRef = FirebaseFirestore.instance.collection('Mentees').doc(menteeId);

    batch.update(mentorRef, {
      'mentees': FieldValue.arrayUnion([menteeId]),
    });
    batch.update(menteeRef, {
      'mentor':  FieldValue.arrayUnion([mentorId]), 
    });

    await batch.commit();
  }
}

//class for handling functionality of chat service
class chatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 //function to create an id of chat 
  String generateChatRoomId(String id1, String id2) {
    List<String> ids = [id1, id2];
    ids.sort(); //sort ids alphabetically
    return "${ids[0]}_${ids[1]}";
  }
  
  //function to create a chatroom
  Future<void> createChatRoom(String menteeId, String mentorId) async {
    String chatRoomId = generateChatRoomId(menteeId, mentorId);
    final chatRoomRef = _firestore.collection("ChatRooms").doc(chatRoomId);
    final snapshot = await chatRoomRef.get();

    if (!snapshot.exists) {
      await chatRoomRef.set({
        "menteeId": menteeId, // Always store menteeId under "menteeId"
        "mentorId": mentorId, // Always store mentorId under "mentorId"
        "createdAt": FieldValue.serverTimestamp(),
      });
      print("ChatRoom Created with menteeId: $menteeId and mentorId: $mentorId");
    } else {
      print("ChatRoom Already Exists");
    }
  }


  //function to check if chat already exists to avoid duplicate
  Future<bool> chatRoomExists(String menteeId, String mentorId) async {
    String chatRoomId = generateChatRoomId(menteeId, mentorId);
    final chatRoomRef = _firestore.collection("ChatRooms").doc(chatRoomId);
    final snapshot = await chatRoomRef.get();
    return snapshot.exists;
  }
  
  //function to send message
  Future<void> sendMessage(String senderId, String receiverId, String message) async {
    String chatRoomId = generateChatRoomId(senderId, receiverId);
    final chatRoomRef = _firestore.collection("ChatRooms").doc(chatRoomId);

    // Send message if chat room exists
    await chatRoomRef.collection("Messages").add({
      "senderId": senderId,
      "receiverId": receiverId,
      "message": message,
      "timestamp": FieldValue.serverTimestamp(),
    }).then((_) {
      print("Message sent successfully");
    }).catchError((error) {
      print("Failed to send message: $error");
    });
  }
  
  //function to recieve message 
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String senderId, String receiverId) {
    String chatRoomId = generateChatRoomId(senderId, receiverId);
    final chatRoomRef = _firestore.collection("ChatRooms").doc(chatRoomId);
    
    return chatRoomRef
        .collection("Messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }


}







