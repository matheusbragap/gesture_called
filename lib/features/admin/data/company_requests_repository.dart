import '../../../core/services/supabase_service.dart';
import '../models/company_request_model.dart';

class CompanyRequestsRepository {
  final _client = SupabaseService.client;

  Future<int?> findActiveCompanyIdByCode(String rawCode) async {
    final code = rawCode.trim();
    if (code.isEmpty) return null;

    // Compatibilidade: tenta colunas comuns de código caso existam no banco.
    for (final field in const ['code', 'invite_code', 'company_code']) {
      try {
        final byField = await _client
            .from('companies')
            .select('id')
            .eq('isActive', true)
            .eq(field, code)
            .maybeSingle();
        if (byField != null) {
          return (byField['id'] as num).toInt();
        }
      } catch (_) {
        // Ignora caso a coluna não exista e usa fallback por ID.
      }
    }

    final numericCode = int.tryParse(code.replaceAll(RegExp(r'[^0-9]'), ''));
    if (numericCode == null) return null;

    final byId = await _client
        .from('companies')
        .select('id')
        .eq('isActive', true)
        .eq('id', numericCode)
        .maybeSingle();

    if (byId == null) return null;
    return (byId['id'] as num).toInt();
  }

  Future<Duration> getInviteCooldownRemaining({
    required String userId,
    Duration cooldown = const Duration(seconds: 10),
  }) async {
    final lastRequest = await _client
        .from('company_requests')
        .select('created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (lastRequest == null) return Duration.zero;

    final createdAtRaw = lastRequest['created_at'] as String?;
    if (createdAtRaw == null) return Duration.zero;

    final createdAt = DateTime.parse(createdAtRaw);
    final elapsed = DateTime.now().difference(createdAt);
    final remaining = cooldown - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<CompanyRequestModel> createOrReplaceRequest({
    required String userId,
    required int companyId,
  }) async {
    await _client
        .from('company_requests')
        .delete()
        .eq('user_id', userId)
        .eq('company_id', companyId);

    return createRequest(userId: userId, companyId: companyId);
  }

  /// Cria uma requisição para entrar em uma empresa
  Future<CompanyRequestModel> createRequest({
    required String userId,
    required int companyId,
  }) async {
    final inserted = await _client
        .from('company_requests')
        .insert({
          'user_id': userId,
          'company_id': companyId,
          'status': 'pending',
        })
        .select()
        .single();

    return CompanyRequestModel.fromMap(inserted);
  }

  /// Busca requests pendentes de um user
  Future<List<CompanyRequestModel>> getPendingRequestsByUser(
    String userId,
  ) async {
    final data = await _client
        .from('company_requests')
        .select()
        .eq('user_id', userId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (data as List).map((e) => CompanyRequestModel.fromMap(e)).toList();
  }

  /// Busca todas as requests pendentes de uma empresa
  Future<List<CompanyRequestModel>> getPendingRequestsByCompany(
    int companyId,
  ) async {
    final data = await _client
        .from('company_requests')
        .select()
        .eq('company_id', companyId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (data as List).map((e) => CompanyRequestModel.fromMap(e)).toList();
  }

  /// Aprova um request
  Future<void> approveRequest({
    required int requestId,
    required String userId,
    required int companyId,
    required String assignedRole,
  }) async {
    await _client
        .from('company_requests')
        .update({'status': 'approved'})
        .eq('id', requestId);

    await _client
        .from('profiles')
        .update({'company_id': companyId, 'role': assignedRole})
        .eq('id', userId);
  }

  /// Rejeita um request
  Future<void> rejectRequest(int requestId) async {
    await _client
        .from('company_requests')
        .update({'status': 'rejected'})
        .eq('id', requestId);
  }
}
