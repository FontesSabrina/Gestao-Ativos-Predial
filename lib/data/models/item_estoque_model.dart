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
      id: map['id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? 'Sem nome',
      quantidade: (map['quantidade'] as num?)?.toInt() ?? 0,
      nivelMinimo: (map['nivelMinimo'] as num?)?.toInt() ?? 5,
      unidadeMedida: map['unidadeMedida']?.toString() ?? 'Unidade',
      fornecedor: map['fornecedor']?.toString() ?? 'Sem fornecedor',
      precoUnitario: (map['precoUnitario'] as num?)?.toDouble() ?? 0.0,
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