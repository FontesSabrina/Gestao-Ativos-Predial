import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/entities/chamado.dart';
import '../../../domain/repositories/chamado_repository.dart';

class ListaPorStatusWidget extends StatefulWidget {
  final StatusChamado statusFiltrado;

  const ListaPorStatusWidget({super.key, required this.statusFiltrado});

  @override
  State<ListaPorStatusWidget> createState() => _ListaPorStatusWidgetState();
}

class _ListaPorStatusWidgetState extends State<ListaPorStatusWidget> {
  late Future<List<Chamado>> _futureChamados;

  @override
  void initState() {
    super.initState();
    _futureChamados = GetIt.I<ChamadoRepository>().buscarTodos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Chamado>>(
      future: _futureChamados,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Erro ao carregar dados: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        }

        final listaGeral = snapshot.data ?? [];
        final chamadosFiltrados = listaGeral
            .where((chamado) => chamado.status == widget.statusFiltrado)
            .toList();

        if (chamadosFiltrados.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open_rounded, size: 60, color: Colors.white24),
                const SizedBox(height: 12),
                const Text(
                  'Nenhum chamado nesta categoria',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
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
            final nomeAtivo = chamado.ativo != null ? chamado.ativo!.nome : 'Ativo não identificado';

            return Card(
              color: const Color(0xFF1E1E1E), // Fundo do card escuro
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              nomeAtivo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCritico ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              chamado.prioridade.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isCritico ? Colors.redAccent : Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        chamado.descricaoFalha,
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Colors.white10),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16, color: Colors.white54),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              chamado.tecnicoResponsavel != null
                                  ? 'Téc: ${chamado.tecnicoResponsavel!.nome}'
                                  : 'Sem técnico designado',
                              style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const Icon(Icons.build_circle_outlined, size: 16, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(
                            chamado.tipo.name.toUpperCase(),
                            style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}