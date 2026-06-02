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
  
  // Definindo a cor azul fixa do seu sistema
  static const Color azulFixo = Color(0xFF1A237E);

  void _confirmarExclusao(BuildContext context, Ativo ativo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Ativo'),
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
            child: const Text('EXCLUIR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool podeEditar = widget.usuario.perfil == Perfil.administrador;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Gestão de Ativos', 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: azulFixo, // Azul fixo no cabeçalho
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar por nome ou patrimônio...',
                    prefixIcon: const Icon(Icons.search, color: azulFixo), // Azul fixo
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() => _busca = value.toLowerCase()),
                ),
              ),
              
              Expanded(
                child: FutureBuilder<List<Ativo>>(
                  future: repository.buscarTodos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) return const Center(child: Text("Erro ao carregar ativos."));
                    
                    final listaFiltrada = (snapshot.data ?? []).where((a) => 
                      a.nome.toLowerCase().contains(_busca) || a.patrimonio.toLowerCase().contains(_busca)
                    ).toList();

                    if (listaFiltrada.isEmpty) return const Center(child: Text("Nenhum ativo encontrado."));

                    return ListView.builder(
                      itemCount: listaFiltrada.length,
                      itemBuilder: (context, index) {
                        final ativo = listaFiltrada[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          child: ListTile(
                            onTap: podeEditar ? () async {
                              await Navigator.push(context, MaterialPageRoute(
                                builder: (_) => AtivoFormPage(usuario: widget.usuario, ativo: ativo)
                              ));
                              setState(() {}); 
                            } : null,
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFE8EAF6), // Mantém o tom claro do azul
                              child: Icon(Icons.computer, color: azulFixo), // Azul fixo
                            ),
                            title: Text(ativo.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Patrimônio: ${ativo.patrimonio}\nLocal: ${ativo.localizacao}"),
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
        backgroundColor: azulFixo, // Azul fixo no botão
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AtivoFormPage(usuario: widget.usuario)));
          setState(() {});
        },
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }
}