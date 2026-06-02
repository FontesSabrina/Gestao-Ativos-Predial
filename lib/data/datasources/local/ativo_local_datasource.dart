import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/ativo.dart';

class AtivoLocalDataSource {
  final Database _db; // Agora usamos uma variável local para o banco
  final String _tableName = 'ativos';

  // O construtor recebe o banco injetado pelo ServiceLocator
  AtivoLocalDataSource(this._db);

  Future<List<Ativo>> buscarTodos() async {
    try {
      final maps = await _db.query(_tableName); // Usamos o _db injetado
      return maps.map((map) => Ativo.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar todos os ativos: $e");
    }
  }

  Future<Ativo?> buscarPorId(String id) async {
    try {
      final maps = await _db.query(_tableName, where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        return Ativo.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception("Erro ao buscar ativo pelo ID $id: $e");
    }
  }

  Future<void> salvar(Ativo ativo) async {
    try {
      await _db.insert(
        _tableName, 
        ativo.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Erro ao salvar ativo: $e");
    }
  }

  Future<void> excluir(String id) async {
    try {
      await _db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception("Erro ao excluir ativo com ID $id: $e");
    }
  }
}