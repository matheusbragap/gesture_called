import 'dart:developer' as developer;

import '../../../core/services/supabase_service.dart';

class CategoriesRepository {
  final _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> listAll({required int companyId}) async {
    try {
      final data = await _client
          .from('categories')
          .select()
          .eq('company_id', companyId)
          .order('name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      developer.log(
        'Erro ao listar categorias',
        name: 'CategoriesRepository',
        error: e,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> create({
    required int companyId,
    required String name,
    String? description,
  }) async {
    try {
      final row = await _client
          .from('categories')
          .insert({
            'company_id': companyId,
            'name': name,
            'description': description,
            'is_active': true,
          })
          .select()
          .single();

      return row;
    } catch (e) {
      developer.log(
        'Erro ao criar categoria',
        name: 'CategoriesRepository',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> setActive(
    int id,
    bool isActive, {
    required int companyId,
  }) async {
    await _client
        .from('categories')
        .update({'is_active': isActive})
        .eq('id', id)
        .eq('company_id', companyId);
  }

  Future<void> update({
    required int id,
    required int companyId,
    required String name,
    String? description,
  }) async {
    await _client
        .from('categories')
        .update({'name': name, 'description': description})
        .eq('id', id)
        .eq('company_id', companyId);
  }

  Future<void> deleteById(int id, {required int companyId}) async {
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
    await _client
        .from('categories')
        .delete()
        .eq('id', id)
        .eq('company_id', companyId);
  }
}
