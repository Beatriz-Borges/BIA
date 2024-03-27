class BIAUser {
  final String id;
  final String name;
  final String email;
  final String tipo;
  final String tipoId;
  bool isCoordenadorExtensao;

  BIAUser({
    required this.id,
    required this.name,
    required this.email,
    required this.tipo,
    required this.tipoId,
    this.isCoordenadorExtensao = false,
  });

  static const tipoList = [
    'Professor',
    'Aluno',
  ];
}
