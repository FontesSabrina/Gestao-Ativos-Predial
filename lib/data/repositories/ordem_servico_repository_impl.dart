import 'package:sqflite/sqflite.dart';
import '../../domain/entities/ordem_servico.dart';
import '../../domain/repositories/ordem_servico_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/ordem_servico_model.dart';

class OrdemServicoRepositoryImpl implements OrdemServicoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> salvar(OrdemServico os) async {
    final db = await _dbHelper.database;
    final model = OrdemServicoModel(
      id: os.id,
      ativoId: os.ativoId,
      solicitanteId: os.solicitanteId,
      descricaoProblema: os.descricaoProblema,
      dataAbertura: os.dataAbertura,
      prioridade: os.prioridade,
      tecnicoResponsavelId: os.tecnicoResponsavelId,
      status: os.status,
      relatotecnico: os.relatotecnico,
      dataInicio: os.dataInicio,
      dataFim: os.dataFim,
      custoPecas: os.custoPecas,
      custoMaoDeObra: os.custoMaoDeObra,
      pecasUtilizadas: os.pecasUtilizadas,
      dataAprovacao: os.dataAprovacao,
      aprovadorId: os.aprovadorId,
    );

    // O 'conflictAlgorithm' garante que se o ID já existir, ele será atualizado
    await db.insert(
      'ordens_servico',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<OrdemServico>> buscarTodos() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('ordens_servico');
    return maps.map((map) => OrdemServicoModel.fromMap(map)).toList();
  }

  @override
  Future<OrdemServico?> buscarPorId(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('ordens_servico', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return OrdemServicoModel.fromMap(maps.first);
  }

  @override
  Future<void> excluir(String id) async {
    final db = await _dbHelper.database;
    await db.delete('ordens_servico', where: 'id = ?', whereArgs: [id]);
  }

  // Métodos que podem ser implementados conforme a necessidade futura:
  @override
  Future<List<OrdemServico>> buscarPorStatus(StatusOS status) async {
    final db = await _dbHelper.database;
    final maps = await db.query('ordens_servico', where: 'status = ?', whereArgs: [status.index]);
    return maps.map((map) => OrdemServicoModel.fromMap(map)).toList();
  }

  @override
  Future<List<OrdemServico>> buscarPorTecnico(String idTecnico) async {
    final db = await _dbHelper.database;
    final maps = await db.query('ordens_servico', where: 'tecnicoResponsavelId = ?', whereArgs: [idTecnico]);
    return maps.map((map) => OrdemServicoModel.fromMap(map)).toList();
  }

  @override
  Future<List<OrdemServico>> buscarPorAtivo(String idAtivo) async {
    final db = await _dbHelper.database;
    final maps = await db.query('ordens_servico', where: 'ativoId = ?', whereArgs: [idAtivo]);
    return maps.map((map) => OrdemServicoModel.fromMap(map)).toList();
  }

  @override
  Future<List<OrdemServico>> buscarPorData(DateTime data) async {
    // Busca ordens abertas na data específica
    final db = await _dbHelper.database;
    final dataStr = data.toIso8601String().substring(0, 10);
    final maps = await db.query('ordens_servico', where: "dataAbertura LIKE ?", whereArgs: ['$dataStr%']);
    return maps.map((map) => OrdemServicoModel.fromMap(map)).toList();
  }
}