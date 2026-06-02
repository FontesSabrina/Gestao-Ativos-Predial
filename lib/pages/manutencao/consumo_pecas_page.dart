import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/entities/item_estoque.dart';
import '../../../domain/repositories/estoque_repository.dart';

class ConsumoPecasPage extends StatefulWidget {
  final String ordemServicoId;
  const ConsumoPecasPage({super.key, required this.ordemServicoId});

  @override
  State<ConsumoPecasPage> createState() => _ConsumoPecasPageState();
}

class _ConsumoPecasPageState extends State<ConsumoPecasPage> {
  static const Color primaryColor = Color(0xFF1A237E);
  
  final _qtyController = TextEditingController();
  final _repository = GetIt.I<EstoqueRepository>();
  late Future<List<ItemEstoque>> _futureItens;
  ItemEstoque? _itemSelecionado;

  @override
  void initState() {
    super.initState();
    _futureItens = _repository.buscarTodos();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _registrarConsumo() async {
    if (_itemSelecionado == null || _qtyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione um item e informe a quantidade!")),
      );
      return;
    }

    final qtdUsada = int.tryParse(_qtyController.text) ?? 0;
    
    if (qtdUsada <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quantidade inválida!"))
      );
      return;
    }

    if (qtdUsada > _itemSelecionado!.quantidade) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quantidade indisponível em estoque!"))
      );
      return;
    }

    final novoItem = _itemSelecionado!.copyWith(
      quantidade: _itemSelecionado!.quantidade - qtdUsada
    );
    
    await _repository.salvar(novoItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Baixa realizada com sucesso!"))
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Consumo de Peças"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<List<ItemEstoque>>(
        future: _futureItens,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          
          if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar estoque: ${snapshot.error}"));
          }

          final itens = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                DropdownButtonFormField<ItemEstoque>(
                  decoration: const InputDecoration(
                    labelText: "Selecione a peça", 
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)
                  ),
                  isExpanded: true,
                  value: _itemSelecionado,
                  items: itens.map((i) => DropdownMenuItem(
                    value: i, 
                    child: Text("${i.nome} (Disp: ${i.quantidade})")
                  )).toList(),
                  onChanged: (v) => setState(() => _itemSelecionado = v),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _qtyController,
                  decoration: const InputDecoration(
                    labelText: "Quantidade a consumir", 
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    onPressed: _registrarConsumo,
                    child: const Text(
                      "CONFIRMAR CONSUMO", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}