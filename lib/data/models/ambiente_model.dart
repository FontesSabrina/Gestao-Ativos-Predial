import '../../domain/entities/ambiente.dart';

class AmbienteModel extends Ambiente {
  AmbienteModel({
    required super.id,
    required super.nome,
    required super.predio,
    required super.andar,
    required super.observacoes,
  });

  factory AmbienteModel.fromMap(Map<String, dynamic> map) {
    return AmbienteModel(
      id: map['id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      predio: map['predio']?.toString() ?? '',
      andar: map['andar']?.toString() ?? '',
      observacoes: map['observacoes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'predio': predio,
      'andar': andar,
      'observacoes': observacoes,
    };
  }
}