import 'dart:convert';

import 'package:bia/model/models/concedente.dart';
import 'package:bia/utils/constants.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

// the provider that handles the changes to concedentes

class ConcedenteList with ChangeNotifier {
  final List<Concedente> _items = [];
  late List<Concedente> _filteredItems = _items;

  // returns a copy of _items so that it can't be changed outside the provider
  List<Concedente> get items => [..._items];

  List<Concedente> get filteredItems => [..._filteredItems];
  int get itemsCount => _items.length;

  // function to get the concedentes from the database and saves them in _items
  Future<void> loadConcedentes() async {
    _items.clear();

    final response = await http.get(
      Uri.parse('${Constants.concedentes}.json'),
    );

    if (response.body == 'null') return;

    final data = jsonDecode(response.body);
    data.forEach((concedenteId, concedenteData) {
      _items.insert(
        0,
        Concedente(
          id: concedenteId,
          nome: concedenteData['nome'],
          // nomeFantasia: concedenteData['nomeFantasia'],
          // nomeOficial: concedenteData['nomeOficial'],
          // endereco: concedenteData['nome'],
          // estado: concedenteData['estado'],
          // pais: concedenteData['pais'],
          email: concedenteData['email'],
          telefoneEmpresa: concedenteData['telefoneEmpresa'],
          cnpj: concedenteData['cnpj'],
          responsavel: concedenteData['responsavel'],
          telefoneResponsavel: concedenteData['telefoneResponsavel'],
        ),
      );
    });

    _filteredItems = _items;
    notifyListeners();
  }

  // filter the _items to show only the relevant items
  void filterItems({String nome = ''}) {
    _filteredItems = _items.where((concedente) {
      //   return concedente.nomeFantasia
      //       .toLowerCase()
      //       .contains(nameFantasia.toLowerCase());
      return concedente.nome.toLowerCase().contains(nome.toLowerCase());
    }).toList();

    notifyListeners();
  }

  // adds a new concedente to the database from the create screen
  Future<void> addConcedenteFromData(Map<String, Object> data) async {
    final response = await http.post(
      Uri.parse('${Constants.concedentes}.json'),
      body: jsonEncode({
        'nome': data['nome'] as String,
        // 'nomeFantasia': data['nomeFantasia'] as String,
        // 'nomeOficial': data['nomeOficial'] as String,
        // 'endereco': data['endereço'] as String,
        // 'estado': data['estado'] as String,
        // 'pais': data['pais'] as String,
        'email': data['email'] as String,
        'telefoneEmpresa': data['telefoneEmpresa'] as String,
        'cnpj': data['cnpj'] as String,
        'responsavel': data['responsavel'] as String,
        'telefoneResponsavel': data['telefoneResponsavel'] as String,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadConcedentes();
    await loadConcedentes();
    notifyListeners();
  }

  // updates a concedente on the database from the update screen
  Future<void> update(Map<String, Object> data) async {
    final response = await http.put(
      Uri.parse('${Constants.concedentes}/${data["id"]}.json'),
      body: jsonEncode({
        'id': data['id'] as String,
        'nome': data['nome'] as String,
        // 'nomeFantasia': data['nomeFantasia'] as String,
        // 'nomeOficial': data['nomeOficial'] as String,
        // 'endereco': data['endereco'] as String,
        // 'estado': data['estado'] as String,
        // 'pais': data['pais'] as String,
        'email': data['email'] as String,
        'telefoneEmpresa': data['telefoneEmpresa'] as String,
        'cnpj': data['cnpj'] as String,
        'responsavel': data['responsavel'] as String,
        'telefoneResponsavel': data['telefoneResponsavel'] as String,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadConcedentes();
    await loadConcedentes();
    notifyListeners();
  }

  // removes a concedente from the database
  Future<void> delete(String id) async {
    final response = await http.delete(
      Uri.parse('${Constants.concedentes}/$id.json'),
    );

    if (response.statusCode.toString()[0] != '2') return;

    _items.removeWhere((concedente) => concedente.id == id);
    _filteredItems.removeWhere((concedente) => concedente.id == id);
    notifyListeners();
  }

  // returns a concedente from an id
  Concedente? getConcedente(String id) {
    int index = _items.indexWhere((concedente) => concedente.id == id);
    return index == -1 ? null : _items[index];
  }
}
