class TicketModel {
  final int id;
  final String titulo;
  final String descricao;
  final String status;
  final int unidadeOrigemId;

  TicketModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.status,
    required this.unidadeOrigemId,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      status: json['status'],
      unidadeOrigemId: json['unidade_origem_id'],
    );
  }

  // Método para enviar dados para a API de forma limpa
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'unidade_origem_id': unidadeOrigemId,
    };
  }
}