class Professor {
  final String id;
  final String nome;
  final String siap;
  final String telefone;
  final String email;
  String? cursoId;
  List<String> vagasId;
  bool isCoordenadorExtensao;

  Professor({
    required this.id,
    required this.nome,
    required this.siap,
    required this.telefone,
    required this.email,
    this.cursoId,
    this.isCoordenadorExtensao = false,
    required this.vagasId,
  });
}
