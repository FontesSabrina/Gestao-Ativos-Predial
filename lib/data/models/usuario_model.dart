import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  UsuarioModel({
    required super.id,
    required super.nome,
    required super.email,
    required super.senha,
    required super.perfil,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    final index = map['perfil'] ?? 0;
    final perfilValido = index < Perfil.values.length ? index : Perfil.values.length - 1;

    return UsuarioModel(
      id: map['id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? 'Usuário', 
      email: map['email']?.toString() ?? '',
      senha: map['senha']?.toString() ?? '',
      perfil: Perfil.values[perfilValido],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'perfil': perfil.index,
    };
  }
}