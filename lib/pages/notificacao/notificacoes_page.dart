import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/entities/notificacao.dart';
import '../../../domain/entities/usuario.dart';
import '../../../domain/repositories/notificacao_repository.dart';

class NotificacoesPage extends StatefulWidget {
  final Usuario usuario;
  const NotificacoesPage({super.key, required this.usuario});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  static const Color primaryColor = Color(0xFF1A237E);
  
  final _repository = GetIt.I<NotificacaoRepository>();
  late Future<List<Notificacao>> _futureNotificacoes;

  @override
  void initState() {
    super.initState();
    _carregarNotificacoes();
  }

  void _carregarNotificacoes() {
    setState(() {
      _futureNotificacoes = _repository.buscarNotificacoesDoUsuario(widget.usuario.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Central de Avisos", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Notificacao>>(
        future: _futureNotificacoes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final lista = snapshot.data ?? [];
          
          // Envolvemos o conteúdo em Center + ConstrainedBox para centralizar
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: lista.isEmpty 
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 60, color: theme.hintColor),
                      const SizedBox(height: 12),
                      Text("Nenhuma notificação no momento.", style: TextStyle(color: theme.hintColor)),
                    ],
                  )
                : RefreshIndicator(
                    onRefresh: () async => _carregarNotificacoes(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: lista.length,
                      itemBuilder: (context, index) {
                        final item = lista[index];
                        final isDark = theme.brightness == Brightness.dark;
                        final cardColor = item.lida 
                            ? theme.cardColor 
                            : (isDark ? const Color(0xFF2C2C2C) : Colors.blue.withOpacity(0.1));

                        return Card(
                          elevation: 0,
                          color: cardColor,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Icon(
                              item.lida ? Icons.notifications_none : Icons.notifications_active,
                              color: item.lida ? theme.hintColor : Colors.amber,
                            ),
                            title: Text(
                              item.titulo, 
                              style: TextStyle(
                                fontWeight: item.lida ? FontWeight.normal : FontWeight.bold,
                                fontSize: 15,
                              )
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(item.mensagem),
                            ),
                            onTap: () async {
                              if (!item.lida) {
                                await _repository.marcarComoLida(item.id);
                                _carregarNotificacoes();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }
}