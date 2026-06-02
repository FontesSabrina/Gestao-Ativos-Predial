import '../../domain/entities/ativo.dart';

class AtivoModel extends Ativo {
  AtivoModel({
    required super.id,
    required super.patrimonio,
    required super.nome,
    required super.localizacao,
    required super.estadoConservacao,
    required super.dataAquisicao,
  });

  factory AtivoModel.fromMap(Map<String, dynamic> map) {
    return AtivoModel(
      id: map['id'],
      patrimonio: map['patrimonio'],
      nome: map['nome'],
      localizacao: map['localizacao'],
      estadoConservacao: map['estadoConservacao'],
      dataAquisicao: DateTime.parse(map['dataAquisicao']),
    );
  }

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
}