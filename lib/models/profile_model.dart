class ProfileModel {
  final String id; // UUID que vem do auth.users
  final String name;
  final String email;
  final String? phoneNumber;
  final int? companyId; // Pode ser nulo
  final bool isActive;
  final DateTime lastSeen;
  final DateTime createdAt;
  
  // ⚠️ REGRA DE NEGÓCIO: Adicionada temporariamente no Front-end.
  // Você precisará adicionar uma coluna 'role' na tabela 'profiles' do Supabase.
  final String role; 

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.companyId,
    required this.isActive,
    required this.lastSeen,
    required this.createdAt,
    required this.role, // 'tecnico' ou 'funcionario'
  });

  // Getter inteligente para a Permissão (RBAC) que usamos na tela de Detalhes
  bool get isTecnico => role == 'tecnico';

  // Método para ler do Supabase
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      companyId: json['company_id'],
      isActive: json['isActive'] ?? true,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : DateTime.now(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      role: json['role'] ?? 'funcionario', // Assume 'funcionario' por segurança se não existir
    );
  }

  // Método para enviar para o Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'company_id': companyId,
      'isActive': isActive,
      'lastSeen': lastSeen.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'role': role,
    };
  }
}

// SIMULAÇÃO DO USUÁRIO LOGADO (Para testar a tela de detalhes agora)
final usuarioLogado = ProfileModel(
  id: 'uuid-falso-123',
  name: 'Arlisson Santos',
  email: 'arlisson@email.com',
  isActive: true,
  lastSeen: DateTime.now(),
  createdAt: DateTime.now(),
  role: 'tecnico', // Mude para 'funcionario' para testar o bloqueio na tela de chamados
);