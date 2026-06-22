import '../../domain/entities/chamado.dart';
import '../../domain/entities/ativo.dart';
import '../../domain/entities/usuario.dart';

class ChamadoModel extends Chamado {
  ChamadoModel({
    required super.id,
    required super.ativo,
    required super.solicitante,
    required super.descricaoFalha,
    required super.prioridade,
    required super.tipo,
    required super.status,
    required super.dataAbertura,
    super.tecnicoResponsavel,
  });


  factory ChamadoModel.fromMap(Map<String, dynamic> map) {
    return ChamadoModel(
      id: map['id'] as String,
      ativo: Ativo(
        id: map['ativoId'] as String,
        nome: 'Carregando...', 
        patrimonio: '', 
        localizacao: '', 
        estadoConservacao: '', 
        dataAquisicao: DateTime.now(),
      ),
      solicitante: Usuario(
        id: map['solicitanteId'] as String? ?? '', 
        nome: 'Carregando...', 
        email: '', 
        perfil: Perfil.solicitante, 
        senha: '',
      ),
      descricaoFalha: map['descricaoFalha'] as String? ?? '',
      prioridade: map['prioridade'] as String? ?? 'Baixa',
      tipo: TipoManutencao.values[map['tipo'] ?? 0],
      status: StatusChamado.values[map['status'] ?? 0],
      dataAbertura: DateTime.parse(map['dataAbertura'] as String),
      tecnicoResponsavel: map['tecnicoResponsavelId'] != null
          ? Usuario(
              id: map['tecnicoResponsavelId'] as String,
              nome: 'Carregando...',
              email: '',
              perfil: Perfil.tecnicoResponsavel,
              senha: '',
            )
          : null,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ativoId': ativo.id,
      'solicitanteId': solicitante.id,
      'tecnicoResponsavelId': tecnicoResponsavel?.id,
      'descricaoFalha': descricaoFalha,
      'prioridade': prioridade,
      'tipo': tipo.index,
      'status': status.index,
      'dataAbertura': dataAbertura.toIso8601String(),
    };
  }
}