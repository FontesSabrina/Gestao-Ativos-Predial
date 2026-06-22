import '../../domain/entities/notificacao.dart';

class NotificacaoModel extends Notificacao {
  NotificacaoModel({
    required super.id,
    required super.titulo,
    required super.mensagem,
    required super.dataCriacao,
    super.lida,
    required super.usuarioId,
  });

  factory NotificacaoModel.fromMap(Map<String, dynamic> map) {
    return NotificacaoModel(
      id: map['id']?.toString() ?? '',
      titulo: map['titulo']?.toString() ?? '',
      mensagem: map['mensagem']?.toString() ?? '',
      dataCriacao: DateTime.parse(map['dataCriacao'] as String),
      lida: (map['lida'] ?? 0) == 1,
      usuarioId: map['usuarioId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'mensagem': mensagem,
      'dataCriacao': dataCriacao.toIso8601String(), 
      'lida': lida ? 1 : 0, 
      'usuarioId': usuarioId,
    };
  }
}