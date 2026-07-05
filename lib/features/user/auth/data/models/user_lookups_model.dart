class LookupItem {
  final String id;
  final String type;
  final String name;
  final int order;

  const LookupItem({
    required this.id,
    required this.type,
    required this.name,
    required this.order,
  });

  factory LookupItem.fromJson(Map<String, dynamic> json) {
    return LookupItem(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      order: json['order'] as int? ?? 0,
    );
  }
}

class UserLookupsResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final List<LookupItem> goals;
  final List<LookupItem> activityLevels;
  final List<LookupItem> branches;

  const UserLookupsResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.goals,
    required this.activityLevels,
    required this.branches,
  });

  factory UserLookupsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final goalsList = (data['goals'] as List? ?? [])
        .map((e) => LookupItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final activityLevelsList = (data['activityLevels'] as List? ?? [])
        .map((e) => LookupItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final branchesList = (data['branches'] as List? ?? [])
        .map((e) => LookupItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return UserLookupsResponseModel(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      goals: goalsList,
      activityLevels: activityLevelsList,
      branches: branchesList,
    );
  }
}
