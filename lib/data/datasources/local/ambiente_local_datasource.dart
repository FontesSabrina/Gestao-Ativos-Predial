import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/ambiente.dart';

class AmbienteLocalDataSource {
  final Database _db;
  final String _tableName = 'ambientes';

  AmbienteLocalDataSource(this._db);

  Future<List<Ambiente>> buscarTodos() async {
    final maps = await _db.query(_tableName);
    return maps.map((map) => Ambiente.fromMap(map)).toList();
  }

  Future<void> salvar(Ambiente ambiente) async {
    await _db.insert(
      _tableName, 
      ambiente.toMap(), 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<void> excluir(String id) async {
    await _db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}