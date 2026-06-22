import '../entities/chamado.dart';
import '../entities/usuario.dart';
import '../entities/ordem_servico.dart';
import '../entities/notificacao.dart';
import '../repositories/ordem_servico_repository.dart';
import '../repositories/chamado_repository.dart';
import '../repositories/notificacao_repository.dart';

class ChamadoDomainServices {
  final OrdemServicoRepository _osRepository;
  final ChamadoRepository _chamadoRepository;
  final NotificacaoRepository _notificacaoRepository;

  ChamadoDomainServices(
    this._osRepository, 
    this._chamadoRepository, 
    this._notificacaoRepository
  );

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

  Future<List<Chamado>> buscarTodos() async => await _chamadoRepository.buscarTodos();
  Future<void> registrarChamado(Chamado chamado) async => await _chamadoRepository.salvar(chamado);

  Future<void> cancelarChamado(Chamado chamado) async {
    await _chamadoRepository.atualizarStatus(chamado.id, StatusChamado.cancelado);
    await _enviarNotificacao(
      "Chamado Cancelado",
      "O chamado para o ativo '${chamado.ativo.nome}' foi cancelado pelo gestor.",
      chamado.solicitante.id
    );
  }

  Future<void> aprovarChamadoEGerarOS({
    required Chamado chamado,
    required Usuario tecnico,
    required Usuario usuarioLogado,
  }) async {
    if (usuarioLogado.perfil != Perfil.administrador) {
      throw Exception("Acesso Negado: Apenas administradores podem designar técnicos.");
    }

    await _chamadoRepository.atualizarStatus(chamado.id, StatusChamado.emExecucao);

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
    await _chamadoRepository.atualizarStatus(ordem.id, StatusChamado.concluido);

    await _enviarNotificacao(
      "Manutenção Finalizada",
      "A ordem de serviço para o chamado ${ordem.id} foi concluída com sucesso.",
      ordem.solicitanteId
    );
  }
}