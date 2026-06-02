import 'package:sqflite/sqflite.dart';
import '../../models/ordem_servico_model.dart';

class OrdemServicoLocalDataSource {
  final Database database;

  OrdemServicoLocalDataSource(this.database);

  Future<void> salvar(OrdemServicoModel model) async {
    await database.insert(
      'ordens_servico',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> buscarTodas() async {
    return await database.query('ordens_servico');
  }

  Future<List<Map<String, dynamic>>> buscarPorStatus(int statusIndex) async {
    return await database.query(
      'ordens_servico',
      where: 'status = ?',
      whereArgs: [statusIndex],
    );
  }
}