class UserModel {
  final int id;
  final String nome;
  final String email;
  final String perfil;
  final int unidadeId;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
    required this.unidadeId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      perfil: json['perfil'],
      unidadeId: json['unidade_id'],
    );
  }
}