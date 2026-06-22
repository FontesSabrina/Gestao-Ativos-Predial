import '../../domain/entities/ativo.dart';
import '../../domain/repositories/ativo_repository.dart';
import '../datasources/local/ativo_local_datasource.dart';

class AtivoRepositoryImpl implements AtivoRepository {
  final AtivoLocalDataSource localDataSource;

  AtivoRepositoryImpl(this.localDataSource);

  @override
  Future<List<Ativo>> buscarTodos() async {
    return await localDataSource.buscarTodos();
  }

  @override
  Future<Ativo?> buscarPorId(String id) async {
    return await localDataSource.buscarPorId(id);
  }

  @override
  Future<void> salvar(Ativo ativo) async {
    await localDataSource.salvar(ativo);
  }

  @override
  Future<void> excluir(String id) async {
    await localDataSource.excluir(id);
  }

  @override
  Future<List<Ativo>> buscarPorLocalizacao(String localizacao) async {
    final todos = await localDataSource.buscarTodos();
    return todos.where((ativo) => ativo.localizacao == localizacao).toList();
  }
}