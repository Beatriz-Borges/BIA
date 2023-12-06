import 'dart:convert';
import 'package:bia/model/models/vaga.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// the provider that handles the changes to vagas

class VagaList with ChangeNotifier {
  final List<Vaga> _items = [];
  late List<Vaga> _filteredItems = _items;

  // returns a copy of _items so that it can't be changed outside the provider
  List<Vaga> get items => [..._items];

  List<Vaga> get filteredItems => [..._filteredItems];
  int get itemsCount => _items.length;

  // function to get the vagas from the database and saves them in _items
  Future<void> loadVagas({String? concedenteId}) async {
    _items.clear();

    final response = await http.get(
      Uri.parse('${Constants.vagas}.json'),
    );

    if (response.body == 'null') return;

    final data = jsonDecode(response.body);
    final user = AuthService().currentUser!;

    // if the user is an aluno that is linked to a vaga, it saves the
    // vaga in a variable
    String alunoVaga = '';
    if (['Aluno'].contains(user.tipo)) {
      final alunoResponse =
          await http.get(Uri.parse('${Constants.alunos}/${user.tipoId}.json'));
      final alunoData = jsonDecode(alunoResponse.body);
      if (alunoData != null) {
        if (alunoData['vagaId'] != null) {
          alunoVaga = alunoData['vagaId'];
        }
      }
    }
    data.forEach((vagaId, vagaData) {
      // if the alunoVaga isn't empty it will get the vaga
      // to the user that is linked to it
      // otherwise if the user is aluno it won't get any of them
      if (!['Aluno'].contains(user.tipo) ||
          user.tipoId == vagaData['alunoId'] ||
          (!vagaData['curricular'] && vagaData['alunoId'] == null) &&
              alunoVaga == '') {
        _items.insert(
          0,
          Vaga(
            id: vagaId,
            funcao: vagaData['funcao'],
            concedenteId: vagaData['concedenteId'],
            cursoId: vagaData['cursoId'],
            remuneracao: vagaData['remuneracao'],
            descricao: vagaData['descricao'],
            curricular: vagaData['curricular'],
            alunoId: vagaData['alunoId'],
            professorId: vagaData['professorId'],
            interessados: vagaData['interessados'] != null
                ? vagaData['interessados'].cast<String>()
                : <String>[],
          ),
        );
      }
    });

    _filteredItems = _items.where((vaga) {
      // if the concedente parameter isn't null it will filter the list
      // to that concedente
      return concedenteId == null ? true : vaga.concedenteId == concedenteId;
    }).toList();

    notifyListeners();
  }

  // filter the _items to show only vagas with a specific concedente
  void filterItemsConcedente({String? concedenteId}) {
    if (concedenteId != null) {
      _filteredItems = _filteredItems.where((vaga) {
        return vaga.concedenteId == concedenteId;
      }).toList();
    }

    notifyListeners();
  }

  // filter the _items to show only the relevant items
  void filterItems({
    String funcao = '',
    bool? curricular,
    String? cursoId,
  }) {
    _filteredItems = _items.where((vaga) {
      return vaga.funcao.toLowerCase().contains(funcao.toLowerCase());
    }).toList();

    if (curricular != null) {
      _filteredItems = _filteredItems.where((vaga) {
        return vaga.curricular == curricular;
      }).toList();
    }

    if (cursoId != null) {
      _filteredItems = _filteredItems.where((vaga) {
        return vaga.cursoId == cursoId;
      }).toList();
    }

    notifyListeners();
  }

