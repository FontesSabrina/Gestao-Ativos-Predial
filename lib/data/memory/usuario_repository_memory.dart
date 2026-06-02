import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';
import 'repository_memory_base.dart';

class UsuarioRepositoryMemory extends RepositoryMemoryBase<Usuario> implements UsuarioRepository {
  
  @override
  List<Usuario> get fakeData => [
    Usuario(id: '1', nome: 'Sabrina', email: 'sabrina@aura.com', senha: 'admin123', perfil: Perfil.administrador),
    Usuario(id: '2', nome: 'João', email: 'joao@aura.com', senha: 'tech123', perfil: Perfil.tecnicoResponsavel),
    Usuario(id: '3', nome: 'Maria', email: 'maria@aura.com', senha: 'user123', perfil: Perfil.solicitante),
    Usuario(id: '4', nome: 'Alexandre', email: 'alexandre@aura.com', senha: 'audit123', perfil: Perfil.auditor),
  ];

  @override
  Future<List<Usuario>> buscarTodos() async {
    await connect();
    return dataMemory;
  }

  @override
  Future<Usuario?> buscarPorId(String id) async {
    await connect();
    return dataMemory.cast<Usuario?>().firstWhere(
      (u) => u?.id == id, 
      orElse: () => null
    );
  }

  @override
  Future<Usuario?> buscarPorEmail(String email) async {
    await connect();
    return dataMemory.cast<Usuario?>().firstWhere(
      (u) => u?.email == email, 
      orElse: () => null
    );
  }

  @override
  Future<List<Usuario>> buscarPorPerfil(Perfil perfil) async {
    await connect();
    return dataMemory.where((u) => u.perfil == perfil).toList();
  }

  @override
  Future<Usuario?> login(String email, String senha) async {
    await connect();
    return dataMemory.cast<Usuario?>().firstWhere(
      (u) => u?.email == email && u?.senha == senha, 
      orElse: () => null
    );
  }

  @override
  Future<void> salvar(Usuario usuario) async {
    await connect();
    final index = dataMemory.indexWhere((u) => u.id == usuario.id);
    if (index != -1) {
      dataMemory[index] = usuario;
    } else {
      dataMemory.add(usuario);
    }
  }

  @override
  Future<void> excluir(String id) async {
    await connect();
    dataMemory.removeWhere((u) => u.id == id);
  }
}