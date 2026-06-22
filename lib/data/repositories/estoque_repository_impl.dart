import '../../domain/entities/item_estoque.dart';
import '../../domain/repositories/estoque_repository.dart';
import '../datasources/local/estoque_local_datasource.dart';

class EstoqueRepositoryImpl implements EstoqueRepository {
  final EstoqueLocalDataSource localDataSource;

  EstoqueRepositoryImpl(this.localDataSource);

  @override
  Future<List<ItemEstoque>> buscarTodos() async {
    return await localDataSource.buscarTodos();
  }

  @override
  Future<ItemEstoque?> buscarPorId(String id) async {
    return await localDataSource.buscarPorId(id);
  }

  @override
  Future<void> salvar(ItemEstoque item) async {
    await localDataSource.salvar(item);
  }

  @override
  Future<void> excluir(String id) async {
    await localDataSource.excluir(id);
  }

  @override
  Future<void> atualizarQuantidade(String id, int novaQuantidade) async {
    await localDataSource.atualizarQuantidade(id, novaQuantidade);
  }

  @override
  Future<List<ItemEstoque>> buscarItensAbaixoDoMinimo() async {
    final todos = await localDataSource.buscarTodos();
    return todos.where((item) => item.quantidade <= item.nivelMinimo).toList();
  }
}