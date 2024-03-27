class Curso {
  final String id;
  final String nome;
  final String sigla;
  final String nivel;
  String? coordenadorId;

  Curso({
    required this.id,
    required this.nome,
    required this.sigla,
    required this.nivel,
    this.coordenadorId,
  });

  static List<String> niveis = [
    'Superior',
    'Integrado',
    'Proeja',
  ];
}
