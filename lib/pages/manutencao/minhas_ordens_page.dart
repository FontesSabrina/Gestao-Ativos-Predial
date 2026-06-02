import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/ordem_servico.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/ativo.dart';
import '../../domain/repositories/ordem_servico_repository.dart';
import '../../domain/repositories/ativo_repository.dart';
import '../../pages/ordem_servico/ordem_servico_execucao_page.dart';

class MinhasOrdensPage extends StatefulWidget {
  final Usuario usuarioLogado;

  const MinhasOrdensPage({super.key, required this.usuarioLogado});

  @override
  State<MinhasOrdensPage> createState() => _MinhasOrdensPageState();
}

class _MinhasOrdensPageState extends State<MinhasOrdensPage> {
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color backgroundColor = Color(0xFFF8F9FD);

  final _osRepository = GetIt.I<OrdemServicoRepository>();
  List<OrdemServico> _minhasOrdens = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarOrdens();
  }

  Future<void> _carregarOrdens() async {
    try {
      final todas = await _osRepository.buscarTodos();
      if (mounted) {
        setState(() {
          _minhasOrdens = todas.where((os) => 
            os.tecnicoResponsavelId == widget.usuarioLogado.id && 
            os.status == StatusOS.aberta
          ).toList();
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Minhas Ordens de Serviço', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _minhasOrdens.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _carregarOrdens,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _minhasOrdens.length,
                    itemBuilder: (context, index) => _OsTecnicoCard(
                      os: _minhasOrdens[index],
                      usuario: widget.usuarioLogado,
                      onRefresh: _carregarOrdens,
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build_circle_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma O.S. pendente para você!', 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])
          ),
        ],
      ),
    );
  }
}

class _OsTecnicoCard extends StatelessWidget {
  static const Color primaryColor = Color(0xFF1A237E);
  final OrdemServico os;
  final Usuario usuario;
  final VoidCallback onRefresh;

  const _OsTecnicoCard({required this.os, required this.usuario, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.orange[50], 
          child: const Icon(Icons.build, color: Colors.orange)
        ),
        title: FutureBuilder<Ativo?>(
          future: GetIt.I<AtivoRepository>().buscarPorId(os.ativoId),
          builder: (context, snapshot) => Text(
            snapshot.data?.nome ?? "Carregando...", 
            style: const TextStyle(fontWeight: FontWeight.bold)
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text('Problema: ${os.descricaoProblema}', maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text('Prioridade: ${os.prioridade}', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
          ],
        ),
        trailing: const Icon(Icons.play_arrow_rounded, color: primaryColor, size: 30),
        onTap: () async {
          final recarregar = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrdemServicoExecucaoPage(ordem: os, usuario: usuario)),
          );
          if (recarregar == true) onRefresh();
        },
      ),
    );
  }
}