import 'package:meta/meta.dart';
import 'usuario.dart';
import 'ativo.dart';

enum TipoManutencao { corretiva, preventiva, preditiva }
enum StatusChamado { aberto, emExecucao, concluido, cancelado }

@immutable
class Chamado {
  final String id;
  final Ativo ativo; // Mantemos o objeto para uso na UI
  final Usuario solicitante;
  final String descricaoFalha;
  final String prioridade;
  final TipoManutencao tipo;
  final StatusChamado status;
  final DateTime dataAbertura;
  final Usuario? tecnicoResponsavel;

  const Chamado({
    required this.id,
    required this.ativo,
    required this.solicitante,
    required this.descricaoFalha,
    required this.prioridade,
    required this.tipo,
    required this.status,
    required this.dataAbertura,
    this.tecnicoResponsavel,
  });

  // --- PADRÃO AURA PARA SQLite ---

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ativoId': ativo.id, // Chave Estrangeira
      'solicitanteId': solicitante.id, // Chave Estrangeira
      'tecnicoResponsavelId': tecnicoResponsavel?.id,
      'descricaoFalha': descricaoFalha,
      'prioridade': prioridade,
      'tipo': tipo.index,
      'status': status.index,
      'dataAbertura': dataAbertura.toIso8601String(),
    };
  }

  // O fromMap aqui precisaria receber o objeto do Ativo e do Usuario 
  // que você buscaria previamente no seu Banco de Dados (Repository).
  
  Chamado copyWith({
    String? prioridade,
    TipoManutencao? tipo,
    StatusChamado? status,
    Usuario? tecnicoResponsavel,
  }) {
    return Chamado(
      id: id,
      ativo: ativo,
      solicitante: solicitante,
      descricaoFalha: descricaoFalha,
      prioridade: prioridade ?? this.prioridade,
      tipo: tipo ?? this.tipo,
      status: status ?? this.status,
      dataAbertura: dataAbertura,
      tecnicoResponsavel: tecnicoResponsavel ?? this.tecnicoResponsavel,
    );
  }

  factory Chamado.fromMap(Map<String, dynamic> map) {
  // ATENÇÃO: Como o banco salva IDs, você precisará buscar o Ativo e Usuário 
  // no seu Repository antes de chamar este método.
  // Por enquanto, uma forma segura de inicializar é via construtor:
  return Chamado(
    id: map['id'],
    ativo: map['ativo'], // Isso deve ser injetado via repositório
    solicitante: map['solicitante'],
    descricaoFalha: map['descricaoFalha'],
    prioridade: map['prioridade'],
    tipo: TipoManutencao.values[map['tipo'] ?? 0],
    status: StatusChamado.values[map['status'] ?? 0],
    dataAbertura: DateTime.parse(map['dataAbertura']),
  );
}
}