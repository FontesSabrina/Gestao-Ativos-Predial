import 'package:flutter/material.dart';
import '../../domain/entities/usuario.dart';
import 'abrir_chamado_page.dart';
import 'chamados_pendentes_page.dart';

class GerenciamentoChamadosPage extends StatelessWidget {
  final Usuario usuario;
  
  const GerenciamentoChamadosPage({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    if (usuario.perfil == Perfil.administrador) {
      return ChamadosPendentesPage(usuario: usuario);
    } 
    
    return AbrirChamadoPage(usuario: usuario);
  }
}