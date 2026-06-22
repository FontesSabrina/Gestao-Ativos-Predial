import 'package:sqflite/sqflite.dart';
import '../../models/item_estoque_model.dart';
import '../../../domain/entities/item_estoque.dart';

class EstoqueLocalDataSource {
  final Database _db;
  final String _tableName = 'estoque';

  EstoqueLocalDataSource(this._db);

  Future<List<ItemEstoque>> buscarTodos() async {
    try {
      final maps = await _db.query(_tableName);
      return maps.map((map) => ItemEstoqueModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar todos os itens do estoque: $e");
    }
  }

  Future<ItemEstoque?> buscarPorId(String id) async {
    try {
      final maps = await _db.query(_tableName, where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        return ItemEstoqueModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception("Erro ao buscar item de estoque pelo ID $id: $e");
    }
  }

  Future<void> salvar(ItemEstoque item) async {
    try {
      final modelo = ItemEstoqueModel(
        id: item.id,
        nome: item.nome,
        quantidade: item.quantidade,
        nivelMinimo: item.nivelMinimo,
        unidadeMedida: item.unidadeMedida,
        fornecedor: item.fornecedor,
        precoUnitario: item.precoUnitario,
      );

      await _db.insert(
        _tableName, 
        modelo.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Erro ao salvar item no estoque: $e");
    }
  }

  Future<void> atualizarQuantidade(String id, int novaQuantidade) async {
    try {
      await _db.update(
        _tableName,
        {'quantidade': novaQuantidade},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Erro ao atualizar quantidade do item $id: $e");
    }
  }

  Future<void> atualizarItem(ItemEstoque item) async {
    try {
      final modelo = ItemEstoqueModel(
        id: item.id,
        nome: item.nome,
        quantidade: item.quantidade,
        nivelMinimo: item.nivelMinimo,
        unidadeMedida: item.unidadeMedida,
        fornecedor: item.fornecedor,
        precoUnitario: item.precoUnitario,
      );

      await _db.update(
        _tableName,
        modelo.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } catch (e) {
      throw Exception("Erro ao atualizar item no estoque: $e");
    }
  }

  Future<void> excluir(String id) async {
    try {
      await _db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception("Erro ao excluir item do estoque com ID $id: $e");
    }
  }
}