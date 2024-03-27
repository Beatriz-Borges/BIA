import 'dart:convert';

import 'package:bia/model/models/professor.dart';
import 'package:bia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// the provider that handles the changes to professores

class ProfessorList with ChangeNotifier {
  final List<Professor> _items = [];

  static Set<String> siaps = {};
  late List<Professor> _filteredItems = _items;

  // returns a copy of _items so that it can't be changed outside the provider
  List<Professor> get items => [..._items];

  List<Professor> get filteredItems => [..._filteredItems];
  int get itemsCount => _items.length;
  static String cExtensaoId = '';

  // function to get the professores from the database and saves them in _items
  Future<void> loadProfessores() async {
    _items.clear();
    siaps.clear();

    // gets the id of the coordenador de extensão
    cExtensaoId = await getCoordenadorExtensao();

    final response = await http.get(
      Uri.parse('${Constants.professores}.json'),
    );

    if (response.body == 'null') return;

    final data = jsonDecode(response.body);
    data.forEach((professorId, professorData) {
      _items.insert(
        0,
        Professor(
          id: professorId,
          nome: professorData['nome'],
          email: professorData['email'],
          telefone: professorData['telefone'],
          siap: professorData['siap'],
          cursoId: professorData['cursoId'],
          vagasId: professorData['vagasId'] != null
              ? professorData['vagasId'].cast<String>()
              : <String>[],
          // sets as coordenador de extensão if the id is the
          // same as cExtensaoId
          isCoordenadorExtensao: professorId == cExtensaoId,
        ),
      );
      siaps.add(professorData['siap']);
    });

    _filteredItems = _items;
    notifyListeners();
  }

  // filter the _items to show only the relevant items
  void filterItems({
    String name = '',
    bool alfabetico = false,
    bool? disponivel,
  }) {
    _filteredItems = _items.where(
      (professor) {
        return professor.nome.toLowerCase().contains(name.toLowerCase());
      },
    ).toList();

    if (disponivel == true) {
      _filteredItems = _filteredItems.where(
        (professor) {
          return professor.cursoId == null;
        },
      ).toList();
    }

    if (alfabetico) {
      _filteredItems.sort(
        (a, b) {
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        },
      );
    }

    notifyListeners();
  }

  bool filteredListHasprofessor(String? siap) {
    if (siap == null) {
      return false;
    }

    for (var professor in filteredItems) {
      if (professor.siap == siap) {
        return true;
      }
    }

    return false;
  }

  // adds the id of a curso to a professor
  Future<void> vinculaCurso(String id, String? cursoId) async {
    if (id == '') return;
    final response = await http.patch(
      Uri.parse('${Constants.professores}/$id.json'),
      body: jsonEncode({
        'cursoId': cursoId,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadProfessores();
    await loadProfessores();
    notifyListeners();
  }

  // updates the id of coordenador de extensão on the database
  Future<void> setCoordenadorExtensao(String id) async {
    final response = await http.patch(
      Uri.parse('${Constants.baseUrl}.json'),
      body: jsonEncode({'coordenadorextensao': id}),
    );

    if (response.statusCode.toString()[0] != '2') return;

    cExtensaoId = id;

    await loadProfessores();
    await loadProfessores();
  }

  // returns the id of coordenador de extensão from the database
  Future<String> getCoordenadorExtensao() async {
    final response = await http.get(
      Uri.parse('${Constants.coordenadorExtensao}.json'),
    );
    final data = jsonDecode(response.body);

    if (data == null) return '';

    return data;
  }

  // adds a new professor to the database from the create screen
  Future<void> addProfessorFromData(Map<String, Object> data) async {
    final response = await http.post(
      Uri.parse('${Constants.professores}.json'),
      body: jsonEncode({
        'nome': data['nome'] as String,
        'email': data['email'] as String,
        'siap': data['siap'] as String,
        'telefone': data['telefone'] as String,
        'vagasId': <String>[],
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    siaps.add(data['siap'] as String);

    await loadProfessores();
    await loadProfessores();
    notifyListeners();
  }

  // updates a professor from the database from the update screen
  Future<void> update(Map<String, Object> data) async {
    final response = await http.patch(
      Uri.parse('${Constants.professores}/${data["id"]}.json'),
      body: jsonEncode({
        'nome': data['nome'] as String,
        'email': data['email'] as String,
        'siap': data['siap'] as String,
        'telefone': data['telefone'] as String,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadProfessores();
    await loadProfessores();
    notifyListeners();
  }

  // adds a vaga id to the professor's list of vagas
  Future<void> vinculaVaga(String id, String vaga) async {
    final response = await http.get(
      Uri.parse('${Constants.professores}/$id.json'),
    );
    final data = jsonDecode(response.body);
    if (data == null) return Future.error('Professo não encontrado');
    final List<String> vagas =
        data['vagasId'] == null ? [] : data['vagasId'].cast<String>();
    vagas.add(vaga);
    await http.patch(
      Uri.parse('${Constants.professores}/$id.json'),
      body: jsonEncode({
        'vagasId': vagas,
      }),
    );

    // await loadProfessores();
    // await loadProfessores();
    _filteredItems = _items;

    notifyListeners();
  }

  // removes a vaga id from the professor's list of vagas
  Future<void> desvinculaVaga(String id, String vagaId) async {
    final response = await http.get(
      Uri.parse('${Constants.professores}/$id.json'),
    );
    final data = jsonDecode(response.body);
    if (data == null) return Future.error('Professo não encontrado');
    final List<String> vagas =
        data['vagasId'] == null ? [] : data['vagasId'].cast<String>();
    vagas.remove(vagaId);
    await http.patch(
      Uri.parse('${Constants.professores}/$id.json'),
      body: jsonEncode({
        'vagasId': vagas,
      }),
    );

    await loadProfessores();
    await loadProfessores();
    // _filteredItems = _items;

    notifyListeners();
  }

  // removes a professor from the database
  Future<void> delete(String id) async {
    final response = await http.delete(
      Uri.parse('${Constants.professores}/$id.json'),
    );

    if (response.statusCode.toString()[0] != '2') return;

    siaps.remove(_items.firstWhere((professor) => professor.id == id).siap);
    _items.removeWhere((professor) => professor.id == id);
    _filteredItems.removeWhere((professor) => professor.id == id);
    notifyListeners();
  }

  // returns a specific professor from an id
  Professor? getProfessor(String? id) {
    if (id == null) return null;
    int index = _items.indexWhere((professor) => professor.id == id);
    return index == -1 ? null : _items[index];
  }
}
