import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/usuario.dart';

class UsuarioLocalDataSource {
  final Database _db; // Banco injetado
  final String _tableName = 'usuarios';

  // Construtor recebendo o banco
  UsuarioLocalDataSource(this._db);

  Future<List<Usuario>> buscarTodos() async {
    try {
      final maps = await _db.query(_tableName); // Usa o _db
      return maps.map((map) => Usuario.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar todos os usuários: $e");
    }
  }

  Future<Usuario?> buscarPorId(String id) async {
    try {
      final maps = await _db.query(_tableName, where: 'id = ?', whereArgs: [id]);
      return maps.isNotEmpty ? Usuario.fromMap(maps.first) : null;
    } catch (e) {
      throw Exception("Erro ao buscar usuário pelo ID $id: $e");
    }
  }

  Future<Usuario?> buscarPorEmail(String email) async {
    try {
      final maps = await _db.query(_tableName, where: 'email = ?', whereArgs: [email]);
      return maps.isNotEmpty ? Usuario.fromMap(maps.first) : null;
    } catch (e) {
      throw Exception("Erro ao buscar usuário pelo email $email: $e");
    }
  }

  Future<void> salvar(Usuario usuario) async {
    try {
      await _db.insert(
        _tableName, 
        usuario.toMap(), 
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