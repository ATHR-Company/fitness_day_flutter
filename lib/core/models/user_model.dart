class UserModel {
  final String name;
  final String email;
  final String phone;
  final double? weight;
  final double? height;
  final String? goal;
  final String? gender;
  final String? birthDate;

  const UserModel({
    required this.name,
    required this.email,
    required this.phone,
    this.weight,
    this.height,
    this.goal,
    this.gender,
    this.birthDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      goal: json['goal'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birthDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'weight': weight,
      'height': height,
      'goal': goal,
      'gender': gender,
      'birthDate': birthDate,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    double? weight,
    double? height,
    String? goal,
    String? gender,
    String? birthDate,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}
