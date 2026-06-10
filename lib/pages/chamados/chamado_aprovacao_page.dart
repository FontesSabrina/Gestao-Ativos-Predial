import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/chamado.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../../domain/services/chamado_domain_services.dart';

class ChamadoAprovacaoPage extends StatefulWidget {
  final Chamado chamado;
  final Usuario usuarioLogado;

  const ChamadoAprovacaoPage({
    super.key, 
    required this.chamado, 
    required this.usuarioLogado
  });

  @override
  State<ChamadoAprovacaoPage> createState() => _ChamadoAprovacaoPageState();
}

class _ChamadoAprovacaoPageState extends State<ChamadoAprovacaoPage> {
  late Future<List<Usuario>> _futureTecnicos;
  late final ChamadoDomainServices _chamadoService;
  Usuario? _tecnicoResponsavelSelecionado;
  bool _processando = false;

  static const Color azulFixo = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    _futureTecnicos = GetIt.I<UsuarioRepository>().buscarPorPerfil(Perfil.tecnicoResponsavel);
    _chamadoService = GetIt.I<ChamadoDomainServices>();
  }

  Future<void> _aprovarEGerarOS() async {
    if (_tecnicoResponsavelSelecionado == null) return;
    setState(() => _processando = true);
    try {
      await _chamadoService.aprovarChamadoEGerarOS(
        chamado: widget.chamado,
        tecnico: _tecnicoResponsavelSelecionado!,
        usuarioLogado: widget.usuarioLogado,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _mostrarErro(e.toString());
    }
  }

  Future<void> _cancelarChamado() async {
    setState(() => _processando = true);
    try {
      await _chamadoService.cancelarChamado(widget.chamado);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _mostrarErro(e.toString());
    }
  }

  void _mostrarErro(String erro) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $erro'), backgroundColor: Colors.redAccent)
    );
    setState(() => _processando = false);
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.usuarioLogado.perfil == Perfil.administrador;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise do Chamado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
        backgroundColor: azulFixo,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Usuario>>(
        future: _futureTecnicos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tecnicos = snapshot.data ?? [];
          
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Detalhes do Chamado", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: azulFixo)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow("Ativo (ID):", widget.chamado.ativo.id),
                          _buildInfoRow("Prioridade:", widget.chamado.prioridade.toString()),
                          _buildInfoRow("Data Abertura:", widget.chamado.dataAbertura.toString().substring(0, 16)),
                          const Divider(),
                          const Text("Descrição da Falha:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(widget.chamado.descricaoFalha, style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    if (isAdmin) ...[
                      DropdownButtonFormField<Usuario>(
                        value: _tecnicoResponsavelSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Designar Técnico', 
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline)
                        ),
                        items: tecnicos.map((t) => DropdownMenuItem(value: t, child: Text(t.nome))).toList(),
                        onChanged: (val) => setState(() => _tecnicoResponsavelSelecionado = val),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: azulFixo, 
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: (_tecnicoResponsavelSelecionado == null || _processando) ? null : _aprovarEGerarOS,
                          child: const Text('APROVAR E DESIGNAR', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ] else
                      const Center(
                        child: Text("Aguardando designação do administrador.", 
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
                      ),

                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        onPressed: _processando ? null : _cancelarChamado,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('CANCELAR CHAMADO', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text("$label ", style: const TextStyle(fontWeight: FontWeight.bold, color: azulFixo)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}