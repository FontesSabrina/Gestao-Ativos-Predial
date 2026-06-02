import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/ambiente.dart';

class AmbienteLocalDataSource {
  final Database _db; // Agora depende do banco injetado
  final String _tableName = 'ambientes';

  // O construtor recebe o _db
  AmbienteLocalDataSource(this._db);

  Future<List<Ambiente>> buscarTodos() async {
    // Usa _db em vez de DatabaseHelper
    final maps = await _db.query(_tableName);
    return maps.map((map) => Ambiente.fromMap(map)).toList();
  }

  Future<void> salvar(Ambiente ambiente) async {
    // Usa _db em vez de DatabaseHelper
    await _db.insert(_tableName, ambiente.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> excluir(String id) async {
    // Usa _db em vez de DatabaseHelper
    await _db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}