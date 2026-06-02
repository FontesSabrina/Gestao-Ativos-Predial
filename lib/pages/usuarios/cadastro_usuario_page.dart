import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  
  static const Color azulFixo = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Novo Usuário", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: azulFixo,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
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
                    _buildTextField(_nomeController, "Nome Completo", Icons.person, false),
                    const SizedBox(height: 16),
                    _buildTextField(_emailController, "E-mail", Icons.email, false),
                    const SizedBox(height: 16),
                    _buildTextField(_senhaController, "Senha", Icons.lock, true),
                    const SizedBox(height: 16),
                    _buildTextField(_confirmarSenhaController, "Confirmar Senha", Icons.lock_outline, true,
                      validator: (value) => value != _senhaController.text ? "As senhas não coincidem" : null),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: azulFixo, foregroundColor: Colors.white),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Lógica de salvar
                          }
                        },
                        child: const Text("CADASTRAR", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isPassword, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: azulFixo),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: azulFixo, width: 2)),
      ),
      validator: validator ?? (value) => value!.isEmpty ? "Campo obrigatório" : null,
    );
  }
}