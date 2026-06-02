import '../../domain/entities/ambiente.dart';
import '../../domain/repositories/ambiente_repository.dart';
import '../datasources/local/ambiente_local_datasource.dart';

class AmbienteRepositoryImpl implements AmbienteRepository {
  final AmbienteLocalDataSource localDataSource;

  AmbienteRepositoryImpl(this.localDataSource);

  @override
  Future<List<Ambiente>> buscarTodos() => localDataSource.buscarTodos();

  @override
  Future<void> salvar(Ambiente ambiente) => localDataSource.salvar(ambiente);

  @override
  Future<void> excluir(String id) => localDataSource.excluir(id);
}