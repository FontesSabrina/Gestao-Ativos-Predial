import 'package:sqflite/sqflite.dart';
import '../../models/ordem_servico_model.dart';

class OrdemServicoLocalDataSource {
  final Database _db;

  OrdemServicoLocalDataSource(this._db);

  Future<void> salvar(OrdemServicoModel model) async {
    try {
      await _db.insert(
        'ordens_servico',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Erro ao salvar ordem de serviço: $e");
    }
  }

  Future<List<Map<String, dynamic>>> buscarTodas() async {
    try {
      return await _db.query('ordens_servico');
    } catch (e) {
      throw Exception("Erro ao buscar todas as ordens de serviço: $e");
    }
  }

  Future<List<Map<String, dynamic>>> buscarPorStatus(int statusIndex) async {
    try {
      return await _db.query(
        'ordens_servico',
        where: 'status = ?',
        whereArgs: [statusIndex],
      );
    } catch (e) {
      throw Exception("Erro ao buscar ordens de serviço por status: $e");
    }
  }
}