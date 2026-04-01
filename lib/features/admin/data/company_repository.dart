import '../../../core/services/supabase_service.dart';
import '../models/company_model.dart';

class CompanyRepository {
  final _client = SupabaseService.client;

  Future<CompanyModel> createCompany({
    required String name,
    String? description,
    required String adminUserId,
  }) async {
    final inserted = await _client
        .from('companies')
        .insert({
          'name': name,
          'description': description,
          'isActive': true,
        })
        .select()
        .single();

    final company = CompanyModel.fromMap(inserted);

    await _client.from('profiles').update({
      'company_id': company.id,
    }).eq('id', adminUserId);

    return company;
  }

  Future<CompanyModel?> getCompanyById(int id) async {
    final data = await _client
        .from('companies')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return CompanyModel.fromMap(data);
  }

  Future<void> updateCompany({
    required int id,
    required String name,
    String? description,
  }) async {
    await _client.from('companies').update({
      'name': name,
      'description': description,
    }).eq('id', id);
  }

  /// Remove chamados/mensagens das lojas, lojas, vínculos de perfis e a empresa.
  Future<void> deleteCompanyCascade(int companyId) async {
    final depts = await _client
        .from('departments')
        .select('id')
        .eq('company_id', companyId);
    final deptIds =
        depts.map((e) => (e['id'] as num).toInt()).toList();

    if (deptIds.isNotEmpty) {
      final tickets = await _client
          .from('tickets')
          .select('id')
          .inFilter('department_id', deptIds);
      final ticketIds =
          tickets.map((e) => (e['id'] as num).toInt()).toList();
      if (ticketIds.isNotEmpty) {
        await _client.from('messages').delete().inFilter('ticket_id', ticketIds);
        await _client.from('tickets').delete().inFilter('id', ticketIds);
      }
    }

    await _client.from('departments').delete().eq('company_id', companyId);

    await _client.from('profiles').update({
      'company_id': null,
      'department_id': null,
    }).eq('company_id', companyId);

    await _client.from('companies').delete().eq('id', companyId);
  }
}
