import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/chamado.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../../domain/services/chamado_domain_services.dart';

class ChamadoAprovacaoPage extends StatefulWidget {
  final Chamado chamado;
  const ChamadoAprovacaoPage({super.key, required this.chamado});

  @override
  State<ChamadoAprovacaoPage> createState() => _ChamadoAprovacaoPageState();
}

class _ChamadoAprovacaoPageState extends State<ChamadoAprovacaoPage> {
  late Future<List<Usuario>> _futureTecnicos;
  late final ChamadoDomainServices _chamadoService;
  Usuario? _tecnicoResponsavelSelecionado;
  bool _aprovando = false;

  static const Color azulFixo = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    final repo = GetIt.I<UsuarioRepository>();
    _futureTecnicos = repo.buscarPorPerfil(Perfil.tecnicoResponsavel);
    _chamadoService = GetIt.I<ChamadoDomainServices>();
  }

  Future<void> _aprovarEGerarOS() async {
    if (_tecnicoResponsavelSelecionado == null) return;
    setState(() => _aprovando = true);

    try {
      await _chamadoService.aprovarChamadoEGerarOS(
        chamado: widget.chamado,
        tecnico: _tecnicoResponsavelSelecionado!,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Ordem de Serviço gerada com sucesso!'),
            ],
          ), 
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
      
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar O.S.: $e'), 
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _aprovando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCritico = widget.chamado.prioridade.toLowerCase() == 'alta';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Análise do Gestor', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), 
        backgroundColor: azulFixo, 
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: FutureBuilder<List<Usuario>>(
            future: _futureTecnicos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: azulFixo));
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Erro ao carregar técnicos."));
              }
              
              final tecnicos = snapshot.data ?? [];
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Detalhes do Chamado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 10),

                    Card(
                      elevation: 2,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: isCritico ? BorderSide(color: Colors.red.withOpacity(0.3), width: 1) : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.chamado.ativo.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
                            const SizedBox(height: 8),
                            Text('Problema Relatado:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text(widget.chamado.descricaoFalha, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                            const SizedBox(height: 16),
                            
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _buildBadge(Icons.flag, widget.chamado.prioridade, isCritico ? Colors.red[700]! : (widget.chamado.prioridade.toLowerCase() == 'média' ? Colors.amber[800]! : Colors.green[700]!)),
                                _buildBadge(Icons.location_on, widget.chamado.ativo.localizacao, Colors.blue[700]!),
                                _buildBadge(Icons.build, widget.chamado.tipo.name.toUpperCase(), Colors.orange[800]!),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    const Text('Designar Equipe Técnica', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<Usuario>(
                      hint: const Text('Selecione o técnico responsável'),
                      isExpanded: true,
                      value: _tecnicoResponsavelSelecionado, 
                      icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: azulFixo),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline, color: azulFixo),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                      ),
                      items: tecnicos.map((t) {
                        return DropdownMenuItem<Usuario>(
                          value: t,
                          child: Text(t.nome, style: const TextStyle(fontSize: 15)),
                        );
                      }).toList(),
                      onChanged: (novoTecnico) => setState(() => _tecnicoResponsavelSelecionado = novoTecnico),
                    ),
                    
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_tecnicoResponsavelSelecionado == null || _aprovando) ? null : _aprovarEGerarOS,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulFixo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _aprovando 
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text('APROVAR E GERAR O.S.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08), 
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}