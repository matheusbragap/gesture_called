class TicketModel {
  final int id;
  final String titulo;
  final String descricao;
  String status;
  final int unidadeOrigemId;
  final DateTime dataAbertura;
  String? atendenteId;

  TicketModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.status,
    required this.unidadeOrigemId,
    required this.dataAbertura,
    this.atendenteId,
  });

  // Método que "Lê" do Supabase (JSON -> Objeto)
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      status: json['status'] ?? 'Aberto',
      unidadeOrigemId: json['unidade_origem_id'] ?? 0,
      // Converte a String de data do banco para o objeto DateTime do Dart
      dataAbertura: json['data_abertura'] != null 
          ? DateTime.parse(json['data_abertura']) 
          : DateTime.now(),
      atendenteId: json['atendente_id'],
    );
  }

  // Método que "Escreve" no Supabase (Objeto -> JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'status': status,
      'unidade_origem_id': unidadeOrigemId,
      // Converte o DateTime do Dart para o padrão de String do banco de dados (ISO 8601)
      'data_abertura': dataAbertura.toIso8601String(),
      'atendente_id': atendenteId,
    };
  }
}