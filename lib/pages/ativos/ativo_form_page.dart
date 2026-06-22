import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
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
  DateTime _dataSelecionada = DateTime.now();

  static const Color azulFixo = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.ativo?.nome ?? "");
    _patrimonioController = TextEditingController(text: widget.ativo?.patrimonio ?? "");
    _estadoController = TextEditingController(text: widget.ativo?.estadoConservacao ?? _estadosPossiveis.first);
    
    _dataSelecionada = widget.ativo?.dataAquisicao ?? DateTime.now();
    _dataController = TextEditingController(text: "${_dataSelecionada.day.toString().padLeft(2, '0')}/${_dataSelecionada.month.toString().padLeft(2, '0')}/${_dataSelecionada.year}");
    
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final ambientes = await _ambienteRepository.buscarTodos();
    if (!mounted) return;

    setState(() {
      _listaAmbientes = ambientes;
      if (widget.ativo != null) {
        _ambienteSelecionado = _listaAmbientes.firstWhere(
          (a) => a.nome == widget.ativo!.localizacao, 
          orElse: () => _listaAmbientes.isNotEmpty ? _listaAmbientes.first : _listaAmbientes.first
        );
      }
    });
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? selecionada = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selecionada != null && mounted) {
      setState(() {
        _dataSelecionada = selecionada;
        _dataController.text = "${selecionada.day.toString().padLeft(2, '0')}/${selecionada.month.toString().padLeft(2, '0')}/${selecionada.year}";
      });
    }
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate() && _ambienteSelecionado != null) {
      try {
        final novoAtivo = Ativo(
          id: widget.ativo?.id ?? const Uuid().v4(),
          nome: _nomeController.text,
          patrimonio: _patrimonioController.text,
          localizacao: _ambienteSelecionado!.nome,
          estadoConservacao: _estadoController.text,
          dataAquisicao: _dataSelecionada,
        );

        await _ativoRepository.salvar(novoAtivo);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ativo saved successfully!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro ao salvar ativo."), backgroundColor: Colors.red),
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
        title: Text(widget.ativo != null ? 'Editar Ativo' : 'Cadastrar Ativo', 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    _buildField(_nomeController, 'Nome do Equipamento', Icons.computer, isDark),
                    _buildField(_patrimonioController, 'Número do Patrimônio', Icons.qr_code, isDark),
                    
                    DropdownButtonFormField<Ambiente>(
                      value: _ambienteSelecionado,
                      decoration: _inputDecoration('Localização / Sala', Icons.location_on, isDark),
                      items: _listaAmbientes.map((a) => DropdownMenuItem(value: a, child: Text(a.nome))).toList(),
                      onChanged: (val) => setState(() => _ambienteSelecionado = val),
                      validator: (val) => val == null ? 'Selecione a localização' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _estadoController.text,
                      decoration: _inputDecoration('Estado de Conservação', Icons.build_circle_outlined, isDark),
                      items: _estadosPossiveis.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _estadoController.text = val!),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _dataController,
                      readOnly: true,
                      decoration: _inputDecoration('Data de Aquisição', Icons.calendar_today, isDark),
                      onTap: () => _selecionarData(context),
                    ),
                    
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulFixo, 
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _salvar,
                        child: Text(widget.ativo != null ? 'ALTERAR' : 'SALVAR', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildField(TextEditingController controller, String label, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          decoration: _inputDecoration(label, icon, isDark),
          validator: (value) => value == null || value.isEmpty ? 'Informe o $label' : null,
        ),
      ),
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