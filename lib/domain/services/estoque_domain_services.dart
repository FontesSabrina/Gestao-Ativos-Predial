import '../entities/item_estoque.dart';
import '../repositories/estoque_repository.dart';

class EstoqueDomainServices {
  final EstoqueRepository _repository;

  EstoqueDomainServices(this._repository);

  // Padronizado para buscarTodos()
  Future<List<ItemEstoque>> buscarTodos() async => await _repository.buscarTodos();

  // Regra de Negócio: Consumo com segurança
  Future<void> consumirItem(String idItem, int quantidade) async {
    final item = await _repository.buscarPorId(idItem);
    
    if (item == null) {
      throw Exception("Item não encontrado no estoque.");
    }
    
    final novaQuantidade = item.quantidade - quantidade;
    
    if (novaQuantidade < 0) {
      throw Exception("Estoque insuficiente para o item: ${item.nome}");
    }

    await _repository.atualizarQuantidade(idItem, novaQuantidade);
  }

  // Padronizado para refletir o critério de busca
  Future<List<ItemEstoque>> buscarItensCriticos() async {
    return await _repository.buscarItensAbaixoDoMinimo();
  }

  Future<void> salvar(ItemEstoque item) async => await _repository.salvar(item);
}