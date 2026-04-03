class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final int? companyId;
  final int? departmentId;
  final bool isActive;
  final DateTime lastSeen;
  final DateTime createdAt;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.companyId,
    this.departmentId,
    required this.isActive,
    required this.lastSeen,
    required this.createdAt,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phone_number'],
      companyId: map['company_id'] != null
          ? (map['company_id'] as num).toInt()
          : null,
      departmentId: map['department_id'] != null
          ? (map['department_id'] as num).toInt()
          : null,
      isActive: map['isActive'],
      lastSeen: DateTime.parse(map['lastSeen']),
      createdAt: DateTime.parse(map['created_at']),
      role: map['role'] ?? 'employee',
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    int? companyId,
    int? departmentId,
    bool? isActive,
    DateTime? lastSeen,
    DateTime? createdAt,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      companyId: companyId ?? this.companyId,
      departmentId: departmentId ?? this.departmentId,
      isActive: isActive ?? this.isActive,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }
}
