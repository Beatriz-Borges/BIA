import 'package:bia/view-model/aluno_list.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_button.dart';

// this is the search card for aluno

class SearchCard extends StatefulWidget {
  const SearchCard({super.key});

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  final searchController = TextEditingController();

  bool _expanded = false;
  bool alfabetico = false;
  bool prioridade = false;
  bool disponivel = false;
  String? _selectedCurso;

  @override
  Widget build(BuildContext context) {
    // gets the provider for alunos
    final AlunoList alunoList = Provider.of<AlunoList>(context);

    // creates a nullable list of cursos to be used by a dropdown widget
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
      height: _expanded ? 260 : 160,
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
                  ? SizedBox(
                      child: DropdownButtonFormField(
                        // dropdown that filters aluno by the curso
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
                      ),
                    )
                  : TextField(
                      // text field that filters aluno by name
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar por Aluno',
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
                        'Ordenação de Alunos',
                        textAlign: TextAlign.start,
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
                            // filters aluno by alphabetical order
                            children: [
                              Checkbox(
                                value: alfabetico,
                                onChanged: (value) {
                                  setState(() {
                                    alfabetico = value ?? true;
                                  });
                                },
                              ),
                              const Text(
                                'Alfabética',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            // filters alunos by priority
                            children: [
                              Checkbox(
                                value: prioridade,
                                onChanged: (value) {
                                  setState(() {
                                    prioridade = value ?? false;
                                  });
                                },
                              ),
                              const Text(
                                'Prioridade',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            // filters alunos that are not linked to a
                            // vaga
                            children: [
                              Checkbox(
                                value: disponivel,
                                onChanged: (value) {
                                  setState(() {
                                    disponivel = value ?? false;
                                  });
                                },
                              ),
                              const Text(
                                'Disponível',
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
                  // buttons to apply filters
                  onPressed: () {
                    alunoList.filterItems(
                      name: searchController.text.toUpperCase(),
                      alfabetico: alfabetico,
                      prioridade: prioridade,
                      disponivel: disponivel,
                      cursoId: _selectedCurso,
                    );
                  },
                  child: Text(_expanded ? 'Filtrar' : 'Buscar'),
                ),
                CustomButton(
                  // button tha alternates between filter options
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
