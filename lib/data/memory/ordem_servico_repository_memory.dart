import '../../domain/entities/ordem_servico.dart';
import '../../domain/repositories/ordem_servico_repository.dart';
import 'repository_memory_base.dart';

// Dados fakes organizados conforme o padrão de persistência em memória
var fakeDataOS = [
  OrdemServico(
    id: '1',
    ativoId: '1', 
    solicitanteId: '1',
    tecnicoResponsavelId: '2',
    descricaoProblema: 'Limpeza de filtros e verificação de gás',
    status: StatusOS.aberta,
    dataAbertura: DateTime.now(),
    prioridade: 'Média', 
  ),
  OrdemServico(
    id: '2',
    ativoId: '2', 
    solicitanteId: '1',
    tecnicoResponsavelId: '2',
    descricaoProblema: 'Troca de fiação do painel interno',
    status: StatusOS.emAndamento,
    dataAbertura: DateTime.now().subtract(const Duration(days: 1)),
    prioridade: 'Alta',
  ),
];

class OrdemServicoRepositoryMemory extends RepositoryMemoryBase<OrdemServico> implements OrdemServicoRepository {
  
  @override
  List<OrdemServico> get fakeData => fakeDataOS;

  @override
  Future<List<OrdemServico>> buscarTodos() async {
    await connect();
    return dataMemory;
  }

  @override
  Future<OrdemServico?> buscarPorId(String id) async {
    await connect();
    return dataMemory.cast<OrdemServico?>().firstWhere(
      (os) => os?.id == id,
      orElse: () => null,
    );
  }

  @override
  Future<void> salvar(OrdemServico os) async {
    await connect();
    final index = dataMemory.indexWhere((item) => item.id == os.id);
    if (index != -1) {
      dataMemory[index] = os;
    } else {
      dataMemory.add(os);
    }
  }

  @override
  Future<void> excluir(String id) async {
    await connect();
    dataMemory.removeWhere((os) => os.id == id);
  }

  @override
  Future<List<OrdemServico>> buscarPorStatus(StatusOS status) async {
    await connect();
    return dataMemory.where((os) => os.status == status).toList();
  }

  @override
  Future<List<OrdemServico>> buscarPorAtivo(String idAtivo) async {
    await connect();
    return dataMemory.where((os) => os.ativoId == idAtivo).toList();
  }

  @override
  Future<List<OrdemServico>> buscarPorTecnico(String idTecnico) async {
    await connect();
    return dataMemory.where((os) => os.tecnicoResponsavelId == idTecnico).toList();
  }


  @override
  Future<List<OrdemServico>> buscarPorData(DateTime data) async {
    await connect();
    return dataMemory.where((os) {
      return os.dataAbertura.year == data.year &&
            os.dataAbertura.month == data.month &&
            os.dataAbertura.day == data.day;
    }).toList();
  }
}