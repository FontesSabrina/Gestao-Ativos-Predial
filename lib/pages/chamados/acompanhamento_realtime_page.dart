import 'package:flutter/material.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/chamado.dart';
import 'widgets/lista_por_status_widget.dart';

class AcompanhamentoRealTimePage extends StatelessWidget {
  final Usuario usuario;

  static const Color primaryColor = Color(0xFF1A237E);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color indicatorColor = Colors.amber;

  const AcompanhamentoRealTimePage({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, 
      child: Scaffold(
        backgroundColor: darkBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Painel em Tempo Real',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: indicatorColor,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'Abertos', icon: Icon(Icons.assignment_late_outlined, size: 20)),
              Tab(text: 'Em Execução', icon: Icon(Icons.play_circle_outline_rounded, size: 20)),
              Tab(text: 'Concluídos', icon: Icon(Icons.check_circle_outline, size: 20)),
              Tab(text: 'Cancelados', icon: Icon(Icons.cancel_outlined, size: 20)),
            ],
          ),
        ),
        // CORREÇÃO: Passando o usuário para cada widget de lista
        body: TabBarView(
          children: [
            ListaPorStatusWidget(statusFiltrado: StatusChamado.aberto, usuario: usuario),
            ListaPorStatusWidget(statusFiltrado: StatusChamado.emExecucao, usuario: usuario),
            ListaPorStatusWidget(statusFiltrado: StatusChamado.concluido, usuario: usuario),
            ListaPorStatusWidget(statusFiltrado: StatusChamado.cancelado, usuario: usuario),
          ],
        ),
      ),
    );
  }
}