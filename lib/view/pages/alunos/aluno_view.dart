import 'package:bia/view/components/aluno_card.dart';
import 'package:bia/view/components/search_card.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/view-model/aluno_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// the screen that shows the alunos

class AlunoView extends StatefulWidget {
  final Function selectScreen;
  const AlunoView(this.selectScreen, {super.key});

  @override
  State<AlunoView> createState() => _AlunoViewState();
}

class _AlunoViewState extends State<AlunoView> {
  Function? resetFilter;

  @override
  void initState() {
    Provider.of<AlunoList>(context, listen: false).loadAlunos();
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
    final alunoList = Provider.of<AlunoList>(context);
    final user = AuthService().currentUser!;

    resetFilter = () {
      alunoList.filterItems();
    };

    return Column(
      children: [
        if (['Professor', 'CGTI'].contains(user.tipo) ||
            user.isCoordenadorExtensao)
          const SearchCard(),
        Expanded(
          child: ListView.builder(
            itemCount: alunoList.filteredItems.length,
            itemBuilder: (context, index) {
              return AlunoCard(
                aluno: alunoList.filteredItems[index],
                selectScreen: widget.selectScreen,
              );
            },
          ),
        ),
      ],
    );
  }
}
