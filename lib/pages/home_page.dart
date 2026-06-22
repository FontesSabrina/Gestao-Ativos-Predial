import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/chamado.dart';
import '../../domain/entities/notificacao.dart';
import '../../domain/repositories/chamado_repository.dart';
import '../../domain/repositories/notificacao_repository.dart';
import '../../domain/repositories/estoque_repository.dart';
import '../../pages/usuarios/cadastro_usuario_page.dart';
import '../../pages/ambiente/lista_ambientes_page.dart';
import '../../pages/manutencao/minhas_ordens_page.dart';
import '../../core/theme/theme_controller.dart';
import '../../main.dart';
import '../../pages/usuarios/lista_usuarios_page.dart';
import '../../../routes.dart';

class HomePage extends StatefulWidget {
  final Usuario usuario;
  const HomePage({super.key, required this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color primaryColor = Color(0xFF1A237E);
  
  late ChamadoRepository _chamadoRepository;
  late NotificacaoRepository _notificacaoRepository;
  late EstoqueRepository _estoqueRepository;

  List<Chamado> _listaChamados = [];
  List<Notificacao> _notificacoes = [];
  int _estoqueCriticoCount = 0;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _chamadoRepository = GetIt.I<ChamadoRepository>(); 
    _notificacaoRepository = GetIt.I<NotificacaoRepository>();
    _estoqueRepository = GetIt.I<EstoqueRepository>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDadosDoSistema();
    });
  }

  void _carregarDadosDoSistema() async {
    if (!mounted) return;
    setState(() => _carregando = true);

    try {
      final todos = await _chamadoRepository.buscarTodos();
      final avisos = await _notificacaoRepository.buscarNotificacoesDoUsuario(widget.usuario.id);
      final itensCriticos = await _estoqueRepository.buscarItensAbaixoDoMinimo();

      if (mounted) {
        setState(() {
          _listaChamados = todos;
          _notificacoes = avisos;
          _estoqueCriticoCount = itensCriticos.length;
          _carregando = false;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int pendentes = _listaChamados.where((c) => c.status == StatusChamado.aberto).length;
    int naoLidas = _notificacoes.where((n) => !n.lida).length;

    bool isAdmin = widget.usuario.perfil == Perfil.administrador;
    bool isTecnico = widget.usuario.perfil == Perfil.tecnicoResponsavel;
    bool isSolicitante = widget.usuario.perfil == Perfil.solicitante;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('AURA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor)),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: "Diminuir fonte",
            onPressed: () => setState(() => fontScaleNotifier.value = (fontScaleNotifier.value - 0.1).clamp(0.8, 2.0)),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Aumentar fonte",
            onPressed: () => setState(() => fontScaleNotifier.value = (fontScaleNotifier.value + 0.1).clamp(0.8, 2.0)),
          ),
          IconButton(
            icon: Icon(GetIt.I<ThemeController>().themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => setState(() => GetIt.I<ThemeController>().toggleTheme()),
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none),
                if (naoLidas > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text("$naoLidas", style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notificacoes, arguments: widget.usuario).then((_) => _carregarDadosDoSistema()),
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _buildConteudoPrincipal(pendentes, isAdmin, isTecnico, isSolicitante),
    );
  }

  Widget _buildConteudoPrincipal(int pendentes, bool isAdmin, bool isTecnico, bool isSolicitante) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.usuario.nome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(widget.usuario.perfil.name.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text("Serviços Disponíveis", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              if (isAdmin) ...[
                _buildCardServico("Gestão de Ativos", "Consulte equipamentos e locais", Icons.domain_rounded, Colors.blue.shade700, Colors.blue.shade50, () => Navigator.pushNamed(context, AppRoutes.ativos, arguments: widget.usuario)),
                _buildCardServico("Gerenciamento de Chamados", "Análise e aprovação", Icons.confirmation_number_outlined, Colors.amber.shade800, Colors.amber.shade50, () => Navigator.pushNamed(context, AppRoutes.chamados, arguments: widget.usuario).then((_) => _carregarDadosDoSistema()), badgeCount: pendentes),
                _buildCardServico("Ordens de Serviço", "Acompanhe em tempo real", Icons.construction_rounded, Colors.green.shade700, Colors.green.shade50, () => Navigator.pushNamed(context, AppRoutes.ordensServico, arguments: widget.usuario)),
                _buildCardServico("Manutenção Preventiva", "Calendário e alertas", Icons.calendar_today_rounded, Colors.teal.shade700, Colors.teal.shade50, () => Navigator.pushNamed(context, AppRoutes.planejamentoPreventivas, arguments: widget.usuario)),
                _buildCardServico("Estoque e Peças", "Níveis mínimos e fornecedores", Icons.inventory_2_outlined, Colors.orange.shade700, Colors.orange.shade50, () => Navigator.pushNamed(context, AppRoutes.estoque, arguments: widget.usuario).then((_) => _carregarDadosDoSistema()), badgeCount: _estoqueCriticoCount),
                _buildCardServico("Indicadores e BI", "Custo e eficiência", Icons.insights_rounded, Colors.purple.shade700, Colors.purple.shade50, () => Navigator.pushNamed(context, AppRoutes.indicadores, arguments: widget.usuario)),
                _buildCardServico("Cadastro de Usuários", "Gerenciar acessos", Icons.person_add_alt_1, Colors.lime.shade800, Colors.lime.shade50, () => Navigator.pushNamed(context, AppRoutes.usuarios, arguments: widget.usuario)),
                _buildCardServico("Ambientes", "Lista de locais e cadastros", Icons.list_alt, Colors.pink.shade700, Colors.pink.shade50, () => Navigator.pushNamed(context, AppRoutes.listaAmbientes)),
              ],
              
              if (isTecnico) ...[
                _buildCardServico("Minhas Ordens", "Tarefas atribuídas a você", Icons.assignment_ind_rounded, Colors.indigo.shade700, Colors.indigo.shade50, () => Navigator.push(context, MaterialPageRoute(builder: (_) => MinhasOrdensPage(usuarioLogado: widget.usuario)))),
                _buildCardServico("Gerenciamento de Chamados", "Análise e resolução", Icons.confirmation_number_outlined, Colors.amber.shade800, Colors.amber.shade50, () => Navigator.pushNamed(context, AppRoutes.chamados, arguments: widget.usuario).then((_) => _carregarDadosDoSistema()), badgeCount: pendentes),
                _buildCardServico("Consulta de Estoque", "Verificar disponibilidade", Icons.inventory_2_outlined, Colors.orange.shade700, Colors.orange.shade50, () => Navigator.pushNamed(context, AppRoutes.estoque, arguments: widget.usuario)),
              ],

              if (isSolicitante) ...[
                _buildCardServico("Abrir Chamado", "Reportar problemas", Icons.add_circle_outline, Colors.blue.shade700, Colors.blue.shade50, () => Navigator.pushNamed(context, AppRoutes.abrirChamado, arguments: widget.usuario)),
                _buildCardServico("Meus Chamados", "Acompanhe seus pedidos", Icons.list_alt, Colors.green.shade700, Colors.green.shade50, () => Navigator.pushNamed(context, AppRoutes.meusChamados, arguments: widget.usuario)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardServico(String title, String subtitle, IconData icon, Color iconColor, Color backgroundColor, VoidCallback onTap, {int badgeCount = 0}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: backgroundColor, child: Icon(icon, color: iconColor)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeCount > 0)
              Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle), child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}