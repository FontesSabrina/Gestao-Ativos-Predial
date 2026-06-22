import 'package:sqflite/sqflite.dart';
import '../../models/ativo_model.dart';
import '../../../domain/entities/ativo.dart';

class AtivoLocalDataSource {
  final Database _db; 
  final String _tableName = 'ativos';

  AtivoLocalDataSource(this._db);

  Future<List<Ativo>> buscarTodos() async {
    try {
      final maps = await _db.query(_tableName); 
      return maps.map((map) => AtivoModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar todos os ativos: $e");
    }
  }

  Future<Ativo?> buscarPorId(String id) async {
    try {
      final maps = await _db.query(_tableName, where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        return AtivoModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception("Erro ao buscar ativo pelo ID $id: $e");
    }
  }

  Future<void> salvar(Ativo ativo) async {
    try {
      final modelo = AtivoModel(
        id: ativo.id,
        nome: ativo.nome,
        patrimonio: ativo.patrimonio,
        localizacao: ativo.localizacao,
        estadoConservacao: ativo.estadoConservacao,
        dataAquisicao: ativo.dataAquisicao,
      );

      await _db.insert(
        _tableName, 
        modelo.toMap(), 
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