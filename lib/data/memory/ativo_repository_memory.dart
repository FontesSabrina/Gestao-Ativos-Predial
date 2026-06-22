import '../../domain/entities/ativo.dart';
import '../../domain/repositories/ativo_repository.dart';
import 'repository_memory_base.dart';

class AtivoRepositoryMemory extends RepositoryMemoryBase<Ativo> implements AtivoRepository {
  @override
  List<Ativo> get fakeData => [
    Ativo(id: '1', nome: 'Ar Condicionado', patrimonio: 'PAT-001', localizacao: 'Bloco A', estadoConservacao: 'Bom', dataAquisicao: DateTime.now()),
    Ativo(id: '2', nome: 'Servidor Rack', patrimonio: 'PAT-002', localizacao: 'TI', estadoConservacao: 'Excelente', dataAquisicao: DateTime.now()),
  ];

  @override
  Future<List<Ativo>> buscarTodos() async {
    await connect();
    return dataMemory;
  }

  @override
  Future<Ativo?> buscarPorId(String id) async {
    await connect();
    return dataMemory.cast<Ativo?>().firstWhere((a) => a?.id == id, orElse: () => null);
  }

  @override
  Future<void> salvar(Ativo ativo) async {
    await connect();
    final index = dataMemory.indexWhere((item) => item.id == ativo.id);
    if (index != -1) {
      dataMemory[index] = ativo;
    } else {
      dataMemory.add(ativo);
    }
  }

  @override
  Future<void> excluir(String id) async {
    await connect();
    dataMemory.removeWhere((a) => a.id == id);
  }

  @override
Future<List<Ativo>> buscarPorLocalizacao(String localizacao) async {
  await connect();
  return dataMemory.where((ativo) => ativo.localizacao == localizacao).toList();
}
}