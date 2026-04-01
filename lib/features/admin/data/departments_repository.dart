import '../../../core/services/supabase_service.dart';

class DepartmentsRepository {
  final _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> listByCompany(int companyId) async {
    final data = await _client
        .from('departments')
        .select()
        .eq('company_id', companyId)
        .order('name');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> create({
    required int companyId,
    required String name,
    String? description,
    String? location,
  }) async {
    final row = await _client
        .from('departments')
        .insert({
          'company_id': companyId,
          'name': name,
          'description': description,
          'location': location,
          'isActive': true,
        })
        .select()
        .single();

    return row;
  }

  Future<void> setActive(int id, bool isActive) async {
    await _client.from('departments').update({
      'isActive': isActive,
    }).eq('id', id);
  }

  Future<void> update({
    required int id,
    required String name,
    String? description,
    String? location,
  }) async {
    await _client.from('departments').update({
      'name': name,
      'description': description,
      'location': location,
    }).eq('id', id);
  }

  Future<void> deleteCascade(int departmentId) async {
    final tickets = await _client
        .from('tickets')
        .select('id')
        .eq('department_id', departmentId);
    final ticketIds = tickets
        .map((e) => (e['id'] as num).toInt())
        .toList();
    if (ticketIds.isNotEmpty) {
      await _client.from('messages').delete().inFilter('ticket_id', ticketIds);
      await _client.from('tickets').delete().inFilter('id', ticketIds);
    }
    await _client.from('profiles').update({
      'department_id': null,
    }).eq('department_id', departmentId);
    await _client.from('departments').delete().eq('id', departmentId);
  }
}
