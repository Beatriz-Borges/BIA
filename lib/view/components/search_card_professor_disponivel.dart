import 'package:bia/view-model/professor_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_button.dart';

// search card for professores when linking professor to vaga

class SearchCardProfessorDisponivel extends StatefulWidget {
  const SearchCardProfessorDisponivel({
    super.key,
  });

  @override
  State<SearchCardProfessorDisponivel> createState() =>
      _SearchCardProfessorDisponivelState();
}

class _SearchCardProfessorDisponivelState
    extends State<SearchCardProfessorDisponivel> {
  final searchController = TextEditingController();

  bool interessado = false;

  bool alfabetico = false;

  @override
  Widget build(BuildContext context) {
    // gets the provider for professores
    final ProfessorList professorList = Provider.of<ProfessorList>(context);

    return SizedBox(
      height: 160,
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
              child: TextField(
                // text field for filtering professor by name
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar por Professor',
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
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [],
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
                      professorList.filterItems(
                        name: searchController.text.toUpperCase(),
                        alfabetico: alfabetico,
                      );
                    },
                    child: const Text('Buscar'),
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
