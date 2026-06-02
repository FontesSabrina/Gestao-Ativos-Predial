import '../entities/ativo.dart';

abstract class AtivoRepository {
  Future<List<Ativo>> buscarTodos();
  Future<Ativo?> buscarPorId(String id);
  Future<void> salvar(Ativo ativo);
  Future<List<Ativo>> buscarPorLocalizacao(String localizacao);
  Future<void> excluir(String id);
}