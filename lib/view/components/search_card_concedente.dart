import 'package:bia/view-model/concedente_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_button.dart';

class SearchCardConcedente extends StatefulWidget {
  const SearchCardConcedente({super.key});

  @override
  State<SearchCardConcedente> createState() => _SearchCardConcedenteState();
}

class _SearchCardConcedenteState extends State<SearchCardConcedente> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ConcedenteList concedenteList = Provider.of<ConcedenteList>(context);

    return SizedBox(
      height: 160,
      child: Card(
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
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
                // text field for filtering concedentes by name
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar por Concedente',
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
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: CustomButton(
                    //button to apply filters
                    onPressed: () {
                      concedenteList.filterItems(
                        nome: searchController.text,
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
