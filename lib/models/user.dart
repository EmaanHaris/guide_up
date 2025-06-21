//user model of mentor
class User{
  final String uid;
  final String name;
  final String password;
  final String email;
  final String role;
  final String? location;
  final String? about;
  final List<String>? interests;
  final String? education;
  final String? university;
  final String? gradYear;
  //for mentor
  final String? experience;
  final String? company;
  final List<String>? mentees;
  final bool? isAvailable;
  final String? linkedIn;
  final String? msg;
  //for mentee
  final List<String>? skills;
  final String? requirment;
  final List<String>? mentor;

  //constructor
  const User({
    required this.uid,
    required this.name,
    required this.password,
    required this.email,
    required this.role,
    required this.location,
    required this.about,
    required this.interests,
    required this.education,
    required this.university,
    required this.experience,
    required this.company,
    required this.mentees,
    required this.isAvailable,
    required this.linkedIn,
    required this.msg,
    required this.skills,
    required this.gradYear,
    required this.requirment,
    required this.mentor
  });
  //recieved arguments to Json
  Map<String,dynamic> toJson() =>{
    "name": name,
    "password": password,
    "email": email,
    "role": role,
    "location": location,
    "about": about,
    "interests": interests,
    "education": education,
    "university": university,
    "experience": experience,
    "company": company,
    "mentees": mentees,
    "isAvailable": isAvailable,
    "linkedIn": linkedIn,
    "msg": msg,
    "skills": skills,
    "gradYear": gradYear,
    "requirment": requirment,
    "mentor": mentor,
  };
}

