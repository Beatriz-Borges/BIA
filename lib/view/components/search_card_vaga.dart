import 'package:bia/view-model/curso_list.dart';
import 'package:bia/view-model/vaga_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_button.dart';

class SearchCardVaga extends StatefulWidget {
  const SearchCardVaga({super.key});

  @override
  State<SearchCardVaga> createState() => _SearchCardVagaState();
}

class _SearchCardVagaState extends State<SearchCardVaga> {
  final searchController = TextEditingController();

  bool _expanded = false;
  bool _curricular = false;
  bool _eCurricular = false;
  String? _selectedCurso;

  @override
  Widget build(BuildContext context) {
    // gets provider for vagas
    final VagaList vagaList = Provider.of<VagaList>(context);

    // creates a nullable for cursos to be used by a dropdown widget
    List<DropdownMenuItem> cursos() {
      List<DropdownMenuItem> list = [];
      list.add(const DropdownMenuItem(
        value: '',
        child: Text('-'),
      ));
      for (var curso in Provider.of<CursoList>(context, listen: false).items) {
        list.add(DropdownMenuItem(
          value: curso.id,
          child: Text(curso.nome),
        ));
      }
      return list;
    }

    return SizedBox(
      height: _expanded ? 250 : 160,
      child: Card(
        shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(10)),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8,
              ),
              child: _expanded
                  ? DropdownButtonFormField(
                      // dropdown widget that filters vaga by curso
                      borderRadius: BorderRadius.circular(10),
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      hint: const Text(
                        'Selecione o Curso',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      items: [...cursos()],
                      value: _selectedCurso,
                      focusColor: const Color.fromRGBO(0, 0, 0, 0),
                      onChanged: (value) {
                        setState(() {
                          if (value == '') {
                            _selectedCurso = null;
                          } else {
                            _selectedCurso = value;
                          }
                        });
                      },
                    )
                  : TextField(
                      // text field that filters vaga by função
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar por Vaga',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          gapPadding: 10,
                        ),
                      ),
                    ),
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Listar Vagas:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Checkbox(
                                value: _curricular,
                                onChanged: (value) {
                                  setState(() {
                                    _curricular = value ?? true;
                                    if (_curricular) {
                                      _eCurricular = false;
                                    }
                                  });
                                },
                              ),
                              const Text(
                                'Curricular',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Checkbox(
                                value: _eCurricular,
                                onChanged: (value) {
                                  setState(() {
                                    _eCurricular = value ?? false;
                                    if (_eCurricular) {
                                      _curricular = false;
                                    }
                                  });
                                },
                              ),
                              const Text(
                                'Extra-Curricular',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomButton(
                  // button to apply filters
                  onPressed: () {
                    bool? curricular;

                    // translates the curricular variable
                    if (_curricular) {
                      curricular = true;
                    } else if (_eCurricular) {
                      curricular = false;
                    }

                    vagaList.filterItems(
                      funcao: searchController.text,
                      curricular: curricular,
                      cursoId: _selectedCurso,
                    );
                  },
                  child: Text(_expanded ? 'Filtrar' : 'Buscar'),
                ),
                CustomButton(
                  // alternate between the filters options
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  child: Text(_expanded ? 'Voltar' : 'Aplicar Filtros'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
