import 'package:meta/meta.dart';
import 'item_estoque.dart';

enum StatusOS { aberta, emAndamento, concluida, cancelada }

@immutable
class OrdemServico {
  final String id;
  final String ativoId;
  final String solicitanteId;
  final String descricaoProblema;
  final DateTime dataAbertura;
  final String prioridade;
  final String? tecnicoResponsavelId;
  final StatusOS status;
  
  final String? relatotecnico;
  final DateTime? dataInicio;         
  final DateTime? dataFim;            
  final double custoPecas;            
  final double custoMaoDeObra;        
  
  final List<ItemEstoque> pecasUtilizadas;
  
  final DateTime? dataAprovacao;      
  final String? aprovadorId;          

  const OrdemServico({
    required this.id,
    required this.ativoId,
    required this.solicitanteId,
    required this.descricaoProblema,
    required this.dataAbertura,
    required this.prioridade,
    this.tecnicoResponsavelId,
    this.status = StatusOS.aberta,    
    this.relatotecnico,
    this.dataInicio,
    this.dataFim,
    this.custoPecas = 0.0,            
    this.custoMaoDeObra = 0.0,        
    this.pecasUtilizadas = const [],  
    this.dataAprovacao,
    this.aprovadorId,
  });

  OrdemServico copyWith({
    String? id,
    String? ativoId,
    String? solicitanteId,
    String? descricaoProblema,
    DateTime? dataAbertura,
    String? prioridade,
    String? tecnicoResponsavelId,
    StatusOS? status,
    String? relatotecnico,
    DateTime? dataInicio,
    DateTime? dataFim,
    double? custoPecas,
    double? custoMaoDeObra,
    List<ItemEstoque>? pecasUtilizadas,
    DateTime? dataAprovacao,
    String? aprovadorId,
  }) {
    return OrdemServico(
      id: id ?? this.id,
      ativoId: ativoId ?? this.ativoId,
      solicitanteId: solicitanteId ?? this.solicitanteId,
      descricaoProblema: descricaoProblema ?? this.descricaoProblema,
      dataAbertura: dataAbertura ?? this.dataAbertura,
      prioridade: prioridade ?? this.prioridade,
      tecnicoResponsavelId: tecnicoResponsavelId ?? this.tecnicoResponsavelId,
      status: status ?? this.status,
      relatotecnico: relatotecnico ?? this.relatotecnico,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      custoPecas: custoPecas ?? this.custoPecas,
      custoMaoDeObra: custoMaoDeObra ?? this.custoMaoDeObra,
      pecasUtilizadas: pecasUtilizadas ?? this.pecasUtilizadas,
      dataAprovacao: dataAprovacao ?? this.dataAprovacao,
      aprovadorId: aprovadorId ?? this.aprovadorId,
    );
  }

  double get horasGastas {
    if (dataInicio != null && dataFim != null) {
      final diferenca = dataFim!.difference(dataInicio!);
      return diferenca.inMinutes / 60.0; 
    }
    return 0.0; 
  }
}