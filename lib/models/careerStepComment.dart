class StepComment {
  final String stepTitle;
  final String comment;
  final String mentorId;

  StepComment({
    required this.stepTitle,
    required this.comment,
    required this.mentorId,
  });

  factory StepComment.fromMap(Map<String, dynamic> map) {
    return StepComment(
      stepTitle: map['stepTitle'],
      comment: map['comment'],
      mentorId: map['mentorId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stepTitle': stepTitle,
      'comment': comment,
      'mentorId': mentorId,
    };
  }
}
