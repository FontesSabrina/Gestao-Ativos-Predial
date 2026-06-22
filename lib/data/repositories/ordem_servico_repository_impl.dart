import '../../domain/entities/ordem_servico.dart';
import '../../domain/repositories/ordem_servico_repository.dart';
import '../datasources/local/ordem_servico_local_datasource.dart';
import '../models/ordem_servico_model.dart';

class OrdemServicoRepositoryImpl implements OrdemServicoRepository {
  final OrdemServicoLocalDataSource _localDataSource;

  OrdemServicoRepositoryImpl(this._localDataSource);

  @override
  Future<void> salvar(OrdemServico os) async {
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

    await _localDataSource.salvar(model);
  }

  @override
  Future<List<OrdemServico>> buscarTodos() async {
    final List<Map<String, dynamic>> maps = await _localDataSource.buscarTodas();
    return maps.map((map) => OrdemServicoModel.fromMap(map)).toList();
  }

  @override
  Future<OrdemServico?> buscarPorId(String id) async {
    final maps = await _localDataSource.buscarTodas();
    final item = maps.firstWhere((map) => map['id'] == id, orElse: () => {});
    if (item.isEmpty) return null;
    return OrdemServicoModel.fromMap(item);
  }

  @override
  Future<void> excluir(String id) async {
  }

  @override
  Future<List<OrdemServico>> buscarPorStatus(StatusOS status) async {
    final maps = await _localDataSource.buscarPorStatus(status.index);
    return maps.map((map) => OrdemServicoModel.fromMap(map)).toList();
  }

  @override
  Future<List<OrdemServico>> buscarPorTecnico(String idTecnico) async {
    final maps = await _localDataSource.buscarTodas();
    return maps
        .where((map) => map['tecnicoResponsavelId'] == idTecnico)
        .map((map) => OrdemServicoModel.fromMap(map))
        .toList();
  }

  @override
  Future<List<OrdemServico>> buscarPorAtivo(String idAtivo) async {
    final maps = await _localDataSource.buscarTodas();
    return maps
        .where((map) => map['ativoId'] == idAtivo)
        .map((map) => OrdemServicoModel.fromMap(map))
        .toList();
  }

  @override
  Future<List<OrdemServico>> buscarPorData(DateTime data) async {
    final maps = await _localDataSource.buscarTodas();
    final dataStr = data.toIso8601String().substring(0, 10);
    return maps
        .where((map) => map['dataAbertura'].toString().startsWith(dataStr))
        .map((map) => OrdemServicoModel.fromMap(map))
        .toList();
  }
}