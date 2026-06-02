import 'package:meta/meta.dart';

// Presumindo que Perfil seja um enum ou outra classe que você tenha definido
enum Perfil { administrador, tecnicoResponsavel, solicitante, auditor }

@immutable
class Usuario {
  final String id;
  final String nome;
  final String email;
  final String senha;
  final Perfil perfil;

  const Usuario({
    required this.id, 
    required this.nome, 
    required this.email, 
    required this.senha, 
    required this.perfil,
  });

  // Métodos de igualdade que você já tinha (ótimos para comparar usuários no app)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Usuario && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // --- PADRÃO AURA PARA SQLite ---

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha, // Lembre-se: idealmente, nunca salve a senha em texto puro!
      'perfil': perfil.index,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      senha: map['senha'],
      perfil: Perfil.values[map['perfil'] ?? 0],
    );
  }

  // Método copyWith para seguir o padrão de imutabilidade
  Usuario copyWith({
    String? id,
    String? nome,
    String? email,
    String? senha,
    Perfil? perfil,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      perfil: perfil ?? this.perfil,
    );
  }
}