import 'package:flutter/material.dart';
import '../../domain/entities/usuario.dart';
import 'abrir_chamado_page.dart';
import 'chamados_pendentes_page.dart';

class GerenciamentoChamadosPage extends StatelessWidget {
  final Usuario usuario;
  
  const GerenciamentoChamadosPage({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    // Roteamento baseado no perfil do usuário
    // Mantemos a lógica original para garantir a experiência correta por perfil
    if (usuario.perfil == Perfil.administrador) {
      return ChamadosPendentesPage(usuario: usuario);
    } 
    
    // Usuários comuns ou técnicos são direcionados para a abertura de chamado
    return AbrirChamadoPage(usuario: usuario);
  }
}