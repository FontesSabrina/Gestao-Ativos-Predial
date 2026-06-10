import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

class CadastroUsuarioPage extends StatefulWidget {
  final Usuario? usuario;

  const CadastroUsuarioPage({super.key, this.usuario});

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  
  Perfil _perfilSelecionado = Perfil.solicitante;
  static const Color azulFixo = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    if (widget.usuario != null) {
      _nomeController.text = widget.usuario!.nome;
      _emailController.text = widget.usuario!.email;
      // Removida qualquer verificação que envolvesse o perfil de auditor
      _perfilSelecionado = widget.usuario!.perfil;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdicao = widget.usuario != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdicao ? "Editar Usuário" : "Novo Usuário", 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: azulFixo,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.5),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_nomeController, "Nome Completo", Icons.person, false),
                    const SizedBox(height: 16),
                    _buildTextField(_emailController, "E-mail", Icons.email, false),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<Perfil>(
                      value: _perfilSelecionado,
                      decoration: const InputDecoration(
                        labelText: "Perfil de Acesso", 
                        prefixIcon: Icon(Icons.admin_panel_settings, color: azulFixo),
                        border: OutlineInputBorder()
                      ),
                      // Agora usamos diretamente o Enum, que só contém os perfis válidos
                      items: Perfil.values.map((p) => DropdownMenuItem(
                        value: p, 
                        child: Text(p.name.toUpperCase())
                      )).toList(),
                      onChanged: (p) => setState(() => _perfilSelecionado = p!),
                    ),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulFixo,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final novoUsuario = Usuario(
                              id: widget.usuario?.id ?? const Uuid().v4(),
                              nome: _nomeController.text,
                              email: _emailController.text,
                              senha: _senhaController.text,
                              perfil: _perfilSelecionado,
                            );
                            
                            await GetIt.I<UsuarioRepository>().salvar(novoUsuario);
                            if (mounted) Navigator.pop(context);
                          }
                        },
                        child: Text(
                          isEdicao ? "SALVAR ALTERAÇÕES" : "CADASTRAR",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isPassword, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: azulFixo),
        border: const OutlineInputBorder(),
      ),
      validator: validator ?? (value) => value!.isEmpty ? "Campo obrigatório" : null,
    );
  }
}