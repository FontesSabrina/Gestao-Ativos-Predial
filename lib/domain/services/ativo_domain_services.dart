import '../entities/ativo.dart';
import '../repositories/ativo_repository.dart';

class AtivoDomainServices {
  final AtivoRepository _repository;

  AtivoDomainServices(this._repository);

  Future<List<Ativo>> buscarTodos() async => await _repository.buscarTodos();

  Future<void> salvar(Ativo ativo) async {
    await _repository.salvar(ativo);
  }

  bool verificarNecessidadeTroca(Ativo ativo) {
    return ativo.estadoConservacao.toLowerCase() == "pessimo";
  }
}