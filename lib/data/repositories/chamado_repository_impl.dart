import '../../domain/entities/chamado.dart';
import '../../domain/repositories/chamado_repository.dart';
import '../datasources/local/chamado_local_datasource.dart';
import '../../domain/services/notificacao_service.dart';

class ChamadoRepositoryImpl implements ChamadoRepository {
  final ChamadoLocalDataSource localDataSource;

  ChamadoRepositoryImpl(this.localDataSource);

  @override
  Future<List<Chamado>> buscarTodos() async => await localDataSource.buscarTodos();

  @override
  Future<Chamado?> buscarPorId(String id) async => await localDataSource.buscarPorId(id);

  @override
  Future<void> salvar(Chamado chamado) async {
    await localDataSource.salvar(chamado);

    await NotificacaoService.disparar(
      'ADMIN_ID', 
      'Novo Chamado Criado',
      'Chamado para ${chamado.ativo.nome}: ${chamado.descricaoFalha.length > 20 ? chamado.descricaoFalha.substring(0, 20) : chamado.descricaoFalha}...'
    );
  }

  @override
  Future<void> excluir(String id) async => await localDataSource.excluir(id);

  @override
  Future<void> atualizarStatus(String id, StatusChamado novoStatus) async {
    final chamado = await localDataSource.buscarPorId(id);
    if (chamado != null) {
      await localDataSource.salvar(chamado.copyWith(status: novoStatus));
    }
  }

  @override
  Future<List<Chamado>> buscarPorUsuario(String usuarioId) async {
    final todos = await localDataSource.buscarTodos();
    return todos.where((c) => c.solicitante.id == usuarioId).toList();
  }
}