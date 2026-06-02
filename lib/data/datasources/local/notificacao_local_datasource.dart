import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/notificacao.dart';

class NotificacaoLocalDataSource {
  final Database _db;

  NotificacaoLocalDataSource(this._db);

  // Método para salvar (Inserir)
  Future<void> salvar(Notificacao not) async {
    await _db.insert(
      'notificacoes', 
      {
        'id': not.id,
        'titulo': not.titulo,
        'mensagem': not.mensagem,
        'dataCriacao': not.dataCriacao.toIso8601String(),
        'lida': not.lida ? 1 : 0,
        'usuarioId': not.usuarioId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Garante que, se o ID existir, ele sobrescreve
    );
  }

  // Método para buscar por usuário
  Future<List<Notificacao>> buscarPorUsuario(String usuarioId) async {
    final results = await _db.query(
      'notificacoes', 
      where: 'usuarioId = ?', 
      whereArgs: [usuarioId],
      orderBy: 'dataCriacao DESC'
    );
    
    return results.map((m) => Notificacao(
      id: m['id'] as String,
      titulo: m['titulo'] as String,
      mensagem: m['mensagem'] as String,
      dataCriacao: DateTime.parse(m['dataCriacao'] as String),
      lida: (m['lida'] as int) == 1,
      usuarioId: m['usuarioId'] as String,
    )).toList();
  }

  // Método para marcar como lida
  Future<void> marcarComoLida(String id) async {
    await _db.update(
      'notificacoes', 
      {'lida': 1}, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  // BÔNUS: Adicionei este método para você conseguir limpar notificações antigas
  Future<void> excluir(String id) async {
    await _db.delete('notificacoes', where: 'id = ?', whereArgs: [id]);
  }
}