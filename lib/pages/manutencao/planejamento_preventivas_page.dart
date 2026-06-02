import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/entities/usuario.dart';
import '../../../domain/entities/ordem_servico.dart';
import '../../../domain/entities/ativo.dart';
import '../../../domain/services/ordem_servico_domain_services.dart';
import '../../../domain/repositories/ativo_repository.dart';

class PlanejamentoPreventivasPage extends StatefulWidget {
  final Usuario usuario;
  const PlanejamentoPreventivasPage({super.key, required this.usuario});

  @override
  State<PlanejamentoPreventivasPage> createState() => _PlanejamentoPreventivasPageState();
}

class _PlanejamentoPreventivasPageState extends State<PlanejamentoPreventivasPage> {
  static const Color primaryColor = Color(0xFF1A237E);
  DateTime _dataSelecionada = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Planejamento Preventivo', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.calendar_month_rounded), text: 'Cronograma'),
              Tab(icon: Icon(Icons.warning_amber_rounded), text: 'Alertas'),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: TabBarView(
              children: [
                _CronogramaTab(
                  dataSelecionada: _dataSelecionada, 
                  onDateChanged: (d) => setState(() => _dataSelecionada = d)
                ),
                const _AlertasTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CronogramaTab extends StatefulWidget {
  final DateTime dataSelecionada;
  final Function(DateTime) onDateChanged;
  const _CronogramaTab({required this.dataSelecionada, required this.onDateChanged});

  @override
  State<_CronogramaTab> createState() => _CronogramaTabState();
}

class _CronogramaTabState extends State<_CronogramaTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          color: theme.cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Data: ${widget.dataSelecionada.day.toString().padLeft(2, '0')}/${widget.dataSelecionada.month.toString().padLeft(2, '0')}/${widget.dataSelecionada.year}',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final data = await showDatePicker(
                    context: context,
                    initialDate: widget.dataSelecionada,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (data != null) widget.onDateChanged(data);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E), 
                  foregroundColor: Colors.white
                ),
                icon: const Icon(Icons.date_range),
                label: const Text('Alterar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<OrdemServico>>(
            future: GetIt.I<OrdemServicoDomainServices>().buscarTodos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final ordensDoDia = (snapshot.data ?? []).where((os) => 
                os.dataAbertura.year == widget.dataSelecionada.year &&
                os.dataAbertura.month == widget.dataSelecionada.month &&
                os.dataAbertura.day == widget.dataSelecionada.day
              ).toList();

              if (ordensDoDia.isEmpty) {
                return Center(child: Text('Nenhuma preventiva agendada.', style: TextStyle(color: theme.hintColor)));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: ordensDoDia.length,
                itemBuilder: (context, index) => _CardPreventiva(os: ordensDoDia[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AlertasTab extends StatelessWidget {
  const _AlertasTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ativo>>(
      future: GetIt.I<AtivoRepository>().buscarTodos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final ativosAlerta = (snapshot.data ?? []).where((a) {
          final tempoUso = DateTime.now().difference(a.dataAquisicao).inDays;
          return a.estadoConservacao.toLowerCase() != 'bom' || tempoUso > 730;
        }).toList();

        if (ativosAlerta.isEmpty) {
          return Center(child: Text('Nenhum alerta pendente.', style: TextStyle(color: Theme.of(context).hintColor)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: ativosAlerta.length,
          itemBuilder: (context, index) {
            final ativo = ativosAlerta[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.warning_rounded, color: Colors.amber),
                title: Text(ativo.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Estado: ${ativo.estadoConservacao.toUpperCase()}'),
                trailing: TextButton(onPressed: () {}, child: const Text('PROGRAMAR', style: TextStyle(color: Colors.blueAccent))),
              ),
            );
          },
        );
      },
    );
  }
}

class _CardPreventiva extends StatelessWidget {
  final OrdemServico os;
  const _CardPreventiva({required this.os});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.build_circle, color: Colors.white)
        ),
        title: FutureBuilder<Ativo?>(
          future: GetIt.I<AtivoRepository>().buscarPorId(os.ativoId),
          builder: (context, snapshot) => Text(
            snapshot.data?.nome ?? "Carregando...", 
            style: const TextStyle(fontWeight: FontWeight.bold)
          ),
        ),
        subtitle: Text('Prioridade: ${os.prioridade}'),
        trailing: const Chip(
          label: Text('PREVENTIVA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Color(0xFF1A237E),
        ),
      ),
    );
  }
}