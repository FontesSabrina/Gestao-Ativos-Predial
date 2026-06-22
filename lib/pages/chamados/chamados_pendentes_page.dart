import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/chamado.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/chamado_repository.dart';
import 'chamado_aprovacao_page.dart';
import 'abrir_chamado_page.dart';
import 'acompanhamento_realtime_page.dart'; 

class ChamadosPendentesPage extends StatefulWidget {
  final Usuario usuario;
  const ChamadosPendentesPage({super.key, required this.usuario});

  @override
  State<ChamadosPendentesPage> createState() => _ChamadosPendentesPageState();
}

class _ChamadosPendentesPageState extends State<ChamadosPendentesPage> {
  late final ChamadoRepository _chamadoRepository;
  List<Chamado> _allChamados = [];
  List<Chamado> _filteredChamados = [];
  bool _carregando = true;

  final TextEditingController _searchController = TextEditingController();
  static const Color azulFixo = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    _chamadoRepository = GetIt.I<ChamadoRepository>();
    _atualizarLista();
    _searchController.addListener(_aplicarFiltros);
  }

  Future<void> _atualizarLista() async {
    if (!mounted) return;
    setState(() => _carregando = true);
    
    final lista = await _chamadoRepository.buscarTodos();
    
    if (!mounted) return;
    setState(() {
      _allChamados = lista.where((c) => c.status == StatusChamado.aberto).toList();
      _carregando = false;
    });
    _aplicarFiltros();
  }

  void _aplicarFiltros() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChamados = _allChamados.where((c) => 
          c.ativo.nome.toLowerCase().contains(query) || 
          c.descricaoFalha.toLowerCase().contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Chamados Pendentes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: azulFixo,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Painel em Tempo Real',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AcompanhamentoRealTimePage(usuario: widget.usuario)),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: azulFixo,
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => AbrirChamadoPage(usuario: widget.usuario))
        ).then((_) => _atualizarLista()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar ativo ou falha...',
                    prefixIcon: const Icon(Icons.search, color: azulFixo),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: _carregando 
                  ? const Center(child: CircularProgressIndicator(color: azulFixo))
                  : _filteredChamados.isEmpty 
                    ? const Center(child: Text("Nenhum chamado pendente encontrado."))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredChamados.length,
                        itemBuilder: (context, i) => _buildChamadoCard(_filteredChamados[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChamadoCard(Chamado c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: azulFixo.withOpacity(0.1),
          child: const Icon(Icons.warning_amber_rounded, color: azulFixo),
        ),
        title: Text(c.ativo.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(c.descricaoFalha, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right, color: azulFixo),
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (_) => ChamadoAprovacaoPage(
              chamado: c, 
              usuarioLogado: widget.usuario
            ),
          )
        ).then((_) => _atualizarLista()),
      ),
    );
  }
}