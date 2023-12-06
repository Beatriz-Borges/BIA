class Aluno {
  final String id;
  final String nome;
  final String matricula;
  final String telefone;
  final String email;
  final String cursoId;
  final bool eCurricular;
  final bool eExtraCurricular;
  String? vagaId;

  Aluno({
    required this.id,
    required this.nome,
    required this.matricula,
    this.telefone = '',
    required this.email,
    required this.cursoId,
    required this.eCurricular,
    required this.eExtraCurricular,
    this.vagaId,
  });

  int get ano {
    return int.parse(matricula.substring(0, 4));
  }

  int get semestre {
    return int.parse(matricula[4]);
  }

  String get anoSemestre {
    return '$ano.$semestre';
  }

  int get prioridadeInt {
    int anoAtual = 2023;
    int semestreAtual = 1;

    int points = 0;

    points = (anoAtual - ano) * 2 + semestreAtual - semestre - 2;
    //5 * 2 + 1 - 1 - 2
    //10 + 0 - 2
    // 8
    //
    int result = points;

    if (points < 0 || eCurricular) {
      result = 0;
    } else if (points > 3) {
      result = 3;
    }

    return result;
  }

  String get prioridade {
    int points = prioridadeInt;

    String prioridade = '-';
    if (points == 0) {
      prioridade = '-';
    } else if (points == 1) {
      prioridade = 'baixa';
    } else if (points == 2) {
      prioridade = 'média';
    } else if (points == 3) {
      prioridade = 'alta';
    }

    return prioridade;
  }
}