  // adds the id of an aluno to a vaga
  Future<void> vinculaAluno(String id, String aluno) async {
    final response = await http.patch(
      Uri.parse('${Constants.vagas}/$id.json'),
      body: jsonEncode({
        'alunoId': aluno,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadVagas();
    await loadVagas();

    // _filteredItems = _items;

    notifyListeners();
  }

  // removes the id of an aluno from a vaga
  Future<void> desvinculaAluno(String id) async {
    final response = await http.patch(
      Uri.parse('${Constants.vagas}/$id.json'),
      body: jsonEncode({
        'alunoId': null,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadVagas();
    await loadVagas();

    notifyListeners();
  }

  // adds a professor id to a vaga
  Future<void> vinculaProfessor(String id, String professor) async {
    final int index = _items.indexWhere((vaga) => vaga.id == id);
    final oldProfessor = _items[index].professorId;
    _items[index].professorId = professor;

    final response = await http.patch(
      Uri.parse('${Constants.vagas}/$id.json'),
      body: jsonEncode({
        'professorId': professor,
      }),
    );

    if (response.statusCode.toString()[0] != '2') {
      _items[index].professorId == oldProfessor;
    }

    await loadVagas();
    await loadVagas();

    notifyListeners();
  }

  // removes a professor id from a vaga
  Future<void> desvinculaProfessor(String id) async {
    final response = await http.patch(
      Uri.parse('${Constants.vagas}/$id.json'),
      body: jsonEncode({
        'professorId': null,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;
    _filteredItems = _items;

    notifyListeners();
  }

  // adds a new vaga to the database from the create screen
  Future<void> addVagaFromData(
    Map<String, dynamic> data,
    int quantidade,
  ) async {
    for (var i = 0; i < quantidade; i++) {
      final response = await http.post(
        Uri.parse('${Constants.vagas}.json'),
        body: jsonEncode({
          'funcao': data['funcao'] as String,
          'concedenteId': data['concedenteId'] as String,
          'cursoId': data['cursoId'] as String,
          'remuneracao': data['remuneracao'] as double,
          'descricao': data['descricao'] as String,
          'curricular': data['curricular'] as bool,
          'interessados': <String>[],
        }),
      );
      if (response.statusCode.toString()[0] != '2') return;
    }
    await loadVagas();
    await loadVagas();
    notifyListeners();
  }

  // updates a vaga on the database from the update screen
  Future<void> update(Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('${Constants.vagas}/${data["id"]}.json'),
      body: jsonEncode({
        'funcao': data['funcao'] as String,
        'concedenteId': data['concedenteId'] as String,
        'remuneracao': data['remuneracao'] as double,
        'descricao': data['descricao'] as String,
        'curricular': data['curricular'] as bool,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadVagas();
    await loadVagas();
    notifyListeners();
  }

  // removes a aluno id from the list of alunos interessados
  Future<void> removeInteressado(String vagaId, String alunoId) async {
    Vaga? vaga = getVaga(vagaId);

    if (vaga == null) return;

    vaga.interessados.remove(alunoId);

    final response = await http.patch(
      Uri.parse('${Constants.vagas}/$vagaId.json'),
      body: jsonEncode({
        'interessados': vaga.interessados,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadVagas();
    await loadVagas();
    notifyListeners();
  }

  // adds an aluno id to the list of alunos interessados
  Future<void> addInteressado(String vagaId, String alunoId) async {
    Vaga? vaga = getVaga(vagaId);

    if (vaga == null) return;

    vaga.interessados.add(alunoId);

    final response = await http.patch(
      Uri.parse('${Constants.vagas}/$vagaId.json'),
      body: jsonEncode({
        'interessados': vaga.interessados,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadVagas();
    await loadVagas();
    notifyListeners();
  }

  // removes a vaga from the database
  Future<void> delete(String id) async {
    final response = await http.delete(
      Uri.parse('${Constants.vagas}/$id.json'),
    );

    if (response.statusCode.toString()[0] != '2') return;

    _items.removeWhere((vaga) => vaga.id == id);
    _filteredItems.removeWhere((vaga) => vaga.id == id);
    notifyListeners();
  }

  Vaga? getVaga(String? id) {
    if (id == null) return null;
    int index = _items.indexWhere((vaga) => vaga.id == id);
    return index == -1 ? null : _items[index];
  }

  // returns a list of vagas from a list of vagasIds
  List<Vaga> getVagas(List<String> vagasId) {
    final List<Vaga> vagas = [];
    for (var vagaId in vagasId) {
      int index = _items.indexWhere((vaga) => vaga.id == vagaId);
      if (index != -1) vagas.add(_items[index]);
    }
    return vagas;
  }
}
