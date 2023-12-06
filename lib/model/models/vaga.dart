class Vaga {
  final String id;
  final String funcao;
  final String concedenteId;
  final String cursoId;
  final double remuneracao;
  final String descricao;
  final bool curricular;
  String? alunoId;
  String? professorId;
  List<String> interessados;

  Vaga({
    required this.id,
    required this.funcao,
    required this.concedenteId,
    required this.cursoId,
    required this.remuneracao,
    this.descricao = '',
    required this.curricular,
    this.alunoId,
    this.professorId,
    required this.interessados,
  });
}
