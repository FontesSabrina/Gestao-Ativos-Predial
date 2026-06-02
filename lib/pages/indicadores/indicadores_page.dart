import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/entities/ordem_servico.dart';
import '../../../domain/entities/ativo.dart';
import '../../../domain/services/ordem_servico_domain_services.dart';
import '../../../domain/repositories/ativo_repository.dart';

class IndicadoresPage extends StatefulWidget {
  const IndicadoresPage({super.key});

  @override
  State<IndicadoresPage> createState() => _IndicadoresPageState();
}

class _IndicadoresPageState extends State<IndicadoresPage> {
  final _osService = GetIt.I<OrdemServicoDomainServices>();
  final _ativoRepository = GetIt.I<AtivoRepository>();
  final Map<String, String> _nomesAtivosCache = {};

  Future<void> _gerarRelatorioPDF({
    required List<OrdemServico> todas,
    required double taxa,
    required double custo,
    required double tma,
  }) async {
    final pdf = pw.Document();
    for (var os in todas) {
      if (!_nomesAtivosCache.containsKey(os.ativoId)) {
        final ativo = await _ativoRepository.buscarPorId(os.ativoId);
        _nomesAtivosCache[os.ativoId] = ativo?.nome ?? "Ativo não identificado";
      }
    }
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF1A237E),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('AURA — SISTEMA DE GESTÃO', style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Relatório Gerencial de Indicadores de Manutenção', style: pw.TextStyle(color: PdfColors.grey300, fontSize: 10)),
                      ],
                    ),
                    pw.Text('BI & PERFORMANCE', style: pw.TextStyle(color: PdfColors.amber100, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Text('1. Resumo dos Indicadores Operacionais', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF1A237E))),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF3F51B5)),
                headers: ['Métrica Indicadora', 'Resultado Atual'],
                data: [
                  ['Taxa de Conclusão de OS', '${taxa.toStringAsFixed(1)}%'],
                  ['Custo Total Acumulado', 'R\$ ${custo.toStringAsFixed(2)}'],
                  ['Tempo Médio de Atendimento (TMA)', '${tma.toStringAsFixed(1)} horas'],
                  ['Total de Ordens Registradas', '${todas.length} ordens'],
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Text('2. Histórico de Ordens de Serviço Relatadas', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF1A237E))),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF455A64)),
                headers: ['Equipamento / Ativo', 'Problema Relatado', 'Prioridade', 'Status'],
                data: todas.map((os) {
                  return [
                    _nomesAtivosCache[os.ativoId] ?? 'Carregando...',
                    os.descricaoProblema,
                    os.prioridade,
                    os.status.toString().split('.').last.toUpperCase(),
                  ];
                }).toList(),
              ),
              pw.Spacer(),
              pw.Divider(color: PdfColors.grey400, thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Aura Sistema — Relatório de Auditoria Técnica', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                  pw.Text('Documento Gerado Automatizado', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                ],
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save(), name: 'relatorio_indicadores_aura.pdf');
  }

  Future<void> _prepararNomesAtivos(List<MapEntry<String, int>> dados) async {
    for (var entry in dados) {
      if (!_nomesAtivosCache.containsKey(entry.key)) {
        final ativo = await _ativoRepository.buscarPorId(entry.key);
        if (mounted) setState(() => _nomesAtivosCache[entry.key] = ativo?.nome ?? "Ativo Ocul.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.indigoAccent : const Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Painel de Indicadores e BI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A237E),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<OrdemServico>>(
        future: _osService.buscarTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final todasOrdens = snapshot.data ?? [];
          if (todasOrdens.isEmpty) return const Center(child: Text('Nenhum dado encontrado.', style: TextStyle(color: Colors.grey)));

          final ordensConcluidas = todasOrdens.where((os) => os.status == StatusOS.concluida).toList();
          final ordensEmAberto = todasOrdens.where((os) => os.status == StatusOS.aberta || os.status == StatusOS.emAndamento).toList();
          final taxaConclusao = todasOrdens.isNotEmpty ? (ordensConcluidas.length / todasOrdens.length) * 100 : 0.0;
          final custoTotal = ordensConcluidas.fold(0.0, (soma, os) => soma + os.custoPecas + os.custoMaoDeObra);
          final tma = ordensConcluidas.isNotEmpty ? (ordensConcluidas.fold(0.0, (soma, os) => soma + os.horasGastas) / ordensConcluidas.length) : 0.0;
          final Map<String, int> contagemFalhasPorAtivo = {};
          for (var os in todasOrdens) contagemFalhasPorAtivo[os.ativoId] = (contagemFalhasPorAtivo[os.ativoId] ?? 0) + 1;
          final ativosMaisCriticados = contagemFalhasPorAtivo.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
          final topAtivosGratico = ativosMaisCriticados.take(5).toList();
          _prepararNomesAtivos(topAtivosGratico);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Visão Geral Operacional", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                        ElevatedButton.icon(
                          onPressed: () => _gerarRelatorioPDF(todas: todasOrdens, taxa: taxaConclusao, custo: custoTotal, tma: tma),
                          icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 18),
                          label: const Text('Exportar PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.2,
                      children: [
                        _buildIndicatorCard(context, 'Taxa de Conclusão', '${taxaConclusao.toStringAsFixed(1)}%', Icons.pie_chart_rounded, Colors.blueAccent),
                        _buildIndicatorCard(context, 'Custo Total OS', 'R\$ ${custoTotal.toStringAsFixed(2)}', Icons.attach_money_rounded, Colors.green),
                        _buildIndicatorCard(context, 'TMA (Tempo Médio)', '${tma.toStringAsFixed(1)} h', Icons.hourglass_top_rounded, Colors.orangeAccent),
                        _buildIndicatorCard(context, 'Total de Registros', '${todasOrdens.length}', Icons.assignment_rounded, Colors.purpleAccent),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text("Análise e Custos Operacionais", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      color: theme.cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: theme.dividerColor)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [Icon(Icons.bar_chart_rounded, color: primaryColor, size: 22), const SizedBox(width: 8), const Text('Recorrência de Falhas por Ativo (Top 5)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]),
                            const Divider(height: 32),
                            topAtivosGratico.isEmpty ? const SizedBox(height: 200, child: Center(child: Text('Sem dados.', style: TextStyle(color: Colors.grey)))) : SizedBox(height: 250, child: BarChart(BarChartData(barGroups: topAtivosGratico.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.value.toDouble(), color: primaryColor, width: 22)])).toList()))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text("Resumo de Atividades Urgentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 0,
                      color: theme.cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.dividerColor)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(children: [Row(children: [const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20), const SizedBox(width: 8), Text('Ordens Pendentes (${ordensEmAberto.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]), const Divider(height: 20), ...ordensEmAberto.take(3).map((os) => ListTile(title: Text(os.descricaoProblema), trailing: Text(os.prioridade)))])),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndicatorCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.dividerColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(title, style: TextStyle(fontSize: 13, color: theme.hintColor, fontWeight: FontWeight.w600))), Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20))]),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }
}