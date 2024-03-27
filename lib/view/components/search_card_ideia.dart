import 'package:bia/view-model/curso_list.dart';
import 'package:bia/view-model/ideia_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_button.dart';

class SearchCardIdeia extends StatefulWidget {
  const SearchCardIdeia({super.key});

  @override
  State<SearchCardIdeia> createState() => _SearchCardIdeiaState();
}

class _SearchCardIdeiaState extends State<SearchCardIdeia> {
  final searchController = TextEditingController();

  bool _expanded = false;
  bool alfabetico = false;
  String? _selectedCurso;

  @override
  Widget build(BuildContext context) {
    // gets provider for ideias
    final IdeiaList ideiaList = Provider.of<IdeiaList>(context);

    // creates a nullable list of cursos for a dropdown widget
    List<DropdownMenuItem> cursos() {
      List<DropdownMenuItem> list = [];
      list.add(const DropdownMenuItem(
        value: '',
        child: Text('-'),
      ));
      for (var curso in Provider.of<CursoList>(context, listen: false).items) {
        list.add(DropdownMenuItem(
          value: curso.sigla,
          child: Text(curso.nome),
        ));
      }
      return list;
    }

    return SizedBox(
      height: _expanded ? 230 : 160,
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
                        // dropdown widget for filtering ideia by curso
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
                      // text field for filtering ideia by name
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar por ideia',
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
                        'Ordenação de ideias',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Row(
                        // filter ideias by alphabetical order
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
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
                    ideiaList.filterItems(
                      titulo: searchController.text.toUpperCase(),
                      alfabetico: alfabetico,
                      cursoId: _selectedCurso,
                    );
                  },
                  child: Text(_expanded ? 'Filtrar' : 'Buscar'),
                ),
                CustomButton(
                  // button to alternate between filters
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
