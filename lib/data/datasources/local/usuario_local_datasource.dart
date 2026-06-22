import 'package:sqflite/sqflite.dart';
import '../../models/usuario_model.dart';
import '../../../domain/entities/usuario.dart';

class UsuarioLocalDataSource {
  final Database _db; 
  final String _tableName = 'usuarios';

  UsuarioLocalDataSource(this._db);

  Future<List<Usuario>> buscarTodos() async {
    try {
      final maps = await _db.query(_tableName); 
      return maps.map((map) => UsuarioModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar todos os usuários: $e");
    }
  }

  Future<Usuario?> buscarPorId(String id) async {
    try {
      final maps = await _db.query(_tableName, where: 'id = ?', whereArgs: [id]);
      return maps.isNotEmpty ? UsuarioModel.fromMap(maps.first) : null;
    } catch (e) {
      throw Exception("Erro ao buscar usuário pelo ID $id: $e");
    }
  }

  Future<Usuario?> buscarPorEmail(String email) async {
    try {
      final maps = await _db.query(_tableName, where: 'email = ?', whereArgs: [email]);
      return maps.isNotEmpty ? UsuarioModel.fromMap(maps.first) : null;
    } catch (e) {
      throw Exception("Erro ao buscar usuário pelo email $email: $e");
    }
  }

  Future<void> salvar(Usuario usuario) async {
    try {
      final modelo = UsuarioModel(
        id: usuario.id,
        nome: usuario.nome,
        email: usuario.email,
        senha: usuario.senha,
        perfil: usuario.perfil,
      );

      await _db.insert(
        _tableName, 
        modelo.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Erro ao salvar usuário: $e");
    }
  }

  Future<void> excluir(String id) async {
    try {
      await _db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception("Erro ao excluir usuário com ID $id: $e");
    }
  }
}