import '../../../core/services/supabase_service.dart';

class CategoriesRepository {
  final _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> listAll() async {
    try {
      final data = await _client.from('categories').select().order('name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('ERRO CATEGORIAS: $e'); // Adicione isto
      rethrow;
    }
  }

  Future<Map<String, dynamic>> create({
    required String name,
    String? description,
  }) async {
    try {
      final row = await _client
          .from('categories')
          .insert({'name': name, 'description': description, 'is_active': true})
          .select()
          .single();

      return row;
    } catch (e) {
      print('ERRO CREATE CATEGORIA: $e');
      rethrow;
    }
  }

  Future<void> setActive(int id, bool isActive) async {
    await _client
        .from('categories')
        .update({'is_active': isActive})
        .eq('id', id);
  }

  Future<void> update({
    required int id,
    required String name,
    String? description,
  }) async {
    await _client
        .from('categories')
        .update({'name': name, 'description': description})
        .eq('id', id);
  }

  Future<void> deleteById(int id) async {
    final rows = await _client
        .from('tickets')
        .select('id')
        .eq('category_id', id)
        .limit(1);
    if (rows.isNotEmpty) {
      throw Exception(
        'Não é possível excluir: existem chamados vinculados a esta categoria.',
      );
    }
    await _client.from('categories').delete().eq('id', id);
  }
}
