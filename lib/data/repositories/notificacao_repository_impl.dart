import '../../domain/entities/notificacao.dart';
import '../../domain/repositories/notificacao_repository.dart';
import '../datasources/local/notificacao_local_datasource.dart';

class NotificacaoRepositoryImpl implements NotificacaoRepository {
  final NotificacaoLocalDataSource dataSource;

  NotificacaoRepositoryImpl(this.dataSource);

  @override
  Future<List<Notificacao>> buscarNotificacoesDoUsuario(String usuarioId) async {
    return await dataSource.buscarPorUsuario(usuarioId);
  }

  @override
  Future<void> adicionarNotificacao(Notificacao notificacao) async {
    await dataSource.salvar(notificacao);
  }

  @override
  Future<void> marcarComoLida(String id) async {
    await dataSource.marcarComoLida(id);
  }
}