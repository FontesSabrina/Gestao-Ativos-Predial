import '../../domain/entities/ordem_servico.dart';

class OrdemServicoModel extends OrdemServico {
  OrdemServicoModel({
    required super.id,
    required super.ativoId,
    required super.solicitanteId,
    required super.descricaoProblema,
    required super.dataAbertura,
    required super.prioridade,
    super.tecnicoResponsavelId,
    super.status,
    super.relatotecnico,
    super.dataInicio,
    super.dataFim,
    super.custoPecas,
    super.custoMaoDeObra,
    super.pecasUtilizadas,
    super.dataAprovacao,
    super.aprovadorId,
  });

  factory OrdemServicoModel.fromMap(Map<String, dynamic> map) {
    return OrdemServicoModel(
      id: map['id'],
      ativoId: map['ativoId'],
      solicitanteId: map['solicitanteId'],
      descricaoProblema: map['descricaoProblema'],
      dataAbertura: DateTime.parse(map['dataAbertura']),
      prioridade: map['prioridade'],
      tecnicoResponsavelId: map['tecnicoResponsavelId'],
      status: StatusOS.values[map['status'] ?? 0],
      relatotecnico: map['relatotecnico'],
      custoPecas: (map['custoPecas'] as num?)?.toDouble() ?? 0.0,
      custoMaoDeObra: (map['custoMaoDeObra'] as num?)?.toDouble() ?? 0.0,
      dataInicio: map['dataInicio'] != null ? DateTime.parse(map['dataInicio']) : null,
      dataFim: map['dataFim'] != null ? DateTime.parse(map['dataFim']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ativoId': ativoId,
      'solicitanteId': solicitanteId,
      'descricaoProblema': descricaoProblema,
      'dataAbertura': dataAbertura.toIso8601String(),
      'prioridade': prioridade,
      'tecnicoResponsavelId': tecnicoResponsavelId,
      'status': status.index,
      'relatotecnico': relatotecnico,
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'custoPecas': custoPecas,
      'custoMaoDeObra': custoMaoDeObra,
    };
  }
}