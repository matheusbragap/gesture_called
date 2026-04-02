class CompanyRequestModel {
  final int id;
  final String userId;
  final int companyId;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime? updatedAt;

  CompanyRequestModel({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory CompanyRequestModel.fromMap(Map<String, dynamic> map) {
    return CompanyRequestModel(
      id: (map['id'] as num).toInt(),
      userId: map['user_id'],
      companyId: (map['company_id'] as num).toInt(),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}
