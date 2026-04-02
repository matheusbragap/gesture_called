import '../../../core/services/supabase_service.dart';
import '../../../core/constants/user_roles.dart';
import '../models/invite_model.dart';

class InvitesRepository {
  final _client = SupabaseService.client;

  Future<String> getCompanyNameById(int companyId) async {
    final data = await _client
        .from('companies')
        .select('name')
        .eq('id', companyId)
        .maybeSingle();

    if (data == null) {
      return 'Empresa #$companyId';
    }

    final name = data['name'] as String?;
    if (name == null || name.trim().isEmpty) {
      return 'Empresa #$companyId';
    }

    return name;
  }

  /// Admin cria um convite para um email com um cargo específico
  Future<InviteModel> createInvite({
    required String invitedEmail,
    required int companyId,
    required String role,
    required String invitedByUserId,
  }) async {
    final inserted = await _client
        .from('invites')
        .insert({
          'invited_email': invitedEmail,
          'company_id': companyId,
          'role': role,
          'invited_by_user_id': invitedByUserId,
          'status': 'pending',
        })
        .select()
        .single();

    return InviteModel.fromMap(inserted);
  }

  /// Busca convites pendentes para o usuário (por email ou user_id)
  Future<List<InviteModel>> getPendingInvitesForUser(String userEmail) async {
    final data = await _client
        .from('invites')
        .select()
        .eq('invited_email', userEmail)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (data as List).map((e) => InviteModel.fromMap(e)).toList();
  }

  /// Admin busca convites pendentes que ele enviou
  Future<List<InviteModel>> getSentInvites(String adminUserId) async {
    final data = await _client
        .from('invites')
        .select()
        .eq('invited_by_user_id', adminUserId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => InviteModel.fromMap(e)).toList();
  }

  /// Usuário aceita o convite e entra na empresa
  Future<void> acceptInvite({
    required int inviteId,
    required String userId,
    required String userEmail,
  }) async {
    // Busca o convite para pegar os dados
    final inviteData = await _client
        .from('invites')
        .select()
        .eq('id', inviteId)
        .single();

    final invite = InviteModel.fromMap(inviteData);

    // Sai da empresa atual (se houver)
    await _client
        .from('profiles')
        .update({
          'company_id': null,
          'department_id': null,
          'role': UserRoles.iddle,
        })
        .eq('id', userId);

    // Entra na nova empresa com o cargo designado
    await _client
        .from('profiles')
        .update({'company_id': invite.companyId, 'role': invite.role})
        .eq('id', userId);

    // Marca convite como aceito
    await _client
        .from('invites')
        .update({
          'status': 'accepted',
          'invited_user_id': userId,
          'responded_at': DateTime.now().toIso8601String(),
        })
        .eq('id', inviteId);
  }

  /// Usuário rejeita o convite
  Future<void> rejectInvite(int inviteId) async {
    await _client
        .from('invites')
        .update({
          'status': 'rejected',
          'responded_at': DateTime.now().toIso8601String(),
        })
        .eq('id', inviteId);
  }

  /// Admin aprova uma requisição de acesso
  Future<void> approveRequest({
    required String userId,
    required int companyId,
    required String assignedRole,
  }) async {
    await _client
        .from('profiles')
        .update({'company_id': companyId, 'role': assignedRole})
        .eq('id', userId);
  }
}
