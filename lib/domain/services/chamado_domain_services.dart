import '../entities/chamado.dart';
import '../entities/usuario.dart';
import '../entities/ordem_servico.dart';
import '../entities/notificacao.dart'; // Importante adicionar
import '../repositories/ordem_servico_repository.dart';
import '../repositories/chamado_repository.dart';
import '../repositories/notificacao_repository.dart'; // Importante adicionar

class ChamadoDomainServices {
  final OrdemServicoRepository _osRepository;
  final ChamadoRepository _chamadoRepository;
  final NotificacaoRepository _notificacaoRepository;

  ChamadoDomainServices(
    this._osRepository, 
    this._chamadoRepository, 
    this._notificacaoRepository
  );

  // --- Método Auxiliar Privado ---
  Future<void> _enviarNotificacao(String titulo, String mensagem, String usuarioId) async {
    final novaNotificacao = Notificacao(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      mensagem: mensagem,
      dataCriacao: DateTime.now(),
      lida: false,
      usuarioId: usuarioId,
    );
    await _notificacaoRepository.adicionarNotificacao(novaNotificacao);
  }

  // --- Métodos de Negócio ---

  Future<List<Chamado>> buscarTodos() async => await _chamadoRepository.buscarTodos();

  Future<void> registrarChamado(Chamado chamado) async => await _chamadoRepository.salvar(chamado);

  Future<void> aprovarChamadoEGerarOS({
    required Chamado chamado,
    required Usuario tecnico,
  }) async {
    // 1. Atualiza status
    await _chamadoRepository.atualizarStatus(chamado.id, StatusChamado.emExecucao);

    // 2. Gera a OS
    final novaOS = OrdemServico(
      id: chamado.id,
      ativoId: chamado.ativo.id,
      solicitanteId: chamado.solicitante.id,
      descricaoProblema: chamado.descricaoFalha,
      prioridade: chamado.prioridade,
      status: StatusOS.aberta,
      dataAbertura: chamado.dataAbertura,
      tecnicoResponsavelId: tecnico.id,
    );
    await _osRepository.salvar(novaOS);

    // 3. Notifica o solicitante
    await _enviarNotificacao(
      "Chamado Aprovado",
      "O chamado ${chamado.id} foi aprovado e a manutenção iniciada.",
      chamado.solicitante.id
    );
  }

  Future<void> finalizarOS({
    required OrdemServico ordem,
    required String relato,
    required double custoPecas,
    required double custoMaoDeObra,
    required Usuario executor,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    
    final osFinalizada = ordem.copyWith(
      status: StatusOS.concluida,
      relatotecnico: relato, 
      custoPecas: custoPecas,
      custoMaoDeObra: custoMaoDeObra,
      dataInicio: dataInicio,
      dataFim: dataFim ?? DateTime.now(),
    );
    
    await _osRepository.salvar(osFinalizada);

    // Notifica o solicitante que a manutenção foi concluída
    await _enviarNotificacao(
      "Manutenção Finalizada",
      "A ordem de serviço para o chamado ${ordem.id} foi concluída com sucesso.",
      ordem.solicitanteId
    );
  }
}