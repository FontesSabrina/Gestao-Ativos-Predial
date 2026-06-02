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
    return UsuarioModel(
      id: map['id'] ?? 0,
      nome: map['nome']?.toString() ?? 'Usuário', 
      email: map['email'] ?? '',
      senha: map['senha'] ?? '',
      perfil: Perfil.values[map['perfil'] ?? 0],
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