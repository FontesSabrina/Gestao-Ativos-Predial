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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Abrir Chamado', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: azulFixo,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildDropdown('Ativo', _idAtivoSelecionado, Icons.computer, 
                      _ativos.map((a) => DropdownMenuItem(value: a.id, child: Text(a.nome, style: const TextStyle(color: Colors.white)))).toList(),
                      (val) => setState(() => _idAtivoSelecionado = val)),
                    const SizedBox(height: 16),
                    _buildDropdown('Prioridade', _prioridadeSelecionada, Icons.priority_high, 
                      ['Baixa', 'Média', 'Alta'].map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(color: Colors.white)))).toList(),
                      (val) => setState(() => _prioridadeSelecionada = val!)),
                    const SizedBox(height: 16),
                    _buildDropdown('Tipo de Manutenção', _tipoSelecionado, Icons.build_circle_outlined, 
                      TipoManutencao.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase(), style: const TextStyle(color: Colors.white)))).toList(),
                      (val) => setState(() => _tipoSelecionado = val!)),
                    const SizedBox(height: 16),
                    _buildTextField(_descricaoController, "Descrição da Falha", Icons.description, maxLines: 4),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _enviarChamado,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulFixo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('SALVAR CHAMADO', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildDropdown(String label, dynamic value, IconData icon, List<DropdownMenuItem> items, Function(dynamic) onChanged) {
    return DropdownButtonFormField(
      value: value,
      dropdownColor: const Color(0xFF1E1E1E),
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
      items: items,
      onChanged: onChanged,
      validator: (val) => val == null ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
      validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: azulFixo),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: azulFixo, width: 2)),
    );
  }
}