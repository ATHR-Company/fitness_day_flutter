class ChallengeModel {
  final String title;
  final String goal;
  final String startDate;
  final String endDate;
  final int participants;
  final String? imageUrl;
  final bool isActive;

  const ChallengeModel({
    required this.title,
    required this.goal,
    required this.startDate,
    required this.endDate,
    required this.participants,
    this.imageUrl,
    this.isActive = false,
  });
}
