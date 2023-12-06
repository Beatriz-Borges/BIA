import 'dart:convert';

import 'package:bia/model/models/aluno.dart';
import 'package:bia/utils/constants.dart';
import 'package:bia/view-model/aluno_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// the provider that handles the changes to alunos in the import page

class AlunoImportList with ChangeNotifier {
  final List<Aluno> _items = [];
  bool isLoading = false;

  // returns a copy of _items in alphabetical order
  List<Aluno> get items {
    final List<Aluno> list = [..._items];
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

  // adds aluno to _items from the import page
  void addAlunoFromImport({
    required String nome,
    required String matricula,
    required String email,
    required String cursoId,
  }) {
    if (AlunoList.matriculas.contains(matricula)) return;

    _items.add(
      Aluno(
        id: 'placeholder',
        nome: nome,
        email: email,
        matricula: matricula,
        cursoId: cursoId,
        eCurricular: false,
        eExtraCurricular: false,
      ),
    );
    notifyListeners();
  }

  // calls the fucntion to save in the database
  // not sure why i made it this way, but i'm not changing it now
  Future<void> addAlunoFromImportList() async {
    isLoading = true;
    for (var aluno in items) {
      try {
        await addAlunoFromData({
          'nome': aluno.nome,
          'email': aluno.email,
          'matricula': aluno.matricula,
          'telefone': aluno.telefone,
          'cursoId': aluno.cursoId,
          'eCurricular': aluno.eCurricular,
          'eExtraCurricular': aluno.eExtraCurricular,
        });
      } catch (e) {
        // print(e.toString());
      }
    }
  }

  // adds a new aluno to the database
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

    AlunoList.matriculas.add(data['matricula'] as String);
    delete(data['matricula'] as String);
  }

  // removes from the list
  void delete(String matricula) {
    _items.removeWhere((aluno) => aluno.matricula == matricula);
    notifyListeners();
    if (_items.isEmpty) {
      isLoading = false;
    }
  }

  // returns an aluno from a matricula
  Aluno? getAluno(String? matricula) {
    if (matricula == null) return null;
    int index = _items.indexWhere((aluno) => aluno.matricula == matricula);
    return index == -1 ? null : _items[index];
  }
}
