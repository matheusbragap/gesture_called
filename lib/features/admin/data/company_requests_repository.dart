import '../../../core/services/supabase_service.dart';
import '../models/company_request_model.dart';

class CompanyRequestsRepository {
  final _client = SupabaseService.client;

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
  Future<List<CompanyRequestModel>> getPendingRequestsByUser(String userId) async {
    final data = await _client
        .from('company_requests')
        .select()
        .eq('user_id', userId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (data as List).map((e) => CompanyRequestModel.fromMap(e)).toList();
  }

  /// Busca todas as requests pendentes de uma empresa
  Future<List<CompanyRequestModel>> getPendingRequestsByCompany(int companyId) async {
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
    await _client.from('company_requests').update({
      'status': 'approved',
    }).eq('id', requestId);

    await _client.from('profiles').update({
      'company_id': companyId,
      'role': assignedRole,
    }).eq('id', userId);
  }

  /// Rejeita um request
  Future<void> rejectRequest(int requestId) async {
    await _client.from('company_requests').update({
      'status': 'rejected',
    }).eq('id', requestId);
  }
}
