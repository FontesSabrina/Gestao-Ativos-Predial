import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/ativo.dart';
import '../../domain/entities/ambiente.dart';
import '../../domain/repositories/ativo_repository.dart';
import '../../domain/repositories/ambiente_repository.dart';

class AtivoFormPage extends StatefulWidget {
  final Usuario usuario;
  final Ativo? ativo;

  const AtivoFormPage({super.key, required this.usuario, this.ativo});

  @override
  State<AtivoFormPage> createState() => _AtivoFormPageState();
}

class _AtivoFormPageState extends State<AtivoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _ativoRepository = GetIt.I<AtivoRepository>();
  final _ambienteRepository = GetIt.I<AmbienteRepository>();

  List<Ambiente> _listaAmbientes = [];
  Ambiente? _ambienteSelecionado;
  
  final List<String> _estadosPossiveis = ['Novo', 'Bom', 'Regular', 'Ruim', 'Em Manutenção', 'Desativado'];

  late TextEditingController _nomeController;
  late TextEditingController _patrimonioController;
  late TextEditingController _estadoController;
  late TextEditingController _dataController;

  static const Color azulFixo = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.ativo?.nome ?? "");
    _patrimonioController = TextEditingController(text: widget.ativo?.patrimonio ?? "");
    _estadoController = TextEditingController(text: widget.ativo?.estadoConservacao ?? _estadosPossiveis.first);
    
    final data = widget.ativo?.dataAquisicao ?? DateTime.now();
    _dataController = TextEditingController(text: "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}");
    
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final ambientes = await _ambienteRepository.buscarTodos();
    if (!mounted) return;

    setState(() {
      _listaAmbientes = ambientes;
      if (widget.ativo != null) {
        try {
          _ambienteSelecionado = _listaAmbientes.firstWhere((a) => a.nome == widget.ativo!.localizacao);
        } catch (e) {
          _ambienteSelecionado = _listaAmbientes.isNotEmpty ? _listaAmbientes.first : null;
        }
      }
    });
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? selecionada = await showDatePicker(
      context: context,
      initialDate: widget.ativo?.dataAquisicao ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selecionada != null && mounted) {
      setState(() {
        _dataController.text = "${selecionada.day.toString().padLeft(2, '0')}/${selecionada.month.toString().padLeft(2, '0')}/${selecionada.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdicao = widget.ativo != null;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Ativo' : 'Novo Ativo', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: azulFixo,
        iconTheme: const IconThemeData(color: Colors.white),
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
                    _buildField(_nomeController, 'Nome do Equipamento', Icons.computer),
                    _buildField(_patrimonioController, 'Número do Patrimônio', Icons.qr_code),
                    
                    DropdownButtonFormField<Ambiente>(
                      value: _ambienteSelecionado,
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Localização / Sala', Icons.location_on),
                      items: _listaAmbientes.map((a) => DropdownMenuItem(value: a, child: Text(a.nome, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (val) => setState(() => _ambienteSelecionado = val),
                      validator: (val) => val == null ? 'Selecione a localização' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _estadosPossiveis.contains(_estadoController.text) ? _estadoController.text : _estadosPossiveis.first,
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Estado de Conservação', Icons.build_circle_outlined),
                      items: _estadosPossiveis.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (val) => setState(() => _estadoController.text = val!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dataController,
                      readOnly: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Data de Aquisição', Icons.calendar_today),
                      onTap: () => _selecionarData(context),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: azulFixo, foregroundColor: Colors.white),
                        onPressed: () async {
                          if (_formKey.currentState!.validate() && _ambienteSelecionado != null) {
                            List<String> p = _dataController.text.split('/');
                            DateTime dataFinal = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
                            final novoAtivo = Ativo(
                              id: isEdicao ? widget.ativo!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                              nome: _nomeController.text,
                              patrimonio: _patrimonioController.text,
                              localizacao: _ambienteSelecionado!.nome,
                              estadoConservacao: _estadoController.text,
                              dataAquisicao: dataFinal,
                            );
                            await _ativoRepository.salvar(novoAtivo);
                            if (mounted) Navigator.pop(context);
                          }
                        },
                        child: Text(isEdicao ? 'SALVAR ALTERAÇÕES' : 'SALVAR ATIVO', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label, icon),
        validator: (value) => value == null || value.isEmpty ? 'Informe o $label' : null,
      ),
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