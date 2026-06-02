import '../entities/chamado.dart';

abstract class ChamadoRepository {
  Future<List<Chamado>> buscarTodos();
  Future<Chamado?> buscarPorId(String id);
  Future<void> salvar(Chamado chamado);
  Future<List<Chamado>> buscarPorUsuario(String idUsuario);
  Future<void> atualizarStatus(String idChamado, StatusChamado novoStatus);
  Future<void> excluir(String id);
}