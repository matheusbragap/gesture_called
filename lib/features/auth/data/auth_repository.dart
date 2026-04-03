import '../models/user_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/constants/user_roles.dart';


class AuthRepository {
  final _client = SupabaseService.client;

  Future<UserModel> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final userId = response.user!.id;
    return await _fetchProfile(userId);
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  Future<UserModel> _fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserModel.fromMap(data);
  }

  Future<UserModel?> getCurrentUser() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;
    return await _fetchProfile(session.user.id);
  }

  Future<bool> checkEmailExists(String email) async {
    final data = await _client
        .from('profiles')
        .select('email')
        .eq('email', email);

    return data.isNotEmpty;
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone_number': phoneNumber,
      },
    );

    final userId = response.user!.id;

    await _client.from('profiles').insert({
      'id': userId,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'role': 'iddle',
      'isActive': true,
    });

    return await _fetchProfile(userId);
  }

  Future<void> updateProfileName({
    required String userId,
    required String name,
  }) async {
    await _client.from('profiles').update({
      'name': name,
    }).eq('id', userId);
  }

  Future<void> leaveCompany({required String userId}) async {
    await _client.from('profiles').update({
      'company_id': null,
      'department_id': null,
      'role': UserRoles.iddle,
    }).eq('id', userId);
  }
}
