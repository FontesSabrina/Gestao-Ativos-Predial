import '../../domain/entities/ambiente.dart';
import '../../domain/repositories/ambiente_repository.dart';

class AmbienteRepositoryMemory implements AmbienteRepository {
  static final List<Ambiente> _ambientes = [];

  @override
  Future<List<Ambiente>> buscarTodos() async => _ambientes;

  @override
  Future<void> salvar(Ambiente ambiente) async {
    // 1. Tenta encontrar o índice do ambiente que já existe na lista pelo ID
    final index = _ambientes.indexWhere((a) => a.id == ambiente.id);

    if (index >= 0) {
      // 2. Se o índice for maior ou igual a 0, significa que o ambiente já existe.
      // Então nós substituímos o antigo pelo novo.
      _ambientes[index] = ambiente;
    } else {
      // 3. Se não encontrar (index == -1), é um novo ambiente, aí sim damos o .add()
      _ambientes.add(ambiente);
    }
  }

  @override
  Future<void> excluir(String id) async => _ambientes.removeWhere((a) => a.id == id);
}