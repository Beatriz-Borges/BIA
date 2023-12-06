import 'dart:convert';

import 'package:bia/model/models/aluno.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// the provider that handles the changes to alunos

class AlunoList with ChangeNotifier {
  final List<Aluno> _items = [];
  late List<Aluno> _filteredItems = _items;

  static Set<String> matriculas = {};

  // returns a copy of _items so that it can't be changed outside the provider
  List<Aluno> get items => [..._items];

  List<Aluno> get filteredItems => [..._filteredItems];
  int get itemsCount => _items.length;

  // function to get the alunos from the database and saves them in _items
  Future<void> loadAlunos() async {
    _items.clear();

    final response = await http.get(
      Uri.parse('${Constants.alunos}.json'),
    );

    if (response.body == 'null') return;

    matriculas.clear();

    final data = jsonDecode(response.body);
    final user = AuthService().currentUser!;
    List<String> vagas = [];
    String? coordenaCurso;
    if (['Professor'].contains(user.tipo) && !user.isCoordenadorExtensao) {
      final response = await http
          .get(Uri.parse('${Constants.professores}/${user.tipoId}.json'));

      final professor = jsonDecode(response.body);
      if (professor != null) {
        if (professor['vagasId'] != null) {
          vagas = professor['vagasId'].cast<String>();
        }
        if (professor['cursoId'] != null) {
          coordenaCurso = professor['cursoId'];
        }
      }
      data.forEach((alunoId, alunoData) {
        if (vagas.contains(alunoData['vagaId']) ||
            coordenaCurso == alunoData['cursoId']) {
          // if the user is a professor it will add the alunos linked to
          // the same vaga as them, and if the user is coordenador de curso
          // it will add the alunos of the same curso
          _items.insert(
            0,
            Aluno(
              id: alunoId,
              nome: alunoData['nome'],
              email: alunoData['email'],
              matricula: alunoData['matricula'],
              telefone: alunoData['telefone'],
              cursoId: alunoData['cursoId'],
              eCurricular: alunoData['eCurricular'],
              eExtraCurricular: alunoData['eExtraCurricular'],
              vagaId: alunoData['vagaId'],
            ),
          );
          matriculas.add(alunoData['matricula']);
        }
      });
    } else if (['Aluno'].contains(user.tipo)) {
      data.forEach((alunoId, alunoData) {
        if (alunoId == user.tipoId) {
          // if the user is an aluno it will add himself to the list
          _items.insert(
            0,
            Aluno(
              id: alunoId,
              nome: alunoData['nome'],
              email: alunoData['email'],
              matricula: alunoData['matricula'],
              telefone: alunoData['telefone'],
              cursoId: alunoData['cursoId'],
              eCurricular: alunoData['eCurricular'],
              eExtraCurricular: alunoData['eExtraCurricular'],
              vagaId: alunoData['vagaId'],
            ),
          );
          matriculas.add(alunoData['matricula']);
        }
      });
    } else if (['CGTI'].contains(user.tipo) || user.isCoordenadorExtensao) {
      data.forEach((alunoId, alunoData) {
        // if the user is CGTI or the coordenador de extensão it will add
        // all alunos
        _items.insert(
          0,
          Aluno(
            id: alunoId,
            nome: alunoData['nome'],
            email: alunoData['email'],
            matricula: alunoData['matricula'],
            telefone: alunoData['telefone'],
            cursoId: alunoData['cursoId'],
            eCurricular: alunoData['eCurricular'],
            eExtraCurricular: alunoData['eExtraCurricular'],
            vagaId: alunoData['vagaId'],
          ),
        );
        matriculas.add(alunoData['matricula']);
      });
    }

    _filteredItems = _items;
    notifyListeners();
  }

