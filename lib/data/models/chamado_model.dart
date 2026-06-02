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

  // Este método converte o Map do Banco de Dados para a sua Entidade
  factory ChamadoModel.fromMap(Map<String, dynamic> map) {
    return ChamadoModel(
      id: map['id'] as String,
      // Criamos um "esqueleto" de Ativo e Usuario, pois o banco só tem o ID
      ativo: Ativo(
        id: map['ativoId'] as String,
        nome: 'Carregando...', 
        patrimonio: '', 
        localizacao: '', 
        estadoConservacao: '', 
        dataAquisicao: DateTime.now()
      ),
      solicitante: Usuario(
        id: map['solicitanteId'] as String? ?? '', 
        nome: 'Carregando...', 
        email: '', 
        perfil: Perfil.solicitante, 
        senha: ''
      ),
      descricaoFalha: map['descricao'] as String? ?? '',
      prioridade: map['prioridade'] as String? ?? 'Baixa',
      tipo: TipoManutencao.values.firstWhere((e) => e.name == map['tipo'], orElse: () => TipoManutencao.preventiva),
      status: StatusChamado.values.firstWhere((e) => e.name == map['status'], orElse: () => StatusChamado.aberto),
      dataAbertura: DateTime.parse(map['dataCriacao'] as String),
    );
  }
}