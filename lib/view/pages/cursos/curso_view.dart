import 'package:bia/view/components/curso_card.dart';
import 'package:bia/view/components/search_card_curso.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// the screen that shows the cursos

class CursoView extends StatefulWidget {
  final Function selectScreen;
  const CursoView(this.selectScreen, {super.key});

  @override
  State<CursoView> createState() => _CursoViewState();
}

class _CursoViewState extends State<CursoView> {
  Function? resetFilter;

  @override
  void initState() {
    Provider.of<CursoList>(context, listen: false).loadCursos();
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
    final CursoList cursoList = Provider.of<CursoList>(context);

    resetFilter = () {
      cursoList.filterItems();
    };

    return Column(
      children: [
        const SearchCardCurso(),
        Expanded(
          child: ListView.builder(
            itemCount: cursoList.filteredItems.length,
            itemBuilder: (context, index) {
              return CursoCard(
                curso: cursoList.filteredItems[index],
                selectScreen: widget.selectScreen,
              );
            },
          ),
        ),
      ],
    );
  }
}
