import '../../domain/entities/ambiente.dart';
import '../../domain/repositories/ambiente_repository.dart';

class AmbienteRepositoryMemory implements AmbienteRepository {
  // Tornar a lista static garante que ela sobreviva a qualquer reconstrução
  static final List<Ambiente> _ambientes = [];

  @override
  Future<List<Ambiente>> buscarTodos() async => _ambientes;

  @override
  Future<void> salvar(Ambiente ambiente) async => _ambientes.add(ambiente);

  @override
  Future<void> excluir(String id) async => _ambientes.removeWhere((a) => a.id == id);
}
