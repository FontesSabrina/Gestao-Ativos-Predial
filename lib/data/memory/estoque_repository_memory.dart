import '../../domain/entities/item_estoque.dart';
import '../../domain/repositories/estoque_repository.dart';
import 'repository_memory_base.dart';

class EstoqueRepositoryMemory extends RepositoryMemoryBase<ItemEstoque> implements EstoqueRepository {
  @override
  List<ItemEstoque> get fakeData => [
    ItemEstoque(
      id: '1',
      nome: 'Filtro de Ar',
      quantidade: 10,
      nivelMinimo: 5,
      unidadeMedida: 'Unidade',
      fornecedor: 'Fornecedor A',
      precoUnitario: 25.50,
    ),
  ];

  @override
  Future<List<ItemEstoque>> buscarTodos() async {
    await connect();
    return dataMemory;
  }

  @override
  Future<ItemEstoque?> buscarPorId(String id) async {
    await connect();
    // Usando orElse para evitar exceções
    return dataMemory.cast<ItemEstoque?>().firstWhere(
      (item) => item?.id == id, 
      orElse: () => null
    );
  }

  @override
  Future<void> atualizarQuantidade(String id, int novaQuantidade) async {
    await connect();
    final index = dataMemory.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = dataMemory[index];
      // Mantendo o padrão de atualização via copyWith (certifique-se que existe na sua entidade)
      dataMemory[index] = item.copyWith(quantidade: novaQuantidade);
    }
  }

  @override
  Future<void> salvar(ItemEstoque item) async {
    await connect();
    final index = dataMemory.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      dataMemory[index] = item;
    } else {
      dataMemory.add(item);
    }
  }

  @override
  Future<List<ItemEstoque>> buscarItensAbaixoDoMinimo() async {
    await connect();
    // Aqui usamos o nivelMinimo da entidade, em vez de hardcode '5'
    return dataMemory.where((item) => item.quantidade < item.nivelMinimo).toList();
  }

  @override
Future<void> excluir(String id) async {
  await connect();
  dataMemory.removeWhere((item) => item.id == id);
}
}