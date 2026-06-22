import 'package:sqflite/sqflite.dart';
import '../../models/ambiente_model.dart';
import '../../../domain/entities/ambiente.dart';

class AmbienteLocalDataSource {
  final Database _db;
  final String _tableName = 'ambientes';

  AmbienteLocalDataSource(this._db);

  Future<List<Ambiente>> buscarTodos() async {
    try {
      final maps = await _db.query(_tableName);
      return maps.map((map) => AmbienteModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar todos os ambientes: $e");
    }
  }

  Future<void> salvar(Ambiente ambiente) async {
    try {
      final modelo = AmbienteModel(
        id: ambiente.id,
        nome: ambiente.nome,
        predio: ambiente.predio,
        andar: ambiente.andar,
        observacoes: ambiente.observacoes,
      );

      await _db.insert(
        _tableName, 
        modelo.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Erro ao salvar ambiente: $e");
    }
  }

  Future<void> excluir(String id) async {
    try {
      await _db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception("Erro ao excluir ambiente com ID $id: $e");
    }
  }
}