import 'dart:convert';

import 'package:bia/model/models/professor.dart';
import 'package:bia/utils/constants.dart';
import 'package:bia/view-model/professor_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// the provider that handles the changes to professores in the import page

class ProfessorImportList with ChangeNotifier {
  final List<Professor> _items = [];
  bool isLoading = false;

  // returns a copy of _items in alphabetical order
  List<Professor> get items {
    final List<Professor> list = [..._items];
    list.sort(
      (a, b) {
        return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
      },
    );
    return list;
  }

  int get itemsCount => _items.length;

  void resetImport() {
    _items.clear();
  }

  // adds professor to _items from the import page
  void addprofessorFromImport({
    required String nome,
    required String email,
    required String telefone,
    required String siap,
  }) {
    if (ProfessorList.siaps.contains(siap)) return;

    _items.add(
      Professor(
        id: 'placeholder',
        nome: nome,
        email: email,
        telefone: telefone,
        siap: siap,
        vagasId: <String>[],
      ),
    );
    notifyListeners();
  }

  // calls the fucntion to save in the database
  // not sure why i made it this way, but i'm not changing it now
  Future<void> addProfessorFromImportList() async {
    isLoading = true;
    for (var professor in items) {
      try {
        await addProfessorFromData({
          'nome': professor.nome,
          'email': professor.email,
          'telefone': professor.telefone,
          'siap': professor.siap,
          'vagasId': <String>[],
        });
      } catch (e) {
        // print(e.toString());
      }
    }
  }

  // adds a new professor to the database
  Future<void> addProfessorFromData(Map<String, Object> data) async {
    final response = await http.post(
      Uri.parse('${Constants.professores}.json'),
      body: jsonEncode({
        'nome': data['nome'] as String,
        'email': data['email'] as String,
        'telefone': data['telefone'] as String,
        'siap': data['siap'] as String,
        'vagasId': <String>[],
        // 'cursoId': data['cursoId'] as String,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    ProfessorList.siaps.add(data['siap'] as String);
    delete(data['siap'] as String);
  }

  // removes from the list
  void delete(String siap) {
    _items.removeWhere((professor) => professor.siap == siap);
    notifyListeners();
    if (_items.isEmpty) {
      isLoading = false;
    }
  }

  // returns a professor from a siap
  Professor? getprofessor(String? siap) {
    if (siap == null) return null;
    int index = _items.indexWhere((professor) => professor.siap == siap);
    return index == -1 ? null : _items[index];
  }
}
