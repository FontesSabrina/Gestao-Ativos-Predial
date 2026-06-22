import 'package:sqflite/sqflite.dart';
import '../../models/chamado_model.dart';
import '../../../domain/entities/chamado.dart';

class ChamadoLocalDataSource {
  final Database _db; 
  final String _tableName = 'chamados';

  ChamadoLocalDataSource(this._db); 

  Future<List<Chamado>> buscarTodos() async {
    try {
      final maps = await _db.query(_tableName); 
      return maps.map((map) => ChamadoModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar todos os chamados: $e");
    }
  }

  Future<Chamado?> buscarPorId(String id) async {
    try {
      final maps = await _db.query(
        _tableName, 
        where: 'id = ?', 
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return ChamadoModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception("Erro ao buscar chamado pelo ID $id: $e");
    }
  }

  Future<void> salvar(Chamado chamado) async {
    try {
      final modelo = ChamadoModel(
        id: chamado.id,
        ativo: chamado.ativo,
        solicitante: chamado.solicitante,
        descricaoFalha: chamado.descricaoFalha,
        prioridade: chamado.prioridade,
        tipo: chamado.tipo,
        status: chamado.status,
        dataAbertura: chamado.dataAbertura,
        tecnicoResponsavel: chamado.tecnicoResponsavel,
      );

      await _db.insert(
        _tableName, 
        modelo.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Erro ao salvar chamado: $e");
    }
  }

  Future<void> excluir(String id) async {
    try {
      await _db.delete(
        _tableName, 
        where: 'id = ?', 
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Erro ao excluir chamado com ID $id: $e");
    }
  }
}