import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/entities/ordem_servico.dart';
import '../../../domain/repositories/ordem_servico_repository.dart';
import '../../../domain/repositories/ativo_repository.dart';
import '../../../domain/repositories/usuario_repository.dart';

class ManutencoesPage extends StatefulWidget {
  const ManutencoesPage({super.key});

  @override
  State<ManutencoesPage> createState() => _ManutencoesPageState();
}

class _ManutencoesPageState extends State<ManutencoesPage> {
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color backgroundColor = Color(0xFFF8F9FD);

  final _osRepository = GetIt.I<OrdemServicoRepository>();
  late Future<List<OrdemServico>> _futureOs;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    setState(() {
      _futureOs = _osRepository.buscarTodos();
    });
  }

  String _getStatusLabel(StatusOS status) {
    switch (status) {
      case StatusOS.aberta: return "Aberta";
      case StatusOS.emAndamento: return "Em Andamento";
      case StatusOS.concluida: return "Concluída";
      case StatusOS.cancelada: return "Cancelada";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Ordens de Serviço', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: FutureBuilder<List<OrdemServico>>(
        future: _futureOs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          
          final lista = snapshot.data ?? [];
          if (lista.isEmpty) {
            return const Center(child: Text("Nenhuma ordem encontrada."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final os = lista[index];
              return _OrdemServicoCard(
                os: os, 
                statusLabel: _getStatusLabel(os.status)
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () async {
          await Navigator.pushNamed(context, '/manutencao_form');
          _carregarDados(); 
        },
        label: const Text("NOVA O.S.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _OrdemServicoCard extends StatelessWidget {
  final OrdemServico os;
  final String statusLabel;

  const _OrdemServicoCard({required this.os, required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: FutureBuilder(
          future: GetIt.I<AtivoRepository>().buscarPorId(os.ativoId),
          builder: (context, snapshot) => Text(
            snapshot.data?.nome ?? "Carregando ativo...",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text("Problema: ${os.descricaoProblema}", maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            FutureBuilder(
              future: os.tecnicoResponsavelId != null 
                  ? GetIt.I<UsuarioRepository>().buscarPorId(os.tecnicoResponsavelId!) 
                  : Future.value(null),
              builder: (context, snapshot) => Text(
                "Técnico: ${snapshot.data?.nome ?? 'Aguardando'}",
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(statusLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), 
          backgroundColor: Colors.blue.shade50,
          side: BorderSide.none,
        ),
      ),
    );
  }
}