import 'package:bia/view/components/search_card_professor_disponivel.dart';
import 'package:bia/model/models/vaga.dart';
import 'package:bia/view-model/professor_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/professor_card.dart';

// the screen that shows professores allowed to be linked to vaga

class ProfessoresDisponiveis extends StatefulWidget {
  const ProfessoresDisponiveis({super.key});

  @override
  State<ProfessoresDisponiveis> createState() => _ProfessoresDisponiveisState();
}

class _ProfessoresDisponiveisState extends State<ProfessoresDisponiveis> {
  Function? resetFilter;

  @override
  void initState() {
    Provider.of<ProfessorList>(context, listen: false).loadProfessores();
    super.initState();
  }

  @override
  void dispose() {
    // Not sure what this does, but it fixes a error
    // it seems that makes the building of the page to wait for the
    // function to finish
    WidgetsBinding.instance.addPostFrameCallback((_) => resetFilter!());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // gets vaga from route transition
    final vaga = ModalRoute.of(context)?.settings.arguments as Vaga;

    // gets provider for professores
    final professorList = Provider.of<ProfessorList>(context);

    resetFilter = () {
      professorList.filterItems();
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vincular professor'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          const SearchCardProfessorDisponivel(),
          Expanded(
            child: ListView.builder(
              itemCount: professorList.filteredItems.length,
              itemBuilder: (context, index) {
                return ProfessorCard(
                  professor: professorList.filteredItems[index],
                  selectScreen: () {},
                  vaga: vaga,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
