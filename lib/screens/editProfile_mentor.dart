import 'package:flutter/material.dart';
import 'package:guide_up/services/firebase_firestore.dart';

class editprofileMentor extends StatefulWidget {
  final Map<String, dynamic>? mentorData;

  const editprofileMentor({super.key, required this.mentorData});

  @override
  State<editprofileMentor> createState() => _editprofileMentorState();
}

class _editprofileMentorState extends State<editprofileMentor> {
  final UserInfo mentorInfo = UserInfo();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController aboutMeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController universityController = TextEditingController();
  final TextEditingController gradYearController = TextEditingController();
  final TextEditingController workExperienceController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController linkController=TextEditingController();

  bool isAvailable = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.mentorData != null) {
      nameController.text = widget.mentorData?['name'] ?? '';
      emailController.text = widget.mentorData?['email'] ?? '';
      aboutMeController.text = widget.mentorData?['aboutMe'] ?? '';
      locationController.text = widget.mentorData?['location'] ?? '';
      educationController.text = widget.mentorData?['education'] ?? '';
      universityController.text = widget.mentorData?['university'] ?? '';
      gradYearController.text = widget.mentorData?['gradYear'] ?? '';
      workExperienceController.text = widget.mentorData?['workExperience'] ?? '';
      linkController.text=widget.mentorData?['linkedinUrl'] ?? '';
      companyController.text = widget.mentorData?['company'] ?? '';
      isAvailable = widget.mentorData?['isAvailable'] ?? true;
    }
  }

  Future<void> _saveProfile() async {
    setState(() => isSaving = true);

    String? mentorId = mentorInfo.currentUserID();
    if (mentorId != null) {
      Map<String, dynamic> updatedData = {
        'name': nameController.text,
        'email': emailController.text,
        'aboutMe': aboutMeController.text,
        'location': locationController.text,
        'education': educationController.text,
        'university': universityController.text,
        'gradYear': gradYearController.text,
        'workExperience': workExperienceController.text,
        'linkedinUrl': linkController.text,
        'company': companyController.text,
        'isAvailable': isAvailable,
      };

      await mentorInfo.updateMentorProfile(mentorId, updatedData);
      Navigator.pop(context, updatedData); // Return updated data to the profile page
    }

    setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 180),
                  child: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                ),
                  const SizedBox(height: 30,),
                _buildTextField(nameController, 'Name'),
                _buildTextField(emailController, 'Email'),
                _buildTextField(aboutMeController, 'About Me', maxLines: 3),
                _buildTextField(locationController, 'Location'),
                _buildTextField(educationController, 'Education'),
                _buildTextField(universityController, 'University'),
                _buildTextField(gradYearController, 'Graduation Year'),
                _buildTextField(workExperienceController, 'Work Experience'),
                _buildTextField(linkController,'linkedinUrl' ),
                _buildTextField(companyController, 'Company'),
        
                
                SwitchListTile(
                  title: const Text('Available for Mentorship'),
                  value: isAvailable,
                  onChanged: (value) {
                    setState(() {
                      isAvailable = value;
                    });
                  },
                ),
        
                const SizedBox(height: 20),
        
              
                ElevatedButton(
                  onPressed: isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: const Color(0xFF0288D1),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes', style: TextStyle(fontSize: 18, color: Colors.white),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
