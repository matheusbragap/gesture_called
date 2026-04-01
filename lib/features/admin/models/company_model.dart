class CompanyModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  CompanyModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      description: map['description'] as String?,
      isActive: map['isActive'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
