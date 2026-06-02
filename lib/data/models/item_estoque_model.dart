import '../../domain/entities/item_estoque.dart';

class ItemEstoqueModel extends ItemEstoque {
  ItemEstoqueModel({
    required super.id,
    required super.nome,
    required super.quantidade,
    super.nivelMinimo,
    super.unidadeMedida,
    super.fornecedor,
    super.precoUnitario,
  });

  factory ItemEstoqueModel.fromMap(Map<String, dynamic> map) {
    return ItemEstoqueModel(
      id: map['id'],
      nome: map['nome'],
      quantidade: map['quantidade'],
      nivelMinimo: map['nivelMinimo'],
      unidadeMedida: map['unidadeMedida'],
      fornecedor: map['fornecedor'],
      precoUnitario: (map['precoUnitario'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'quantidade': quantidade,
      'nivelMinimo': nivelMinimo,
      'unidadeMedida': unidadeMedida,
      'fornecedor': fornecedor,
      'precoUnitario': precoUnitario,
    };
  }
}