  // filter the _items to show only the relevant items
  void filterItems({
    String name = '',
    bool alfabetico = false,
    bool prioridade = false,
    bool disponivel = false,
    bool curricular = false,
    bool extra = false,
    String? cursoId,
    List<String>? interessados,
  }) {
    _filteredItems = _items.where(
      (aluno) {
        return aluno.nome.toLowerCase().contains(name.toLowerCase());
      },
    ).toList();

    if (cursoId != null) {
      _filteredItems = _filteredItems.where(
        (aluno) {
          return aluno.cursoId == cursoId;
        },
      ).toList();
    }

    if (disponivel) {
      _filteredItems = filteredItems.where(
        (aluno) {
          final bool isDisponivel = aluno.vagaId == null;
          final bool isPendente =
              aluno.eCurricular == false || aluno.eExtraCurricular == false;
          return isDisponivel && isPendente;
        },
      ).toList();
    }

    if (curricular) {
      _filteredItems = _filteredItems
          .where(
            (aluno) => aluno.eCurricular == false,
          )
          .toList();
    }

    if (extra) {
      _filteredItems = _filteredItems
          .where(
            (aluno) => aluno.eExtraCurricular == false,
          )
          .toList();
    }

    if (alfabetico) {
      _filteredItems.sort(
        (a, b) {
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        },
      );
    }
    if (prioridade) {
      _filteredItems.sort(
        (a, b) {
          return b.prioridadeInt.compareTo(a.prioridadeInt);
        },
      );
    }
    if (interessados != null) {
      _filteredItems = _filteredItems
          .where((aluno) => interessados.contains(aluno.id))
          .toList();
    }

    notifyListeners();
  }

  bool filteredListHasAluno(String? matricula) {
    if (matricula == null) {
      return false;
    }

    for (var aluno in filteredItems) {
      if (aluno.matricula == matricula) {
        return true;
      }
    }

    return false;
  }

  // add a vaga id to the aluno
  Future<void> vinculaVaga(String id, String vaga) async {
    await http.patch(
      Uri.parse('${Constants.alunos}/$id.json'),
      body: jsonEncode({
        'vagaId': vaga,
      }),
    );

    _filteredItems = _items;
    // await loadAlunos();
    // await loadAlunos();
    notifyListeners();
  }

  // removes vaga id from the aluno
  Future<void> desvinculaVaga(String id) async {
    await http.patch(
      Uri.parse('${Constants.alunos}/$id.json'),
      body: jsonEncode({
        'vagaId': null,
      }),
    );

    await loadAlunos();
    await loadAlunos();
    notifyListeners();
  }

  // adds a new aluno to the database from the create screen
  Future<void> addAlunoFromData(Map<String, Object> data) async {
    final response = await http.post(
      Uri.parse('${Constants.alunos}.json'),
      body: jsonEncode({
        'nome': data['nome'] as String,
        'email': data['email'] as String,
        'matricula': data['matricula'] as String,
        'telefone': data['telefone'] as String,
        'cursoId': data['cursoId'] as String,
        'eCurricular': data['eCurricular'] as bool? ?? false,
        'eExtraCurricular': data['eExtraCurricular'] as bool? ?? false,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    matriculas.add(data['matriculas'] as String);

    await loadAlunos();
    await loadAlunos();
    notifyListeners();
  }

  // updates an aluno on the database from the update screen
  Future<void> update(Map<String, Object> data) async {
    final response = await http.patch(
      Uri.parse('${Constants.alunos}/${data["id"]}.json'),
      body: jsonEncode({
        'nome': data['nome'] as String,
        'email': data['email'] as String,
        'matricula': data['matricula'] as String,
        'telefone': data['telefone'] as String,
        'cursoId': data['cursoId'] as String,
        'eCurricular': data['eCurricular'] as bool? ?? false,
        'eExtraCurricular': data['eExtraCurricular'] as bool? ?? false,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadAlunos();
    await loadAlunos();
    notifyListeners();
  }

  // removes an aluno from the database
  Future<void> delete(String id) async {
    final response = await http.delete(
      Uri.parse('${Constants.alunos}/$id.json'),
    );

    if (response.statusCode.toString()[0] != '2') return;

    matriculas.remove(_items.firstWhere((aluno) => aluno.id == id).matricula);
    _items.removeWhere((aluno) => aluno.id == id);
    _filteredItems.removeWhere((aluno) => aluno.id == id);
    notifyListeners();
  }

  // returns an aluno from an id
  Aluno? getAluno(String? id) {
    if (id == null) return null;
    int index = _items.indexWhere((aluno) => aluno.id == id);
    return index == -1 ? null : _items[index];
  }
}
