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