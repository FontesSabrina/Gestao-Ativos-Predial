import '../../domain/entities/notificacao.dart';
import '../../domain/repositories/notificacao_repository.dart';

class NotificacaoRepositoryMemory implements NotificacaoRepository {
  
  final List<Notificacao> _notificacoes = [
    Notificacao(
      id: 'debug-01',
      titulo: 'Bem-vinda ao Aura!',
      mensagem: 'Este é um aviso de teste para verificar se as notificações estão carregando.',
      dataCriacao: DateTime.now(),
      lida: false,
      usuarioId: '1',
    ),
  ];

  @override
  Future<List<Notificacao>> buscarNotificacoesDoUsuario(String usuarioId) async {
    print("DEBUG: Buscando notificações para o usuário: $usuarioId");
    print("DEBUG: Total de notificações na memória: ${_notificacoes.length}");
    
    return _notificacoes.where((n) => n.usuarioId == usuarioId).toList();
  }

  @override
  Future<void> adicionarNotificacao(Notificacao notificacao) async {
    _notificacoes.add(notificacao);
  }

  @override
  Future<void> marcarComoLida(String id) async {
    final index = _notificacoes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notificacoes[index] = _notificacoes[index].copyWith(lida: true);
    }
  }
}