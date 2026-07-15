class BranchModel {
  final String id;
  final String type;
  final String name;
  final int order;

  BranchModel({
    required this.id,
    required this.type,
    required this.name,
    required this.order,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      order: json['order'] ?? 0,
    );
  }
}
