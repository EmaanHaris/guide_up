import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:guide_up/models/careerStep.dart';

class Api{
  final String baseUrl = "https://8d57-111-68-99-9.ngrok-free.app"; //ngrok url
  //functin to get predicted career after sending mentee's information
    Future<Map<String, dynamic>> getCareer(List<String> skills, String education, List<String> interests,String experience) async {
    try{
      String skillsStr = skills.join(', ');
      String interestsStr = interests.join(', ');
      String expStr= experience;
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: { "Content-Type": "application/json"},
        body: jsonEncode({
          "skills": skillsStr,
          "education": education,
          "interests": interestsStr,
          "experience": expStr,
        }),
      );
      if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print("career from model is: $data");
          return {
          'career': data['career_prediction'],
          'roadmap': data['roadmap'], 
        };
      }
      else {
        throw Exception('Failed to get career');
      }
    } catch(e){
      throw Exception('Error: $e');
    }
  }
}

