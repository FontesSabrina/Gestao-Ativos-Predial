import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../domain/entities/ordem_servico.dart';
import '../../../../domain/entities/usuario.dart';
import '../../../../domain/entities/ativo.dart';
import '../../../../domain/services/ordem_servico_domain_services.dart';
import '../../../../domain/repositories/ativo_repository.dart';
import 'ordem_servico_execucao_page.dart';

class OrdensServicoPage extends StatefulWidget {
  final Usuario usuario;
  const OrdensServicoPage({super.key, required this.usuario});

  @override
  State<OrdensServicoPage> createState() => _OrdensServicoPageState();
}

class _OrdensServicoPageState extends State<OrdensServicoPage> {
  static const Color primaryColor = Color(0xFF1A237E);
  final _service = GetIt.I<OrdemServicoDomainServices>();
  Future<List<OrdemServico>>? _futureOrdens;

  @override
  void initState() {
    super.initState();
    _recarregarDados();
  }

  void _recarregarDados() {
    setState(() {
      _futureOrdens = _service.buscarTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ordens de Serviço', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.pending_actions), text: 'Pendentes'),
              Tab(icon: Icon(Icons.check_circle_outline), text: 'Concluídas'),
            ],
          ),
        ),
        body: FutureBuilder<List<OrdemServico>>(
          future: _futureOrdens,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Erro ao carregar ordens: ${snapshot.error}"));
            }
            final ordens = snapshot.data ?? [];
            return TabBarView(
              children: [
                _ListaOS(ordens: ordens, status: StatusOS.aberta, usuario: widget.usuario, onRefresh: _recarregarDados),
                _ListaOS(ordens: ordens, status: StatusOS.concluida, usuario: widget.usuario, onRefresh: _recarregarDados),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ListaOS extends StatefulWidget {
  final List<OrdemServico> ordens;
  final StatusOS status;
  final Usuario usuario;
  final VoidCallback onRefresh;

  const _ListaOS({required this.ordens, required this.status, required this.usuario, required this.onRefresh});

  @override
  State<_ListaOS> createState() => _ListaOSState();
}

class _ListaOSState extends State<_ListaOS> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final filtradas = widget.ordens.where((os) => os.status == widget.status).toList();


    if (filtradas.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma ordem ${widget.status == StatusOS.aberta ? 'pendente' : 'concluída'}.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: filtradas.length,
          itemBuilder: (context, index) => _OsCard(
            os: filtradas[index],
            usuario: widget.usuario,
            onRefresh: widget.onRefresh,
          ),
        ),
      ),
    );
  }
}

class _OsCard extends StatelessWidget {
  final OrdemServico os;
  final Usuario usuario;
  final VoidCallback onRefresh;

  const _OsCard({required this.os, required this.usuario, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConcluida = os.status == StatusOS.concluida;
    final podeExecutar = usuario.perfil == Perfil.administrador || usuario.perfil == Perfil.tecnicoResponsavel;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isConcluida ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
          child: Icon(isConcluida ? Icons.check : Icons.build, color: isConcluida ? Colors.green : Colors.orange),
        ),
        title: FutureBuilder<Ativo?>(
          future: GetIt.I<AtivoRepository>().buscarPorId(os.ativoId),
          builder: (context, snapshot) => Text(
            snapshot.data?.nome ?? "Carregando...",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: Text('Prioridade: ${os.prioridade}'),
        trailing: (isConcluida || !podeExecutar) ? null : Icon(Icons.arrow_forward_ios, size: 16, color: theme.hintColor),
        onTap: (isConcluida || !podeExecutar) ? null : () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrdemServicoExecucaoPage(ordem: os, usuario: usuario))
          ).then((result) {
            if (result == true) onRefresh();
          });
        },
      ),
    );
  }
}