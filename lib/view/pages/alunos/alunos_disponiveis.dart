import 'package:bia/view/components/search_card_disponiveis.dart';
import 'package:bia/model/models/vaga.dart';
import 'package:bia/view-model/aluno_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/aluno_card.dart';
import '../../../model/models/aluno.dart';

// the screen that shows alunos allowed to be linked to vaga

class AlunosDisponiveis extends StatefulWidget {
  const AlunosDisponiveis({super.key});

  @override
  State<AlunosDisponiveis> createState() => _AlunosDisponiveisState();
}

class _AlunosDisponiveisState extends State<AlunosDisponiveis> {
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
    // gets vaga from the route transition
    final vaga = ModalRoute.of(context)?.settings.arguments as Vaga;

    // gets provider for alunos
    final alunoListProvider = Provider.of<AlunoList>(context);

    // gets list of alunos that can be linked to the vaga
    final alunoList = alunoListProvider.filteredItems.where((a) {
      final bool disponivel = vaga.curricular
          ? a.eCurricular == false
          : a.eExtraCurricular == false;
      return a.vagaId == null && a.cursoId == vaga.cursoId && disponivel;
    }).toList();

    resetFilter = () {
      alunoListProvider.filterItems();
    };

    // gets aluno highest priority
    int getPrioridade(List<Aluno> alunos) {
      int prioridade = 0;
      for (var aluno in alunos) {
        if (prioridade < aluno.prioridadeInt) {
          prioridade = aluno.prioridadeInt;
        }
      }
      return prioridade;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vincular Aluno'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          SearchCardDisponivel(
            vaga: vaga,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: vaga.curricular
                  // if vaga is curricular, them only show alunos with
                  // highest priority value
                  ? alunoList
                      .where((aluno) =>
                          aluno.prioridadeInt == getPrioridade(alunoList))
                      .length
                  : alunoList.length,
              itemBuilder: (context, index) {
                return AlunoCard(
                  aluno: vaga.curricular
                      // if vaga is curricular, them only show alunos with
                      // highest priority value
                      ? alunoList
                          .where((aluno) =>
                              aluno.prioridadeInt == getPrioridade(alunoList))
                          .toList()[index]
                      : alunoList[index],
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
