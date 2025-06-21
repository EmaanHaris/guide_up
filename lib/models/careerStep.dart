class CareerStep {
  final String title;
  final List<String> skills;
  final List<Project> projects;
  final List<String> resources;

  CareerStep({
    required this.title,
    required this.skills,
    required this.projects,
    required this.resources,
  });

  factory CareerStep.fromMap(Map<String, dynamic> map) {
    return CareerStep(
      title: map['title'],
      skills: List<String>.from(map['skills'] ?? []),
      projects: (map['projects'] as List).map<Project>((p) {
          if (p is String) {
            return Project(title: p); //default completed to false
          } else if (p is Map<String, dynamic>) {
            return Project.fromMap(p);
          } else {
            throw Exception('Invalid project format');
          }
       }).toList(),
      resources: List<String>.from(map['resources'] ?? []),
    );
  }

   Map<String, dynamic> toMap() {
      return {
        'title': title,
        'skills': skills,
        'projects': projects.map((p) => p.toMap()).toList(),
        'resources': resources,
      };
    }
}
class Project {
  final String title;
  late final bool completed;

  Project({required this.title, this.completed = false});

   Project copyWith({String? title, bool? completed}) {
    return Project(
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'completed': completed,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      title: map['title'] ?? '',
      completed: map['completed'] ?? false,
    );
  }
}
