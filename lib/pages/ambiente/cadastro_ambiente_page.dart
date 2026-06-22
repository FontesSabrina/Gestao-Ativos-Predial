import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/ambiente.dart';
import '../../domain/repositories/ambiente_repository.dart';

class CadastroAmbientePage extends StatefulWidget {
  final Ambiente? ambiente;

  const CadastroAmbientePage({super.key, this.ambiente});

  @override
  State<CadastroAmbientePage> createState() => _CadastroAmbientePageState();
}

class _CadastroAmbientePageState extends State<CadastroAmbientePage> {
  final _formKey = GlobalKey<FormState>();
  final _ambienteRepository = GetIt.I<AmbienteRepository>();

  final _nomeController = TextEditingController();
  final _predioController = TextEditingController();
  final _andarController = TextEditingController();
  final _obsController = TextEditingController();

  static const Color azulFixo = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    if (widget.ambiente != null) {
      _nomeController.text = widget.ambiente!.nome;
      _predioController.text = widget.ambiente!.predio;
      _andarController.text = widget.ambiente!.andar;
      _obsController.text = widget.ambiente!.observacoes;
    }
  }

  Future<void> _salvarAmbiente() async {
    if (_formKey.currentState!.validate()) {
      try {
        final novoAmbiente = Ambiente(
          id: widget.ambiente?.id ?? const Uuid().v4(),
          nome: _nomeController.text,
          predio: _predioController.text,
          andar: _andarController.text,
          observacoes: _obsController.text,
        );

        await _ambienteRepository.salvar(novoAmbiente);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.ambiente == null 
                  ? "Ambiente cadastrado com sucesso!" 
                  : "Ambiente updated com sucesso!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Erro ao salvar ambiente. Tente novamente."),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdicao = widget.ambiente != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? "Editar Ambiente" : "Cadastrar Ambiente", 
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white, 
                borderRadius: BorderRadius.circular(20), 
                border: Border.all(color: isDark ? Colors.white24 : Colors.black12, width: 1.5)
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_nomeController, "Nome / Identificação", Icons.pin_drop, isDark),
                    const SizedBox(height: 16),
                    _buildTextField(_predioController, "Prédio / Bloco", Icons.business, isDark),
                    const SizedBox(height: 16),
                    _buildTextField(_andarController, "Andar", Icons.layers, isDark),
                    const SizedBox(height: 16),
                    _buildTextField(_obsController, "Observações", Icons.description, isDark, maxLines: 3),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulFixo, 
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _salvarAmbiente,
                        child: Text(
                          isEdicao ? "ALTERAR" : "SALVAR", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                        ),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isDark, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        prefixIcon: Icon(icon, color: azulFixo),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: const BorderSide(color: azulFixo, width: 2)
        ),
      ),
      validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
    );
  }
}