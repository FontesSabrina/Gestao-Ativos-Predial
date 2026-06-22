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
  
  
  bool _esconderSenha = true;
  bool _esconderConfirmarSenha = true;

  Perfil _perfilSelecionado = Perfil.solicitante;
  static const Color azulFixo = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    if (widget.usuario != null) {
      _nomeController.text = widget.usuario!.nome;
      _emailController.text = widget.usuario!.email;
      _perfilSelecionado = widget.usuario!.perfil;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
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
                      items: Perfil.values.map((p) => DropdownMenuItem(
                        value: p, 
                        child: Text(p.name.toUpperCase())
                      )).toList(),
                      onChanged: (p) => setState(() => _perfilSelecionado = p!),
                    ),
                    const SizedBox(height: 16),

                    
                    _buildTextField(
                      _senhaController, 
                      "Senha", 
                      Icons.lock, 
                      true,
                      esconderTexto: _esconderSenha,
                      onToggleVisibility: () {
                        setState(() => _esconderSenha = !_esconderSenha);
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    
                    _buildTextField(
                      _confirmarSenhaController, 
                      "Confirmar Senha", 
                      Icons.lock_outline, 
                      true,
                      esconderTexto: _esconderConfirmarSenha,
                      onToggleVisibility: () {
                        setState(() => _esconderConfirmarSenha = !_esconderConfirmarSenha);
                      },
                      validator: (value) => value != _senhaController.text ? "As senhas não coincidem" : null,
                    ),
                    
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
                            
                            if (mounted) {
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEdicao 
                                        ? "Usuário atualizado com sucesso!" 
                                        : "Usuário cadastrado com sucesso!",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              Navigator.pop(context);
                            }
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

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    bool isPassword, {
    bool esconderTexto = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? esconderTexto : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: azulFixo),
        suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(
                  esconderTexto ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        border: const OutlineInputBorder(),
      ),
      validator: validator ?? (value) => value!.isEmpty ? "Campo obrigatório" : null,
    );
  }
}