class InviteModel {
  final int id;
  final String invitedEmail;
  final String? invitedUserId;
  final int companyId;
  final String role;
  final String status; // 'pending', 'accepted', 'rejected'
  final String invitedByUserId;
  final DateTime createdAt;
  final DateTime? respondedAt;

  InviteModel({
    required this.id,
    required this.invitedEmail,
    this.invitedUserId,
    required this.companyId,
    required this.role,
    required this.status,
    required this.invitedByUserId,
    required this.createdAt,
    this.respondedAt,
  });

  factory InviteModel.fromMap(Map<String, dynamic> map) {
    return InviteModel(
      id: (map['id'] as num).toInt(),
      invitedEmail: map['invited_email'],
      invitedUserId: map['invited_user_id'],
      companyId: (map['company_id'] as num).toInt(),
      role: map['role'],
      status: map['status'] ?? 'pending',
      invitedByUserId: map['invited_by_user_id'],
      createdAt: DateTime.parse(map['created_at']),
      respondedAt: map['responded_at'] != null ? DateTime.parse(map['responded_at']) : null,
    );
  }
}
