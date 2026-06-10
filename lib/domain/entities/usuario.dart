import 'package:meta/meta.dart';

// Removi 'auditor' do enum. 
// ATENÇÃO: Como usamos .index, manter a ordem dos que restaram é essencial.
enum Perfil { administrador, tecnicoResponsavel, solicitante }

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
      'senha': senha,
      'perfil': perfil.index, // Salva o índice atual (0, 1, 2)
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    // Pegamos o índice salvo. Se por acaso não existir, o '?? 0' garante o perfil padrão.
    final index = map['perfil'] ?? 0;
    
    // Proteção para evitar erro caso o valor salvo fosse '3' (Auditor)
    // Se for maior que o tamanho da lista, volta para o último perfil válido (solicitante)
    final perfilValido = index < Perfil.values.length ? index : Perfil.values.length - 1;

    return Usuario(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      senha: map['senha'],
      perfil: Perfil.values[perfilValido],
    );
  }

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