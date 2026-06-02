import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../../domain/entities/item_estoque.dart';

class EstoqueLocalDataSource {
  final String _tableName = 'estoque';

  Future<List<ItemEstoque>> buscarTodos() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query(_tableName);
      return maps.map((map) => ItemEstoque.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar todos os itens do estoque: $e");
    }
  }

  Future<ItemEstoque?> buscarPorId(String id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        return ItemEstoque.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception("Erro ao buscar item de estoque pelo ID $id: $e");
    }
  }

  Future<void> salvar(ItemEstoque item) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert(
        _tableName, 
        item.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Erro ao salvar item no estoque: $e");
    }
  }

  Future<void> atualizarQuantidade(String id, int novaQuantidade) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
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
      final db = await DatabaseHelper.instance.database;
      await db.update(
        _tableName,
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } catch (e) {
      throw Exception("Erro ao atualizar item no estoque: $e");
    }
  }

  Future<void> excluir(String id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception("Erro ao excluir item do estoque com ID $id: $e");
    }
  }
}