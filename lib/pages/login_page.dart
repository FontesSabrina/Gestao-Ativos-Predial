import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../routes.dart';
import '../domain/services/usuario_domain_services.dart';
import '../domain/repositories/usuario_repository.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  
  bool _senhaVisivel = false;
  
  late final UsuarioDomainServices _service;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    final repo = GetIt.I<UsuarioRepository>();
    _service = UsuarioDomainServices(repo);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _fazerLogin() async {
    setState(() => _carregando = true);

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final usuario = await _service.autenticar(_emailController.text, _senhaController.text);

      setState(() => _carregando = false);

      if (usuario != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              settings: const RouteSettings(name: AppRoutes.home),
              builder: (context) => HomePage(usuario: usuario),
            ),
          );
        }
      } else {
        if (mounted) {
          _mostrarErro('Acesso negado. Verifique suas credenciais.');
        }
      }
    } catch (e) {
      setState(() => _carregando = false);
      _mostrarErro('Erro ao autenticar: $e');
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1), Colors.black],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(40),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 40, offset: const Offset(0, 20))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.indigo[50], borderRadius: BorderRadius.circular(20)),
                    child: Icon(Icons.settings_suggest_rounded, size: 70, color: Colors.indigo[900]),
                  ),
                  const SizedBox(height: 25),
                  Text('AURA', style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900, color: Colors.indigo[900], letterSpacing: 4)),
                  const Text('RESTRITO PARA COLABORADORES', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  const SizedBox(height: 45),
                  
                  _buildTextField(controller: _emailController, label: 'Usuário / E-mail', icon: Icons.person_pin_rounded),
                  const SizedBox(height: 20),
                  
                  _buildTextField(controller: _senhaController, label: 'Senha', icon: Icons.vpn_key_rounded, isPassword: true),
                  
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo[900], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: _carregando ? null : _fazerLogin,
                      child: _carregando ? const CircularProgressIndicator(color: Colors.white) : const Text('ENTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text("Versão 1.0.26 - Uso Privado", style: TextStyle(color: Colors.black26, fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_senhaVisivel : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black45, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: Colors.indigo[900]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_senhaVisivel ? Icons.visibility : Icons.visibility_off, color: Colors.indigo[900]),
                onPressed: () {
                  setState(() {
                    _senhaVisivel = !_senhaVisivel;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF0F2F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.indigo[900]!, width: 2)),
      ),
    );
  }
}