import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/notificacao.dart';
import '../../domain/repositories/notificacao_repository.dart';

class NotificacaoService {
  static Future<void> disparar(String usuarioId, String titulo, String msg) async {
  print("--- DISPARO DE NOTIFICAÇÃO ---");
  print("Destinatário ID: $usuarioId");
  print("Título: $titulo");
  
  final repo = GetIt.I<NotificacaoRepository>();
  final novaNotificacao = Notificacao(
    id: const Uuid().v4(),
    titulo: titulo,
    mensagem: msg,
    dataCriacao: DateTime.now(),
    usuarioId: usuarioId,
    lida: false,
  );
  
  await repo.adicionarNotificacao(novaNotificacao);
  print("Notificação salva no repositório!");
}
}