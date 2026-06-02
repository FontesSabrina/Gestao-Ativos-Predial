import '../../domain/entities/chamado.dart';
import '../../domain/entities/ativo.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/chamado_repository.dart';
import 'repository_memory_base.dart';

class ChamadoRepositoryMemory extends RepositoryMemoryBase<Chamado> implements ChamadoRepository {
  
  @override
  List<Chamado> get fakeData => [
    Chamado(
      id: '1',
      descricaoFalha: 'Ar condicionado não gela',
      prioridade: 'Alta', 
      tipo: TipoManutencao.corretiva,
      status: StatusChamado.aberto,
      dataAbertura: DateTime.now(),
      ativo: Ativo(
        id: 'A1', 
        nome: 'Ar Split',
        patrimonio: 'PAT-001', 
        localizacao: 'Sala 01', 
        estadoConservacao: 'Bom', 
        dataAquisicao: DateTime.now(), 
      ),
      solicitante: Usuario(
        id: 'U1', 
        nome: 'Sabrina',
        email: 'sabrina@email.com', 
        perfil: Perfil.solicitante, 
        senha: '123', 
      ),
    ),
  ];

  @override
  Future<List<Chamado>> buscarTodos() async {
    await connect(); 
    return dataMemory; 
  }

  @override
  Future<Chamado?> buscarPorId(String id) async {
    await connect();
    // Uso do cast e orElse para evitar erro caso não encontre
    return dataMemory.cast<Chamado?>().firstWhere(
      (c) => c?.id == id, 
      orElse: () => null
    );
  }

  @override
  Future<void> salvar(Chamado chamado) async {
    await connect();
    final index = dataMemory.indexWhere((c) => c.id == chamado.id);
    if (index != -1) {
      dataMemory[index] = chamado;
    } else {
      dataMemory.add(chamado);
    }
  }

  @override
  Future<List<Chamado>> buscarPorUsuario(String idUsuario) async {
    await connect();
    return dataMemory.where((c) => c.solicitante.id == idUsuario).toList();
  }

  @override
  Future<void> atualizarStatus(String idChamado, StatusChamado novoStatus) async {
    await connect();
    final index = dataMemory.indexWhere((c) => c.id == idChamado);
    if (index != -1) {
      // Usando o copyWith (se você tiver implementado na sua entidade) 
      // torna o código muito mais limpo que instanciar um novo objeto manualmente
      dataMemory[index] = dataMemory[index].copyWith(status: novoStatus);
    }
  }

  @override
  Future<void> excluir(String id) async {
    await connect();
    dataMemory.removeWhere((c) => c.id == id);
  }
}