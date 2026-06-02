import 'package:flutter/material.dart';
import '../domain/entities/usuario.dart';
import '../domain/entities/ativo.dart';

// Páginas
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/ativos/ativos_page.dart';
import 'pages/ativos/ativo_form_page.dart';
import 'pages/estoque/estoque_page.dart';
import 'pages/chamados/chamados_pendentes_page.dart';
import 'pages/chamados/abrir_chamado_page.dart';
import 'pages/manutencao/manutencoes_page.dart';
import 'pages/ordem_servico/ordens_servico_page.dart';
import 'pages/manutencao/planejamento_preventivas_page.dart'; 
import '../pages/manutencao/minhas_ordens_page.dart';
import 'pages/chamados/meus_chamados_page.dart';
import 'pages/manutencao/consumo_pecas_page.dart';
import 'pages/usuarios/lista_usuarios_page.dart';
import 'pages/usuarios/cadastro_usuario_page.dart'; 
import 'pages/ativos/cadastro_ambiente_page.dart';
import 'pages/notificacao/notificacoes_page.dart';
import 'pages/indicadores/indicadores_page.dart';

class AtivoFormArgs {
  final Usuario usuario;
  final Ativo? ativo;
  AtivoFormArgs({required this.usuario, this.ativo});
}

class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String ativos = '/ativos';
  static const String ativoForm = '/ativo-form';
  static const String estoque = '/estoque';
  static const String chamados = '/chamados';
  static const String abrirChamado = '/abrir-chamado';
  static const String indicadores = '/indicadores';
  static const String ordensServico = '/ordens-servico';
  static const String planejamentoPreventivas = '/planejamento-preventivas';
  static const String minhasOrdens = '/minhas-ordens';
  static const String meusChamados = '/meus-chamados';
  static const String consumoPecas = '/consumo-pecas';
  static const String usuarios = '/usuarios'; 
  static const String cadastroUsuario = '/cadastro-usuario';
  static const String cadastroAmbiente = '/cadastro-ambiente';
  static const String notificacoes = '/notificacoes';
  static const String manutencoes = '/manutencoes';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      home: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return args is Usuario ? HomePage(usuario: args) : const LoginPage();
      },
      ativos: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return args is Usuario ? AtivosPage(usuario: args) : const LoginPage();
      },
      estoque: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return args is Usuario ? EstoquePage(usuario: args) : const LoginPage();
      },
      chamados: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return args is Usuario ? ChamadosPendentesPage(usuario: args) : const LoginPage();
      },
      abrirChamado: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return args is Usuario ? AbrirChamadoPage(usuario: args) : const LoginPage();
      },
      ordensServico: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return args is Usuario ? OrdensServicoPage(usuario: args) : const LoginPage();
      },
      ativoForm: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Usuario) return AtivoFormPage(usuario: args);
        if (args is AtivoFormArgs) return AtivoFormPage(usuario: args.usuario, ativo: args.ativo);
        return const LoginPage();
      },
      planejamentoPreventivas: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return args is Usuario ? PlanejamentoPreventivasPage(usuario: args) : const LoginPage();
      },
      minhasOrdens: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return args is Usuario ? MinhasOrdensPage(usuarioLogado: args) : const LoginPage();
      },
      meusChamados: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return args is Usuario ? MeusChamadosPage(usuarioLogado: args) : const LoginPage();
      },
      consumoPecas: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return args is String ? ConsumoPecasPage(ordemServicoId: args) : const LoginPage();
      },
      notificacoes: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return args is Usuario ? NotificacoesPage(usuario: args) : const LoginPage();
      },
      indicadores: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return args is Usuario ? IndicadoresPage(usuario: args) : const LoginPage();
      },
      usuarios: (context) => const ListaUsuariosPage(),
      cadastroUsuario: (context) => const CadastroUsuarioPage(),
      cadastroAmbiente: (context) => const CadastroAmbientePage(),
      manutencoes: (context) => const ManutencoesPage(),
    };
  }
}