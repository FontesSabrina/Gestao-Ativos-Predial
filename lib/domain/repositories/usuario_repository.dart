import '../entities/usuario.dart';

abstract class UsuarioRepository {
  // Adicione esta linha:
  Future<List<Usuario>> buscarTodos(); 
  Future<Usuario?> buscarPorEmail(String email);
  Future<Usuario?> login(String email, String senha);
  Future<Usuario?> buscarPorId(String id);
  Future<List<Usuario>> buscarPorPerfil(Perfil perfil);
  Future<void> salvar(Usuario usuario);
  Future<void> excluir(String id);
}