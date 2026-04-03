import '../../../core/services/supabase_service.dart';

class TicketsRepository {
  final _client = SupabaseService.client;

  Future<void> createTicket({
    required String title,
    required String description,
    required String creatorId,
    required int departmentId,
    required int categoryId,
  }) async {
    await _client.from('tickets').insert({
      'title': title,
      'description': description,
      'creator_employee_id': creatorId,
      'department_id': departmentId,
      'category_id': categoryId,
      'status': 'open',
    });
  }

  Future<List<Map<String, dynamic>>> listTicketsForEmployee(String creatorId) async {
    final data = await _client
        .from('tickets')
        .select(
          'id, title, description, status, created_at, '
          'department_id, category_id, creator_employee_id, current_attendant_id, '
          'departments ( id, name ), categories ( id, name )',
        )
        .eq('creator_employee_id', creatorId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> listTicketsForCompany(int companyId) async {
    final depts = await _client
        .from('departments')
        .select('id')
        .eq('company_id', companyId);
    final ids = depts
        .map((e) => (e['id'] as num).toInt())
        .toList();
    if (ids.isEmpty) return [];

    final data = await _client
        .from('tickets')
        .select(
          'id, title, description, status, created_at, '
          'department_id, category_id, creator_employee_id, current_attendant_id, '
          'departments ( id, name ), categories ( id, name )',
        )
        .inFilter('department_id', ids)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getDepartmentsByCompany(int companyId) async {
    final data = await _client
        .from('departments')
        .select()
        .eq('company_id', companyId)
        .eq('isActive', true)
        .order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getCategories(int companyId) async {
    final data = await _client
        .from('categories')
        .select()
        .eq('company_id', companyId)
        .eq('is_active', true)
        .order('name');
    return List<Map<String, dynamic>>.from(data);
  }
}
