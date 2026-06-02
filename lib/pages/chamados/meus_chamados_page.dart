import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/entities/chamado.dart';
import '../../../domain/entities/usuario.dart';
import '../../../domain/repositories/chamado_repository.dart';

class MeusChamadosPage extends StatelessWidget {
  final Usuario usuarioLogado;

  const MeusChamadosPage({super.key, required this.usuarioLogado});

  static const Color azulFixo = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    final repository = GetIt.I<ChamadoRepository>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Meus Chamados", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: azulFixo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: FutureBuilder<List<Chamado>>(
            future: repository.buscarTodos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: azulFixo));
              }
              
              if (snapshot.hasError) {
                return const Center(child: Text("Erro ao carregar chamados."));
              }

              final chamados = snapshot.data ?? [];
              final meusChamados = chamados.where((c) => c.solicitante.id == usuarioLogado.id).toList();

              if (meusChamados.isEmpty) {
                return const Center(child: Text("Você ainda não abriu nenhum chamado."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: meusChamados.length,
                itemBuilder: (context, index) {
                  final c = meusChamados[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: azulFixo.withOpacity(0.1),
                        child: const Icon(Icons.assignment, color: azulFixo),
                      ),
                      title: Text(c.ativo.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(c.descricaoFalha, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          _buildStatusBadge(c.status),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(StatusChamado status) {
    // Definimos cores fixas para os estados para manter a organização
    Color color = status == StatusChamado.aberto ? Colors.blue : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}