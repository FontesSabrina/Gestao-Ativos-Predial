import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../datasources/local/usuario_local_datasource.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final UsuarioLocalDataSource localDataSource;

  UsuarioRepositoryImpl(this.localDataSource);

  @override
  Future<List<Usuario>> buscarTodos() async {
    return await localDataSource.buscarTodos();
  }

  @override
  Future<Usuario?> buscarPorId(String id) async {
    return await localDataSource.buscarPorId(id);
  }

  @override
  Future<Usuario?> buscarPorEmail(String email) async {
    return await localDataSource.buscarPorEmail(email);
  }

  @override
  Future<void> salvar(Usuario usuario) async {
    await localDataSource.salvar(usuario);
  }

  @override
  Future<void> excluir(String id) async {
    await localDataSource.excluir(id);
  }

  @override
  Future<List<Usuario>> buscarPorPerfil(Perfil perfil) async {
    final todos = await localDataSource.buscarTodos();
    return todos.where((u) => u.perfil == perfil).toList();
  }

  @override
  Future<Usuario?> login(String email, String senha) async {
    final usuario = await localDataSource.buscarPorEmail(email);
    if (usuario != null && usuario.senha == senha) {
      return usuario;
    }
    return null;
  }
}