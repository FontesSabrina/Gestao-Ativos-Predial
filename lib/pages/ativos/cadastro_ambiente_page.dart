import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/ambiente.dart';
import '../../domain/repositories/ambiente_repository.dart';

class CadastroAmbientePage extends StatefulWidget {
  const CadastroAmbientePage({super.key});

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

  Future<void> _salvarAmbiente() async {
    if (_formKey.currentState!.validate()) {
      final novoAmbiente = Ambiente(
        id: const Uuid().v4(),
        nome: _nomeController.text,
        predio: _predioController.text,
        andar: _andarController.text,
        observacoes: _obsController.text,
      );
      await _ambienteRepository.salvar(novoAmbiente);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Cadastrar Ambiente", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: azulFixo,
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
                    _buildTextField(_nomeController, "Nome / Identificação", Icons.pin_drop),
                    const SizedBox(height: 16),
                    _buildTextField(_predioController, "Prédio / Bloco", Icons.business),
                    const SizedBox(height: 16),
                    _buildTextField(_andarController, "Andar", Icons.layers),
                    const SizedBox(height: 16),
                    _buildTextField(_obsController, "Observações", Icons.description, maxLines: 3),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: azulFixo, foregroundColor: Colors.white),
                        onPressed: _salvarAmbiente,
                        child: const Text("CADASTRAR AMBIENTE", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: azulFixo),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: azulFixo, width: 2)),
      ),
    );
  }
}