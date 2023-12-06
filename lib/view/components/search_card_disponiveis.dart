import 'package:bia/model/models/vaga.dart';
import 'package:bia/view-model/aluno_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_button.dart';

// search card for alunos when linking aluno to vaga

class SearchCardDisponivel extends StatefulWidget {
  final Vaga vaga;
  const SearchCardDisponivel({
    required this.vaga,
    super.key,
  });

  @override
  State<SearchCardDisponivel> createState() => _SearchCardDisponivelState();
}

class _SearchCardDisponivelState extends State<SearchCardDisponivel> {
  final searchController = TextEditingController();

  bool interessado = false;

  bool alfabetico = false;
  bool prioridade = false;

  @override
  Widget build(BuildContext context) {
    final AlunoList alunoList = Provider.of<AlunoList>(context);

    return SizedBox(
      height: !widget.vaga.curricular ? 220 : 160,
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
            if (!widget.vaga.curricular)
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 8,
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    // text field for filtering aluno by name
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
                      'Listar Alunos:',
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
                        // filter alunos that demonstrated interest in
                        // the vaga if the vaga is extra-curricular
                        if (!widget.vaga.curricular)
                          Column(
                            children: [
                              Checkbox(
                                value: interessado,
                                onChanged: (value) {
                                  setState(() {
                                    interessado = value ?? true;
                                  });
                                },
                              ),
                              const Text(
                                'Interessados',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        // filter the alunos based on their priority
                        // if the vaga is curricular
                        if (widget.vaga.curricular)
                          Column(
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
                        // filter alunos by alphabetical order
                        if (widget.vaga.curricular)
                          Column(
                            children: [
                              Checkbox(
                                value: alfabetico,
                                onChanged: (value) {
                                  setState(() {
                                    alfabetico = value ?? false;
                                  });
                                },
                              ),
                              const Text(
                                'Alfabético',
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
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: CustomButton(
                    // button to apply filters
                    onPressed: () {
                      alunoList.filterItems(
                        name: searchController.text.toUpperCase(),
                        alfabetico: alfabetico,
                        prioridade: prioridade,
                        interessados:
                            interessado ? widget.vaga.interessados : null,
                      );
                    },
                    child: const Text('Filtrar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
