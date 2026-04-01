import '../../../core/services/supabase_service.dart';

class AdminUsersRepository {
  final _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> listAllInCompany(int companyId) async {
    final data = await _client
        .from('profiles')
        .select(
          'id, name, email, phone_number, role, isActive, company_id, department_id, '
          'departments ( id, name )',
        )
        .eq('company_id', companyId)
        .order('name');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> createUserInCompany({
    required String name,
    required String email,
    required String password,
    required String role,
    required int companyId,
    int? departmentId,
  }) async {
    final oldRefresh = _client.auth.currentSession?.refreshToken;
    if (oldRefresh == null || oldRefresh.isEmpty) {
      throw Exception('Sessão inválida. Entre novamente.');
    }

    final res = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name},
    );

    final newUser = res.user;
    if (newUser == null) {
      await _client.auth.setSession(oldRefresh);
      throw Exception(
        'Não foi possível criar o usuário. Verifique se o e-mail já existe ou se a confirmação por e-mail está desativada no Supabase.',
      );
    }

    try {
      await _client.from('profiles').insert({
        'id': newUser.id,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': role,
        'company_id': companyId,
        'department_id': departmentId,
        'isActive': true,
      });
    } catch (e) {
      await _client.auth.setSession(oldRefresh);
      rethrow;
    }

    await _client.auth.setSession(oldRefresh);
  }

  Future<void> updateUser({
    required String userId,
    required String role,
    int? departmentId,
    required bool isActive,
  }) async {
    await _client.from('profiles').update({
      'role': role,
      'department_id': departmentId,
      'isActive': isActive,
    }).eq('id', userId);
  }

  Future<void> removeUserFromCompany(String userId) async {
    await _client.from('profiles').update({
      'company_id': null,
      'department_id': null,
    }).eq('id', userId);
  }

  Future<void> allocateEmployeeByEmail({
    required String email,
    required int companyId,
  }) async {
    final trimmed = email.trim();
    final row = await _client
        .from('profiles')
        .select()
        .ilike('email', trimmed)
        .maybeSingle();

    if (row == null) {
      throw Exception('Nenhum usuário encontrado com este e-mail.');
    }

    if (row['company_id'] != null) {
      throw Exception('Este usuário já pertence a uma empresa.');
    }

    await _client.from('profiles').update({
      'company_id': companyId,
    }).eq('id', row['id']);
  }
}
