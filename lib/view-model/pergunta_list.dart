import 'dart:convert';

import 'package:bia/model/models/pergunta.dart';
import 'package:bia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// the provider that handles the changes to perguntas

class PerguntaList with ChangeNotifier {
  final List<Pergunta> _items = [];

  // returns a copy of _items so that it can't be changed outside the provider
  List<Pergunta> get items => [..._items];
  int get itemsCount => _items.length;

  // function to get the perguntas from the database and saves them in _items
  Future<void> loadPerguntas() async {
    _items.clear();

    final response = await http.get(
      Uri.parse('${Constants.perguntas}.json'),
    );

    if (response.body == 'null') return;

    final data = jsonDecode(response.body);
    data.forEach((perguntaId, perguntaData) {
      _items.insert(
        0,
        Pergunta(
          id: perguntaId,
          pergunta: perguntaData['pergunta'],
          resposta: perguntaData['resposta'],
        ),
      );
    });

    notifyListeners();
  }

  // function tha hanles the reordering of how the perguntas are shown
  void reorderList(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    notifyListeners();
  }

  // adds a new pergunta to the database from the create screen
  Future<void> addPerguntaFromData(Map<String, Object> data) async {
    final response = await http.post(
      Uri.parse('${Constants.perguntas}.json'),
      body: jsonEncode({
        'pergunta': data['pergunta'] as String,
        'resposta': data['resposta'] as String,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadPerguntas();
    await loadPerguntas();
    notifyListeners();
  }

  // updates a pergunta on the database from the update screen
  Future<void> update(Map<String, Object> data) async {
    final response = await http.patch(
      Uri.parse('${Constants.perguntas}/${data["id"]}.json'),
      body: jsonEncode({
        'pergunta': data['pergunta'] as String,
        'resposta': data['resposta'] as String,
      }),
    );

    if (response.statusCode.toString()[0] != '2') return;

    await loadPerguntas();
    await loadPerguntas();
    notifyListeners();
  }

  // removes a pergunta from the database
  Future<void> delete(String id) async {
    final response = await http.delete(
      Uri.parse('${Constants.perguntas}/$id.json'),
    );

    if (response.statusCode.toString()[0] != '2') return;

    _items.removeWhere((pergunta) => pergunta.id == id);
    loadPerguntas();
    notifyListeners();
  }

  // returns a pergunta from an id
  Pergunta? getPergunta(String id) {
    int index = _items.indexWhere((pergunta) => pergunta.id == id);
    return index == -1 ? null : _items[index];
  }
}
