import 'package:bia/model/models/curso.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_button.dart';

class SearchCardCurso extends StatefulWidget {
  const SearchCardCurso({super.key});

  @override
  State<SearchCardCurso> createState() => _SearchCardCursoState();
}

class _SearchCardCursoState extends State<SearchCardCurso> {
  final searchController = TextEditingController();

  bool _expanded = false;
  String? _selectedNivel;

  @override
  Widget build(BuildContext context) {
    // gets the provider for cursos
    final CursoList cursoList = Provider.of<CursoList>(context);

    // creates nullable list of curso.niveis to be used by a dropdown widget
    List<DropdownMenuItem> niveis() {
      List<DropdownMenuItem> list = [];
      list.add(const DropdownMenuItem(
        value: '',
        child: Text('-'),
      ));
      for (var nivel in Curso.niveis) {
        list.add(DropdownMenuItem(
          value: nivel,
          child: Text(nivel),
        ));
      }
      return list;
    }

    return SizedBox(
      height: _expanded ? 160 : 160,
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
                      // dropdown widget for filtering cursos by nivel
                      borderRadius: BorderRadius.circular(10),
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      hint: const Text(
                        'Selecione o Nível',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      items: [...niveis()],
                      value: _selectedNivel,
                      focusColor: const Color.fromRGBO(0, 0, 0, 0),
                      onChanged: (value) {
                        setState(() {
                          if (value == '') {
                            _selectedNivel = null;
                          } else {
                            _selectedNivel = value;
                          }
                        });
                      },
                    )
                  : TextField(
                      // text field for filtering cursos by name
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar por curso',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomButton(
                  // button to apply filters
                  onPressed: () {
                    cursoList.filterItems(
                      nome: searchController.text,
                      nivel: _selectedNivel,
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
