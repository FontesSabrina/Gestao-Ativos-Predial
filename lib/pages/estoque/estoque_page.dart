import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/usuario.dart'; 
import '../../domain/entities/item_estoque.dart';
import '../../domain/services/estoque_domain_services.dart';
import 'estoque_form_page.dart'; 

class EstoquePage extends StatefulWidget {
  final Usuario usuario;
  const EstoquePage({super.key, required this.usuario});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  final _service = GetIt.I<EstoqueDomainServices>();
  static const Color azulFixo = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    final bool podeEditar = widget.usuario.perfil == Perfil.administrador;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Controle de Estoque', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: azulFixo,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.inventory_2_rounded), text: 'Peças'),
              Tab(icon: Icon(Icons.history_rounded), text: 'Movimentações'),
            ],
          ),
        ),
        floatingActionButton: podeEditar
            ? FloatingActionButton(
                backgroundColor: azulFixo,
                onPressed: () async {
                  final result = await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const EstoqueFormPage())
                  );
                  if (result == true && mounted) { 
                    setState(() {}); 
                  }
                },
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        body: TabBarView(
          children: [
            _buildTabWrapper(_buildItensTab()),
            _buildTabWrapper(_buildHistoricoTab()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabWrapper(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: child,
      ),
    );
  }

  Widget _buildItensTab() {
    return FutureBuilder<List<ItemEstoque>>(
      future: _service.buscarTodos(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: azulFixo));
        }
        if (snapshot.hasError) return const Center(child: Text("Erro ao carregar o estoque."));
        
        final itens = snapshot.data ?? [];
        if (itens.isEmpty) return const Center(child: Text("Nenhum insumo cadastrado."));

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: itens.length,
          itemBuilder: (context, index) {
            final item = itens[index];
            final bool critico = item.quantidade <= (item.nivelMinimo / 2);
            final bool aviso = item.alertaEstoqueBaixo && !critico;

            Color color = critico ? Colors.red : (aviso ? Colors.amber : Colors.green);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(Icons.construction_rounded, color: color),
                ),
                title: Text(item.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Fornecedor: ${item.fornecedor}\nMínimo: ${item.nivelMinimo} ${item.unidadeMedida}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${item.quantidade}', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
                    Text(critico ? 'CRÍTICO' : (aviso ? 'ATENÇÃO' : 'OK'), style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoricoTab() {
    return FutureBuilder<List<ItemEstoque>>(
      future: _service.buscarTodos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: azulFixo));
        
        final itens = snapshot.data!;
        if (itens.isEmpty) return const Center(child: Text("Sem movimentações."));

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: itens.length,
          itemBuilder: (context, index) {
            final item = itens[index];
            final bool entrada = item.quantidade > item.nivelMinimo;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: Icon(
                  entrada ? Icons.arrow_circle_up_rounded : Icons.arrow_circle_down_rounded,
                  color: entrada ? Colors.blue : Colors.orange,
                ),
                title: Text(entrada ? 'Entrada / Abastecimento' : 'Saída para Manutenção'),
                subtitle: Text('Item: ${item.nome} • Via: ${item.fornecedor}'),
                trailing: Text(entrada ? '+${item.quantidade}' : '-1', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: entrada ? Colors.blue : Colors.orange)),
              ),
            );
          },
        );
      },
    );
  }
}