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
  final _unidadeController = TextEditingController(); 
  final _precoController = TextEditingController(text: '0.0');

  static const Color azulFixo = Color(0xFF1A237E);

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      try {
        final novoItem = ItemEstoque(
          id: const Uuid().v4(),
          nome: _nomeController.text,
          quantidade: int.tryParse(_qtdController.text) ?? 0,
          nivelMinimo: int.tryParse(_nivelMinimoController.text) ?? 5,
          unidadeMedida: _unidadeController.text.isNotEmpty ? _unidadeController.text : 'Un',
          fornecedor: _fornecedorController.text.isNotEmpty ? _fornecedorController.text : 'Sem fornecedor',
          precoUnitario: double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0.0,
        );
        
        await _service.salvar(novoItem);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item cadastrado com sucesso!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao salvar o item."), backgroundColor: Colors.red),
        );
      }
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
        title: const Text('Cadastrar Estoque', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                          // Alteração aqui: isLettersOnly: true para restringir a apenas letras
                          Expanded(child: _buildTextField(_unidadeController, "Unidade", Icons.straighten, isLettersOnly: true, hintText: "Ex: Kg, L, Un")),
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
                          style: ElevatedButton.styleFrom(backgroundColor: azulFixo, foregroundColor: Colors.white),
                          child: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool isDecimal = false, bool isLettersOnly = false, String? hintText}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : (isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text),
      inputFormatters: [
        if (isNumber) FilteringTextInputFormatter.digitsOnly,
        if (isDecimal) FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*')),
        if (isLettersOnly) FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ\s]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: azulFixo),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
    );
  }
}