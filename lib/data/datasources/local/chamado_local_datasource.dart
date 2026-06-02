import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../../domain/entities/chamado.dart';

class ChamadoLocalDataSource {
  final Database _db; // Agora injetamos o banco aqui
  final String _tableName = 'chamados';

  ChamadoLocalDataSource(this._db); // Construtor

  Future<List<Chamado>> buscarTodos() async {
    try {
      final maps = await _db.query(_tableName); // Usa _db, não o singleton
      return maps.map((map) => Chamado.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar todos os chamados: $e");
    }
  }

  Future<Chamado?> buscarPorId(String id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query(
        _tableName, 
        where: 'id = ?', 
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Chamado.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception("Erro ao buscar chamado pelo ID $id: $e");
    }
  }

  Future<void> salvar(Chamado chamado) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert(
        _tableName, 
        chamado.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Erro ao salvar chamado: $e");
    }
  }

  Future<void> excluir(String id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        _tableName, 
        where: 'id = ?', 
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Erro ao excluir chamado com ID $id: $e");
    }
  }
}