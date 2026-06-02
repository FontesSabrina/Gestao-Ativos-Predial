import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/item_estoque.dart';
import '../../domain/services/estoque_domain_services.dart';

class EstoqueFormPage extends StatefulWidget {
  const EstoqueFormPage({super.key});

  @override
  State<EstoqueFormPage> createState() => _EstoqueFormPageState();
}

class _EstoqueFormPageState extends State<EstoqueFormPage> {
  final _service = GetIt.I<EstoqueDomainServices>();
  final _formKey = GlobalKey<FormState>();
  
  final _nomeController = TextEditingController();
  final _qtdController = TextEditingController();
  final _nivelMinimoController = TextEditingController(text: '5');
  final _fornecedorController = TextEditingController();
  final _unidadeController = TextEditingController(text: 'Unidade');
  final _precoController = TextEditingController(text: '0.0');

  static const Color azulFixo = Color(0xFF1A237E);

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final novoItem = ItemEstoque(
        id: const Uuid().v4(),
        nome: _nomeController.text,
        quantidade: int.tryParse(_qtdController.text) ?? 0,
        nivelMinimo: int.tryParse(_nivelMinimoController.text) ?? 5,
        unidadeMedida: _unidadeController.text.isNotEmpty ? _unidadeController.text : 'Unidade',
        fornecedor: _fornecedorController.text.isNotEmpty ? _fornecedorController.text : 'Sem fornecedor',
        precoUnitario: double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0.0,
      );
      
      await _service.salvar(novoItem);
      
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _qtdController.dispose();
    _nivelMinimoController.dispose();
    _fornecedorController.dispose();
    _unidadeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Novo Item de Estoque', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: azulFixo,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_nomeController, "Nome do Item/Peça", Icons.inventory_2),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_qtdController, "Qtd. Atual", Icons.numbers, isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(_unidadeController, "Unidade", Icons.straighten)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_nivelMinimoController, "Nível Mínimo", Icons.warning_amber_rounded, isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(_precoController, "Preço Unitário", Icons.attach_money, isDecimal: true)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_fornecedorController, "Fornecedor Parceiro", Icons.business),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _salvar, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: azulFixo,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('SALVAR ITEM', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool isDecimal = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber || isDecimal ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber 
        ? [FilteringTextInputFormatter.digitsOnly] 
        : isDecimal ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*'))] : [],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: azulFixo),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
    );
  }
}