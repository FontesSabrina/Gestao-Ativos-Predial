import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/ordem_servico.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/services/chamado_domain_services.dart';

class OrdemServicoExecucaoPage extends StatefulWidget {
  final OrdemServico ordem;
  final Usuario usuario;

  const OrdemServicoExecucaoPage({super.key, required this.ordem, required this.usuario});

  @override
  State<OrdemServicoExecucaoPage> createState() => _OrdemServicoExecucaoPageState();
}

class _OrdemServicoExecucaoPageState extends State<OrdemServicoExecucaoPage> {
  static const Color primaryColor = Color(0xFF1A237E);

  final _service = GetIt.I<ChamadoDomainServices>();
  final _formKey = GlobalKey<FormState>();

  final _relatoController = TextEditingController();
  final _custoPecasController = TextEditingController();
  final _custoMaoDeObraController = TextEditingController();
  
  DateTime _dataHoraInicio = DateTime.now();
  DateTime _dataHoraFim = DateTime.now();

  @override
  void initState() {
    super.initState();
    _relatoController.text = widget.ordem.relatotecnico ?? '';
    _custoPecasController.text = widget.ordem.custoPecas.toStringAsFixed(2);
    _custoMaoDeObraController.text = widget.ordem.custoMaoDeObra.toStringAsFixed(2);
  }

  Future<void> _selecionarDataHora(bool isInicio) async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: isInicio ? _dataHoraInicio : _dataHoraFim,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(primaryColor: primaryColor),
        child: child!,
      ),
    );

    if (data != null && mounted) {
      final TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isInicio ? _dataHoraInicio : _dataHoraFim),
      );

      if (hora != null) {
        setState(() {
          final novaDataHora = DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
          if (isInicio) _dataHoraInicio = novaDataHora;
          else _dataHoraFim = novaDataHora;
        });
      }
    }
  }

  void _finalizar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataHoraFim.isBefore(_dataHoraInicio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A data final é anterior à inicial!'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await _service.finalizarOS(
        ordem: widget.ordem,
        relato: _relatoController.text,
        custoPecas: double.tryParse(_custoPecasController.text.replaceAll(',', '.')) ?? 0.0,
        custoMaoDeObra: double.tryParse(_custoMaoDeObraController.text.replaceAll(',', '.')) ?? 0.0,
        executor: widget.usuario,
        dataInicio: _dataHoraInicio,
        dataFim: _dataHoraFim,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final duracao = _dataHoraFim.difference(_dataHoraInicio);

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fundo Escuro
      appBar: AppBar(
        title: const Text('Execução Técnica', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeaderInfo(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildTimeTile("Início", _dataHoraInicio, () => _selecionarDataHora(true))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTimeTile("Fim", _dataHoraFim, () => _selecionarDataHora(false))),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text("Tempo decorrido: ${duracao.inMinutes} min", 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
              ),
              TextFormField(
                controller: _relatoController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: _inputStyle("Relatório técnico detalhado..."),
                validator: (v) => v!.isEmpty ? 'Relatório obrigatório' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildCustoField(_custoPecasController, 'Peças (R\$)')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildCustoField(_custoMaoDeObraController, 'Mão de Obra (R\$)')),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _finalizar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800], 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text('FINALIZAR O.S.', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: const Color(0xFF1E1E1E), // Fundo de campos escuro
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );

  Widget _buildTimeTile(String label, DateTime dt, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white70)), 
        const SizedBox(height: 4),
        Text(DateFormat('dd/MM HH:mm').format(dt), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
      ]),
    ),
  );

  Widget _buildCustoField(TextEditingController controller, String label) => TextFormField(
    controller: controller,
    style: const TextStyle(color: Colors.white),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: _inputStyle(label),
  );

  Widget _buildHeaderInfo() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(15)),
    child: Center(
      child: Text(
        "O.S. #${widget.ordem.id.length > 5 ? widget.ordem.id.substring(0, 5) : widget.ordem.id}", 
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
      ),
    ),
  );
}