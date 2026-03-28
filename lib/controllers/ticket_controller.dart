import '../models/ticket_model.dart';
import '../services/api_service.dart';

class TicketController {
  
  // 1. Busca todos os chamados
  Future<List<TicketModel>> fetchTickets(String token) async {
    final response = await ApiService.get('/chamados', token: token);
    
    // Converte a lista de JSONs que vem da API numa lista de objetos Dart limpos
    return (response as List).map((json) => TicketModel.fromJson(json)).toList();
  }

  // 2. Cria um novo chamado aplicando a regra de unidade
  Future<bool> createTicket({
    required String titulo,
    required String descricao,
    required int unidadeOrigemId, // ID extraído do utilizador logado
    required String token,
  }) async {
    final ticketBody = {
      'titulo': titulo,
      'descricao': descricao,
      'unidade_origem_id': unidadeOrigemId,
    };

    try {
      await ApiService.post('/chamados', ticketBody, token: token);
      return true; // Sucesso na criação
    } catch (e) {
      // O ApiService já lançou a exceção limpa, a View pode mostrá-la num alerta
      throw Exception('Erro ao criar chamado: $e');
    }
  }
}