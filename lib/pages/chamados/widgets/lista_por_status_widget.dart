import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/entities/chamado.dart';
import '../../../domain/entities/usuario.dart'; // Importe necessário
import '../../../domain/repositories/chamado_repository.dart';
import '../../chamados/chamado_aprovacao_page.dart'; 

class ListaPorStatusWidget extends StatefulWidget {
  final StatusChamado statusFiltrado;
  final Usuario usuario; // Adicionado

  const ListaPorStatusWidget({
    super.key, 
    required this.statusFiltrado,
    required this.usuario, // Adicionado
  });

  @override
  State<ListaPorStatusWidget> createState() => _ListaPorStatusWidgetState();
}

class _ListaPorStatusWidgetState extends State<ListaPorStatusWidget> {
  late Future<List<Chamado>> _futureChamados;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    setState(() {
      _futureChamados = GetIt.I<ChamadoRepository>().buscarTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<List<Chamado>>(
        future: _futureChamados,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error)));
          }

          final chamadosFiltrados = (snapshot.data ?? [])
              .where((c) => c.status == widget.statusFiltrado)
              .toList();

          if (chamadosFiltrados.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_rounded, size: 60, color: theme.disabledColor),
                  const SizedBox(height: 12),
                  Text('Nenhum chamado nesta categoria', style: TextStyle(color: theme.hintColor)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chamadosFiltrados.length,
            itemBuilder: (context, index) {
              final chamado = chamadosFiltrados[index];
              final isCritico = chamado.prioridade.toLowerCase() == 'alta';

              return Card(
                color: theme.cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // CORREÇÃO: Passando o usuário logado aqui também!
                        builder: (_) => ChamadoAprovacaoPage(
                          chamado: chamado, 
                          usuarioLogado: widget.usuario
                        ),
                      ),
                    ).then((_) => _carregarDados());
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      chamado.ativo?.nome ?? 'Ativo não identificado',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(chamado.descricaoFalha, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        _buildStatusBadge(isCritico, chamado.prioridade, theme),
                      ],
                    ),
                    trailing: Icon(Icons.chevron_right, color: theme.hintColor),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(bool isCritico, String prioridade, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCritico ? Colors.red.withOpacity(0.15) : Colors.blue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        prioridade.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isCritico ? Colors.redAccent : Colors.blueAccent,
        ),
      ),
    );
  }
}