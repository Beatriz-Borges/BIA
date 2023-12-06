import 'dart:convert';

import 'package:bia/model/models/ideia.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// the provider that handles the changes to ideias

class IdeiaList with ChangeNotifier {
  final List<Ideia> _items = [];
  late List<Ideia> _filteredItems = _items;

  // returns a copy of _items so that it can't be changed outside the provider
  List<Ideia> get items => [..._items];

  List<Ideia> get filteredItems => [..._filteredItems];
  int get itemsCount => _items.length;

  // function to get the ideias from the database and saves them in _items
  Future<void> loadIdeias() async {
    _items.clear();

    final response = await http.get(
      Uri.parse('${Constants.ideias}.json'),
    );

    if (response.body == 'null') return;

    final data = jsonDecode(response.body);

    final user = AuthService().currentUser!;

    String userId = user.tipoId;
    String? curso;

    // checks it the user is the coordenador de curso, and if it is,
    // it adds all the ideias from that curso
    // the user can see their own ideias
    if (['Professor'].contains(user.tipo)) {
      final response = await http
          .get(Uri.parse('${Constants.professores}/${user.tipoId}.json'));

      final professor = jsonDecode(response.body);
      if (professor != null) {
        curso = professor['cursoId'];
      }
    }
    data.forEach(
      (ideiaId, ideiaData) {
        if (userId.isEmpty ||
            userId == ideiaData['userId'] ||
            curso == ideiaData['cursoId']) {
          _items.insert(
            0,
            Ideia(
              id: ideiaId,
              titulo: ideiaData['titulo'],
              cursoId: ideiaData['cursoId'],
              descricao: ideiaData['descricao'],
              userId: ideiaData['userId'],
            ),
          );
        }
      },
    );

    _filteredItems = _items;
    notifyListeners();
  }

  // filter the _items to show only the relevant items
  void filterItems({
    String titulo = '',
    bool alfabetico = false,
    String? cursoId,
  }) {
    _filteredItems = _items.where(
      (ideia) {
        return ideia.titulo.toLowerCase().contains(titulo.toLowerCase());
      },
    ).toList();

    if (cursoId != null) {
      _filteredItems =
          _filteredItems.where((ideia) => ideia.cursoId == cursoId).toList();
    }

    if (alfabetico) {
      _filteredItems.sort(
        (a, b) {
          return a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
        },
      );
    }

    notifyListeners();
  }

  bool filteredListHasIdeia(String? titulo) {
    if (titulo == null) {
      return false;
    }

    for (var ideia in filteredItems) {
      if (ideia.titulo == titulo) {
        return true;
      }
    }

    return false;
  }

  // adds a new ideia to the database from the create screen
  Future<void> addIdeiaFromData(Map<String, Object> data) async {
    final response = await http.post(
      Uri.parse('${Constants.ideias}.json'),
      body: jsonEncode({
        'titulo': data['titulo'] as String,
        'descricao': data['descricao'] as String,
        'cursoId': data['cursoId'] as String,
        'userId': data['userId'] as String?,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadIdeias();
    await loadIdeias();
    notifyListeners();
  }

  // updates an ideia on the database from the the update screen
  Future<void> update(Map<String, Object> data) async {
    final response = await http.patch(
      Uri.parse('${Constants.ideias}/${data["id"]}.json'),
      body: jsonEncode({
        'titulo': data['titulo'] as String,
        'descricao': data['descricao'] as String,
        'cursoId': data['cursoId'] as String,
        'alunoId': data['userId'] as String,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadIdeias();
    await loadIdeias();
    notifyListeners();
  }

  // removes an ideia from the database
  Future<void> delete(String id) async {
    final response = await http.delete(
      Uri.parse('${Constants.ideias}/$id.json'),
    );

    if (response.statusCode.toString()[0] != '2') return;

    _items.removeWhere((ideia) => ideia.id == id);
    _filteredItems.removeWhere((ideia) => ideia.id == id);
    notifyListeners();
  }

  // returns an ideia from an id
  Ideia? getIdeia(String id) {
    int index = _items.indexWhere((ideia) => ideia.id == id);
    return index == -1 ? null : _items[index];
  }
}
