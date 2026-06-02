import '../entities/ordem_servico.dart';
import '../entities/usuario.dart';
import '../repositories/ordem_servico_repository.dart';

class OrdemServicoDomainServices {
  final OrdemServicoRepository _repository;

  OrdemServicoDomainServices(this._repository);

  Future<List<OrdemServico>> buscarTodos() async => await _repository.buscarTodos();

  Future<void> finalizarOS({
    required OrdemServico ordem,
    required String relato,
    required double custoPecas,
    required double custoMaoDeObra,
    required Usuario executor,
  }) async {
    // Regra de Negócio: Verificação de perfil
    if (executor.perfil != Perfil.tecnicoResponsavel && executor.perfil != Perfil.administrador) {
    throw Exception("Usuário não tem permissão para finalizar ordens.");
    }

    // Usando copyWith para atualizar o estado de forma segura e limpa
    final osFinalizada = ordem.copyWith(
      status: StatusOS.concluida,
      relatotecnico: relato,
      custoPecas: custoPecas,
      custoMaoDeObra: custoMaoDeObra,
      dataFim: DateTime.now(),
      tecnicoResponsavelId: executor.id,
    );

    await _repository.salvar(osFinalizada);
  }
}