import '../../domain/entities/ambiente.dart';
import '../../domain/repositories/ambiente_repository.dart';

class AmbienteRepositoryMemory implements AmbienteRepository {
  static final List<Ambiente> _ambientes = [];

  @override
  Future<List<Ambiente>> buscarTodos() async => _ambientes;

  @override
  Future<void> salvar(Ambiente ambiente) async {
    final index = _ambientes.indexWhere((a) => a.id == ambiente.id);

    if (index >= 0) {
      _ambientes[index] = ambiente;
    } else {
      _ambientes.add(ambiente);
    }
  }

  @override
  Future<void> excluir(String id) async => _ambientes.removeWhere((a) => a.id == id);
}