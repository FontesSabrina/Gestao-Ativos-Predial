import '../entities/ordem_servico.dart';

abstract class OrdemServicoRepository {
  Future<List<OrdemServico>> buscarTodos();
  Future<OrdemServico?> buscarPorId(String id);
  Future<void> salvar(OrdemServico os);
  Future<void> excluir(String id);
  Future<List<OrdemServico>> buscarPorStatus(StatusOS status);
  Future<List<OrdemServico>> buscarPorTecnico(String idTecnico);
  Future<List<OrdemServico>> buscarPorAtivo(String idAtivo);
  Future<List<OrdemServico>> buscarPorData(DateTime data);
}