class Ambiente {
  final String id;
  final String nome;
  final String predio;
  final String andar;
  final String observacoes;

  Ambiente({required this.id, required this.nome, required this.predio, required this.andar, required this.observacoes});

  Map<String, dynamic> toMap() => {
    'id': id, 'nome': nome, 'predio': predio, 'andar': andar, 'observacoes': observacoes
  };

  factory Ambiente.fromMap(Map<String, dynamic> map) => Ambiente(
    id: map['id'], nome: map['nome'], predio: map['predio'], andar: map['andar'], observacoes: map['observacoes']
  );
}