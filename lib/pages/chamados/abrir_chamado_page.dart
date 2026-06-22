import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/chamado.dart';
import '../../domain/entities/ativo.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/services/chamado_domain_services.dart';
import '../../domain/repositories/ativo_repository.dart';

class AbrirChamadoPage extends StatefulWidget {
  final Usuario usuario;
  const AbrirChamadoPage({super.key, required this.usuario});

  @override
  State<AbrirChamadoPage> createState() => _AbrirChamadoPageState();
}

class _AbrirChamadoPageState extends State<AbrirChamadoPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _service = GetIt.I<ChamadoDomainServices>();
  final _ativoRepository = GetIt.I<AtivoRepository>();

  List<Ativo> _ativos = [];
  String? _idAtivoSelecionado;
  String _prioridadeSelecionada = 'Média';
  TipoManutencao _tipoSelecionado = TipoManutencao.corretiva;


  static const Color azulFixo = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    _carregarAtivos();
  }

  Future<void> _carregarAtivos() async {
    final ativos = await _ativoRepository.buscarTodos();
    if (mounted) setState(() => _ativos = ativos);
  }

  Future<void> _enviarChamado() async {
    if (_formKey.currentState!.validate() && _idAtivoSelecionado != null) {
      try {
        final ativo = _ativos.firstWhere((a) => a.id == _idAtivoSelecionado);
        final novoChamado = Chamado(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          ativo: ativo,
          solicitante: widget.usuario,
          descricaoFalha: _descricaoController.text,
          prioridade: _prioridadeSelecionada,
          tipo: _tipoSelecionado,
          status: StatusChamado.aberto,
          dataAbertura: DateTime.now(),
        );

        await _service.registrarChamado(novoChamado);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Chamado aberto com sucesso!'),
            backgroundColor: Colors.green,
          ));
          
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao abrir chamado: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abrir Chamado', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: azulFixo,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildDropdown('Ativo', _idAtivoSelecionado, Icons.computer, 
                      _ativos.map((a) => DropdownMenuItem(value: a.id, child: Text(a.nome))).toList(),
                      (val) => setState(() => _idAtivoSelecionado = val), isDark),
                    const SizedBox(height: 16),
                    _buildDropdown('Prioridade', _prioridadeSelecionada, Icons.priority_high, 
                      ['Baixa', 'Média', 'Alta'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      (val) => setState(() => _prioridadeSelecionada = val!), isDark),
                    const SizedBox(height: 16),
                    _buildDropdown('Tipo de Manutenção', _tipoSelecionado, Icons.build_circle_outlined, 
                      TipoManutencao.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                      (val) => setState(() => _tipoSelecionado = val!), isDark),
                    const SizedBox(height: 16),
                    _buildTextField(_descricaoController, "Descrição da Falha", Icons.description, isDark, maxLines: 4),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 55,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulFixo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _enviarChamado,
                        child: const Text('SALVAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, dynamic value, IconData icon, List<DropdownMenuItem> items, Function(dynamic) onChanged, bool isDark) {
    return DropdownButtonFormField(
      value: value,
      decoration: _inputDecoration(label, icon, isDark),
      items: items,
      onChanged: onChanged,
      validator: (val) => val == null ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isDark, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label, icon, isDark),
      validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: azulFixo),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: isDark ? Colors.white10 : Colors.grey.shade50,
    );
  }
}