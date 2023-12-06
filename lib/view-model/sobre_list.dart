import 'dart:convert';

import 'package:bia/model/models/sobre.dart';
import 'package:bia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// the provider that handles the changes to sobre

class SobreList with ChangeNotifier {
  final List<Sobre> _items = [];

  // returns a copy of _items so that it can't be changed outside the provider
  List<Sobre> get items => [..._items];

  int get itemsCount => _items.length;

  // function to get the sobre from the database and saves them in _items
  Future<void> loadSobre() async {
    _items.clear();

    final response = await http.get(
      Uri.parse('${Constants.sobre}.json'),
    );

    if (response.body == 'null') return;

    final data = jsonDecode(response.body);

    data.forEach(
      (sobreId, sobreData) {
        _items.insert(
          0,
          Sobre(
            id: sobreId,
            titulo: sobreData['titulo'],
            texto: sobreData['texto'],
          ),
        );
      },
    );

    notifyListeners();
  }

  // adds a new sobre to the database from the create screen
  Future<void> addsobreFromData(Map<String, Object> data) async {
    final response = await http.post(
      Uri.parse('${Constants.sobre}.json'),
      body: jsonEncode({
        'titulo': data['titulo'] as String,
        'texto': data['texto'] as String,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadSobre();
    await loadSobre();
    notifyListeners();
  }

  // updates a sobre on the database from the the update screen
  Future<void> update(Map<String, Object> data) async {
    final response = await http.patch(
      Uri.parse('${Constants.sobre}/${data["id"]}.json'),
      body: jsonEncode({
        'texto': data['texto'] as String,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadSobre();
    await loadSobre();
    notifyListeners();
  }

  // removes a sobre from the database
  Future<void> delete(String id) async {
    final response = await http.delete(
      Uri.parse('${Constants.sobre}/$id.json'),
    );

    if (response.statusCode.toString()[0] != '2') return;

    _items.removeWhere((sobre) => sobre.id == id);
    notifyListeners();
  }

  // returns a sobre from an id
  Sobre? getsobre(String id) {
    int index = _items.indexWhere((sobre) => sobre.id == id);
    return index == -1 ? null : _items[index];
  }
}
