import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/ambiente.dart';
import '../../domain/repositories/ambiente_repository.dart';
import 'cadastro_ambiente_page.dart';

class ListaAmbientesPage extends StatefulWidget {
  const ListaAmbientesPage({super.key});

  @override
  State<ListaAmbientesPage> createState() => _ListaAmbientesPageState();
}

class _ListaAmbientesPageState extends State<ListaAmbientesPage> {
  final _ambienteRepository = GetIt.I<AmbienteRepository>();
  List<Ambiente> _ambientes = [];
  List<Ambiente> _filtro = [];
  final TextEditingController _searchController = TextEditingController();
  
  static const Color azulFixo = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  // Carrega os dados do repositório
  Future<void> _carregar() async {
    final lista = await _ambienteRepository.buscarTodos();
    if (mounted) {
      setState(() {
        _ambientes = lista;
        _filtro = lista;
      });
    }
  }

  void _filtrar(String query) {
    setState(() {
      _filtro = _ambientes.where((a) => 
        a.nome.toLowerCase().contains(query.toLowerCase()) || 
        a.predio.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  Future<void> _excluir(Ambiente ambiente) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Ambiente"),
        content: Text("Deseja realmente excluir ${ambiente.nome}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Excluir", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _ambienteRepository.excluir(ambiente.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Ambiente excluído com sucesso!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _carregar();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Erro ao excluir ambiente."),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestão de Ambientes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: azulFixo,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: azulFixo,
        onPressed: () async {
          // Navega para cadastro (sem passar ambiente)
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastroAmbientePage()));
          _carregar(); // Atualiza a lista ao voltar
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filtrar,
                  decoration: const InputDecoration(
                    labelText: "Buscar...",
                    prefixIcon: Icon(Icons.search, color: azulFixo),
                    border: OutlineInputBorder()
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filtro.length,
                  itemBuilder: (context, index) {
                    final ambiente = _filtro[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: azulFixo.withOpacity(0.1), 
                          child: const Icon(Icons.business, color: azulFixo)
                        ),
                        title: Text(ambiente.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${ambiente.predio} | Andar: ${ambiente.andar}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _excluir(ambiente),
                        ),
                        onTap: () async {
                          // Navega para edição (passando o ambiente)
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => CadastroAmbientePage(ambiente: ambiente)));
                          _carregar(); // Recarrega a lista para mostrar a edição
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}