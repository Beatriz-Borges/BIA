import 'package:bia/view/components/professor_card.dart';
import 'package:bia/view/components/search_card_professor.dart';
import 'package:bia/view-model/professor_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// the screen that shows the alunos

class ProfessorView extends StatefulWidget {
  final Function selectScreen;
  const ProfessorView(this.selectScreen, {super.key});

  @override
  State<ProfessorView> createState() => _ProfessorViewState();
}

class _ProfessorViewState extends State<ProfessorView> {
  Function? resetFilter;

  @override
  void initState() {
    // gets provider for professores
    Provider.of<ProfessorList>(context, listen: false).loadProfessores();

    // Not sure what this does, but it fixes a error
    // it seems that makes the building of the page to wait for the
    // function to finish
    WidgetsBinding.instance.addPostFrameCallback((_) => resetFilter!());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final professorList = Provider.of<ProfessorList>(context);

    resetFilter = () {
      professorList.filterItems();
    };

    return Column(
      children: [
        const SearchCardProfessor(),
        Expanded(
          child: ListView.builder(
            itemCount: professorList.filteredItems.length,
            itemBuilder: (context, index) {
              return ProfessorCard(
                professor: professorList.filteredItems[index],
                selectScreen: widget.selectScreen,
              );
            },
          ),
        ),
      ],
    );
  }
}
