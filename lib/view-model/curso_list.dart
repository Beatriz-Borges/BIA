import 'dart:convert';

import 'package:bia/model/models/curso.dart';
import 'package:bia/utils/constants.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

// the provider that handles the changes to cursos

class CursoList with ChangeNotifier {
  final List<Curso> _items = [];
  late List<Curso> _filteredItems = _items;

  // returns a copy of _items so that it can't be changed outside the provider
  List<Curso> get items => [..._items];

  List<Curso> get filteredItems => [..._filteredItems];
  int get itemsCount => _items.length;

  // function to get the ideias from the database and saves them in _items
  Future<void> loadCursos() async {
    _items.clear();

    final response = await http.get(
      Uri.parse('${Constants.cursos}.json'),
    );

    if (response.body == 'null') return;

    final data = jsonDecode(response.body);
    data.forEach((cursoId, cursoData) {
      _items.insert(
        0,
        Curso(
          id: cursoId,
          nome: cursoData['nome'],
          sigla: cursoData['sigla'],
          nivel: cursoData['nivel'],
          coordenadorId: cursoData['coordenadorId'],
        ),
      );
    });

    _filteredItems = _items;
    notifyListeners();
  }

  // filter the _items to show only the relevant items
  void filterItems({String nome = '', String? nivel}) {
    _filteredItems = _items.where((curso) {
      return curso.nome.toLowerCase().contains(nome.toLowerCase());
    }).toList();

    if (nivel != null) {
      _filteredItems = _filteredItems.where((curso) {
        return curso.nivel == nivel;
      }).toList();
    }

    notifyListeners();
  }

  // adds a new curso to the database from the create screen
  Future<void> addCursoFromData(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${Constants.cursos}.json'),
      body: jsonEncode({
        'nome': data['nome'],
        'sigla': data['sigla'],
        'nivel': data['nivel'],
        'coordenadorId': data['coordenadorId'],
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadCursos();
    await loadCursos();
    notifyListeners();
  }

  // updates a curso on the database from the update screen
  Future<void> update(Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('${Constants.cursos}/${data["id"]}.json'),
      body: jsonEncode({
        'nome': data['nome'] as String,
        'sigla': data['sigla'] as String,
        'nivel': data['nivel'] as String,
        'coordenadorId': data['coordenadorId'] == ''
            ? null
            : data['coordenadorId'] as String,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadCursos();
    await loadCursos();
    notifyListeners();
  }

  // removes a curso from the database
  Future<void> delete(String id) async {
    final response = await http.delete(
      Uri.parse('${Constants.cursos}/$id.json'),
    );

    if (response.statusCode.toString()[0] != '2') return;

    _items.removeWhere((curso) => curso.id == id);
    _filteredItems.removeWhere((curso) => curso.id == id);
    notifyListeners();
  }

  // returns a curso from an id
  Curso? getCurso(String? id) {
    if (id == null) return null;
    int index = _items.indexWhere((curso) {
      return curso.id == id;
    });
    return index == -1 ? null : _items[index];
  }

  // returns a curso from a sigla
  Curso? getCursoFromSigla(String? sigla) {
    if (sigla == null) return null;
    int index = _items.indexWhere((curso) {
      return curso.sigla == sigla;
    });
    return index == -1 ? null : _items[index];
  }
}
