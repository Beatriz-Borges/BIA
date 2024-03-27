import 'package:bia/view-model/professor_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_button.dart';

class SearchCardProfessor extends StatefulWidget {
  const SearchCardProfessor({super.key});

  @override
  State<SearchCardProfessor> createState() => _SearchCardProfessorState();
}

class _SearchCardProfessorState extends State<SearchCardProfessor> {
  final searchController = TextEditingController();

  bool _expanded = false;
  bool alfabetico = false;
  bool disponivel = false;
  bool coordenador = false;

  @override
  Widget build(BuildContext context) {
    final ProfessorList professorList = Provider.of<ProfessorList>(context);

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
            if (!_expanded)
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 8,
                ),
                child: TextField(
                  // text field for filtering professor by name
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar por professor',
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
                        'Ordenação de Professores',
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
                            // filters professor by alphabetical order
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
                            // not sure what this filter does. maybe irrelevant
                            children: [
                              Checkbox(
                                value: disponivel,
                                onChanged: (value) {
                                  setState(() {
                                    disponivel = value ?? true;
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
                  // apply filters
                  onPressed: () {
                    professorList.filterItems(
                      name: searchController.text.toUpperCase(),
                      alfabetico: alfabetico,
                      disponivel: disponivel,
                    );
                  },
                  child: Text(_expanded ? 'Filtrar' : 'Buscar'),
                ),
                CustomButton(
                  // change between filters options
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
