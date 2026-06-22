import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/ordem_servico.dart';
import '../../../domain/entities/usuario.dart';
import '../../../domain/services/chamado_domain_services.dart';

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

  @override
  void dispose() {
    _relatoController.dispose();
    _custoPecasController.dispose();
    _custoMaoDeObraController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataHora(bool isInicio) async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: isInicio ? _dataHoraInicio : _dataHoraFim,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
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
        const SnackBar(
          content: Text('A data final não pode ser anterior à inicial!'), 
          backgroundColor: Colors.orange
        ),
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Ordem de Serviço finalizada com sucesso!', 
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
        
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao finalizar O.S.: $e'), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final duracao = _dataHoraFim.difference(_dataHoraInicio);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Execução Técnico', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
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
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildHeaderInfo(),
                    const SizedBox(height: 24),
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
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    TextFormField(
                      controller: _relatoController,
                      maxLines: 4,
                      decoration: _inputStyle("Relatório técnico detalhado..."),
                      validator: (v) => v!.isEmpty ? 'Relatório obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildCustoField(_custoPecasController, 'Peças (R\$)')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildCustoField(_custoMaoDeObraController, 'Mão de Obra (R\$)')),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _finalizar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        child: const Text('FINALIZAR O.S.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildHeaderInfo() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(12)),
    child: Center(
      child: Text(
        "O.S. #${widget.ordem.id.length > 5 ? widget.ordem.id.substring(0, 5) : widget.ordem.id}", 
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
      ),
    ),
  );

  InputDecoration _inputStyle(String hint) => InputDecoration(
    labelText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
  );

  Widget _buildTimeTile(String label, DateTime dt, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: InputDecorator(
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      child: Text(DateFormat('dd/MM HH:mm').format(dt), style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildCustoField(TextEditingController controller, String label) => TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
    decoration: _inputStyle(label),
    validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
  );
}