import 'package:flutter/material.dart';
import 'package:guide_up/services/firebase_firestore.dart';

class editprofileMentee extends StatefulWidget {
  final Map<String, dynamic>? menteeData;

  const editprofileMentee({super.key, required this.menteeData});

  @override
  State<editprofileMentee> createState() => _editprofileMenteeState();
}

class _editprofileMenteeState extends State<editprofileMentee> {
  final UserInfo mentorInfo = UserInfo();
  List<String> skillsList = [];
  List<String> interestsList = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController interestsController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController universityController = TextEditingController();
  final TextEditingController gradYearController = TextEditingController();
  final TextEditingController requirmentController = TextEditingController(); 
  final TextEditingController workExperienceController = TextEditingController();
  final TextEditingController companyController = TextEditingController();

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.menteeData != null) {
      nameController.text = widget.menteeData?['name'] ?? '';
      emailController.text = widget.menteeData?['email'] ?? '';
      interestsList = List<String>.from(widget.menteeData?['interests'] ?? []);
      skillsList = List<String>.from(widget.menteeData?['skills'] ?? []);
      locationController.text = widget.menteeData?['location'] ?? '';
      educationController.text = widget.menteeData?['education'] ?? '';
      universityController.text = widget.menteeData?['university'] ?? '';
      gradYearController.text = widget.menteeData?['gradYear'] ?? '';
      requirmentController.text = widget.menteeData?['requirment'] ?? '';
      workExperienceController.text = widget.menteeData?['workExperience'] ?? '';
      companyController.text = widget.menteeData?['company'] ?? '';
    }
  }

  Future<void> _saveProfile() async {
    setState(() => isSaving = true);

    String? mentorId = mentorInfo.currentUserID();
    if (mentorId != null) {
      Map<String, dynamic> updatedData = {
        'name': nameController.text,
        'email': emailController.text,
        'interests': interestsList,
        'skills': skillsList,
        'location': locationController.text,
        'education': educationController.text,
        'university': universityController.text,
        'gradYear': gradYearController.text,
        'requirment': requirmentController.text,
        'workExperience': workExperienceController.text,
        'company': companyController.text,
      };

      await mentorInfo.updateMenteeProfile(mentorId, updatedData);
      Navigator.pop(context, updatedData); 
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
                 const Padding(
                    padding: EdgeInsets.only(right: 180),
                    child: Text(
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
                _buildChipInput(
                    label: 'Interests',
                    inputController: interestsController,
                    items: interestsList,
                    onAdd: (item) => setState(() => interestsList.add(item)),
                  ),
                _buildChipInput(
                    label: 'Skills',
                    inputController: skillsController,
                    items: skillsList,
                    onAdd: (item) => setState(() => skillsList.add(item)), 
                  ),
                _buildTextField(locationController, 'Location'),
                _buildTextField(educationController, 'Education'),
                _buildTextField(universityController, 'University'),
                _buildTextField(gradYearController, 'Graduation Year'),
                _buildTextField(workExperienceController, 'Work Experience'),
                _buildTextField(companyController, 'Company'),
                _buildTextField(requirmentController, 'Requirment'),
                
        
           
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
  //widget defination for text field
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

  //widget for lists
  Widget _buildChipInput({
      required String label,
      required TextEditingController inputController,
      required List<String> items,
      required Function(String) onAdd,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: inputController,
                  decoration: const InputDecoration(hintText: 'Add...'),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      onAdd(value.trim());
                      inputController.clear();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final value = inputController.text.trim();
                  if (value.isNotEmpty) {
                    onAdd(value);
                    inputController.clear();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6.0,
            children: items
                .map((item) => Chip(
                      label: Text(item),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

}
