import 'package:meta/meta.dart';

@immutable
class Ativo {
  final String id;
  final String patrimonio;
  final String nome;
  final String localizacao;
  final String estadoConservacao;
  final DateTime dataAquisicao;

  const Ativo({
    required this.id,
    required this.patrimonio,
    required this.nome,
    required this.localizacao,
    required this.estadoConservacao,
    required this.dataAquisicao,
  });

  // --- PADRÃO AURA PARA SQLite ---

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patrimonio': patrimonio,
      'nome': nome,
      'localizacao': localizacao,
      'estadoConservacao': estadoConservacao,
      'dataAquisicao': dataAquisicao.toIso8601String(),
    };
  }

  factory Ativo.fromMap(Map<String, dynamic> map) {
    return Ativo(
      id: map['id'],
      patrimonio: map['patrimonio'],
      nome: map['nome'],
      localizacao: map['localizacao'],
      estadoConservacao: map['estadoConservacao'],
      dataAquisicao: DateTime.parse(map['dataAquisicao']),
    );
  }

  // Método copyWith para facilitar as atualizações no estado
  Ativo copyWith({
    String? patrimonio,
    String? nome,
    String? localizacao,
    String? estadoConservacao,
  }) {
    return Ativo(
      id: id,
      patrimonio: patrimonio ?? this.patrimonio,
      nome: nome ?? this.nome,
      localizacao: localizacao ?? this.localizacao,
      estadoConservacao: estadoConservacao ?? this.estadoConservacao,
      dataAquisicao: dataAquisicao,
    );
  }
}