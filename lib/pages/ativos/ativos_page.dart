import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/ativo.dart';
import '../../domain/repositories/ativo_repository.dart';
import 'ativo_form_page.dart';

class AtivosPage extends StatefulWidget {
  final Usuario usuario;
  const AtivosPage({super.key, required this.usuario});

  @override
  State<AtivosPage> createState() => _AtivosPageState();
}

class _AtivosPageState extends State<AtivosPage> {
  final repository = GetIt.I<AtivoRepository>(); 
  String _busca = "";
  
  static const Color azulFixo = Color(0xFF1A237E);

  void _confirmarExclusao(BuildContext context, Ativo ativo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir'),
        content: Text('Tem certeza que deseja excluir "${ativo.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              await repository.excluir(ativo.id);
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool podeEditar = widget.usuario.perfil == Perfil.administrador;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Ativos', 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: azulFixo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar...',
                    prefixIcon: const Icon(Icons.search, color: azulFixo),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: isDark ? Colors.white10 : Colors.white,
                  ),
                  onChanged: (value) => setState(() => _busca = value.toLowerCase()),
                ),
              ),
              
              Expanded(
                child: FutureBuilder<List<Ativo>>(
                  future: repository.buscarTodos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: azulFixo));
                    }
                    if (snapshot.hasError) return const Center(child: Text("Erro ao carregar ativos."));
                    
                    final listaFiltrada = (snapshot.data ?? []).where((a) => 
                      a.nome.toLowerCase().contains(_busca) || a.patrimonio.toLowerCase().contains(_busca)
                    ).toList();

                    if (listaFiltrada.isEmpty) return const Center(child: Text("Nenhum ativo encontrado."));

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: listaFiltrada.length,
                      itemBuilder: (context, index) {
                        final ativo = listaFiltrada[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: podeEditar ? () async {
                              await Navigator.push(context, MaterialPageRoute(
                                builder: (_) => AtivoFormPage(usuario: widget.usuario, ativo: ativo)
                              ));
                              setState(() {}); 
                            } : null,
                            leading: CircleAvatar(
                              backgroundColor: azulFixo.withOpacity(0.1),
                              child: const Icon(Icons.computer, color: azulFixo),
                            ),
                            title: Text(ativo.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Patrimônio: ${ativo.patrimonio} | Local: ${ativo.localizacao}"),
                            trailing: podeEditar ? IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _confirmarExclusao(context, ativo),
                            ) : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: podeEditar ? FloatingActionButton(
        backgroundColor: azulFixo,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AtivoFormPage(usuario: widget.usuario)));
          setState(() {});
        },
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }
}