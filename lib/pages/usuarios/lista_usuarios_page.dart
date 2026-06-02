import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';
import 'cadastro_usuario_page.dart';

class ListaUsuariosPage extends StatefulWidget {
  const ListaUsuariosPage({super.key});

  @override
  State<ListaUsuariosPage> createState() => _ListaUsuariosPageState();
}

class _ListaUsuariosPageState extends State<ListaUsuariosPage> {
  final _repository = GetIt.I<UsuarioRepository>();
  List<Usuario> _usuarios = [];
  List<Usuario> _usuariosFiltrados = [];
  String _busca = "";
  Perfil? _filtroPerfil;
  
  static const Color azulFixo = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final lista = await _repository.buscarTodos();
    setState(() {
      _usuarios = lista;
      _filtrar();
    });
  }

  void _filtrar() {
    setState(() {
      _usuariosFiltrados = _usuarios.where((u) {
        final matchBusca = u.nome.toLowerCase().contains(_busca.toLowerCase()) || 
                           u.email.toLowerCase().contains(_busca.toLowerCase());
        final matchPerfil = _filtroPerfil == null || u.perfil == _filtroPerfil;
        return matchBusca && matchPerfil;
      }).toList();
    });
  }

  Future<void> _excluir(Usuario usuario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Usuário"),
        content: Text("Deseja realmente excluir ${usuario.nome}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Excluir", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.excluir(usuario.id);
      _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestão de Usuários", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: azulFixo,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // Garante que a seta de voltar seja branca
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: azulFixo,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastroUsuarioPage()));
          _carregar();
        },
        child: const Icon(Icons.add, color: Colors.white), // Ícone forçado branco
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Pesquisar por nome ou e-mail", 
                        prefixIcon: Icon(Icons.search, color: azulFixo), 
                        border: OutlineInputBorder()
                      ),
                      onChanged: (v) { _busca = v; _filtrar(); },
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(label: const Text("Todos"), selected: _filtroPerfil == null, onSelected: (_) { _filtroPerfil = null; _filtrar(); }),
                        ...Perfil.values.map((p) => FilterChip(
                          label: Text(p.name.toUpperCase()),
                          selected: _filtroPerfil == p,
                          onSelected: (_) { _filtroPerfil = p; _filtrar(); },
                        ))
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _usuariosFiltrados.length,
                  itemBuilder: (context, i) {
                    final u = _usuariosFiltrados[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: azulFixo.withOpacity(0.1), child: Icon(Icons.person, color: azulFixo)),
                        title: Text(u.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Perfil: ${u.perfil.name.toUpperCase()} | ${u.email}"),
                        // Forçando a lixeira a ser vermelha e visível
                        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _excluir(u)),
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => CadastroUsuarioPage(usuario: u)));
                          _carregar();
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