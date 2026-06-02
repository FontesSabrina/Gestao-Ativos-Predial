import 'package:meta/meta.dart';

@immutable
class ItemEstoque {
  final String id;
  final String nome;
  final int quantidade;
  final int nivelMinimo;
  final String unidadeMedida;
  final String fornecedor;
  final double precoUnitario;

  const ItemEstoque({
    required this.id,
    required this.nome,
    required this.quantidade,
    this.nivelMinimo = 5,
    this.unidadeMedida = 'Unidade',
    this.fornecedor = 'Sem fornecedor',
    this.precoUnitario = 0.0,
  });

  // Método de lógica de negócio
  bool get alertaEstoqueBaixo => quantidade <= nivelMinimo;

  // Método copyWith para imutabilidade
  ItemEstoque copyWith({
    String? id,
    String? nome,
    int? quantidade,
    int? nivelMinimo,
    String? unidadeMedida,
    String? fornecedor,
    double? precoUnitario,
  }) {
    return ItemEstoque(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      nivelMinimo: nivelMinimo ?? this.nivelMinimo,
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
      fornecedor: fornecedor ?? this.fornecedor,
      precoUnitario: precoUnitario ?? this.precoUnitario,
    );
  }

  // Conversão para SQLite
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

  // Criação a partir do banco de dados
  factory ItemEstoque.fromMap(Map<String, dynamic> map) {
    return ItemEstoque(
      id: map['id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? 'Sem nome',
      quantidade: (map['quantidade'] as num?)?.toInt() ?? 0,
      nivelMinimo: (map['nivelMinimo'] as num?)?.toInt() ?? 5,
      unidadeMedida: map['unidadeMedida']?.toString() ?? 'Unidade',
      fornecedor: map['fornecedor']?.toString() ?? 'Sem fornecedor',
      precoUnitario: (map['precoUnitario'] as num?)?.toDouble() ?? 0.0,
    );
  }
}