import '../entities/notificacao.dart';

abstract class NotificacaoRepository {
  Future<List<Notificacao>> buscarNotificacoesDoUsuario(String usuarioId);
  Future<void> adicionarNotificacao(Notificacao notificacao);
  Future<void> marcarComoLida(String id);
}