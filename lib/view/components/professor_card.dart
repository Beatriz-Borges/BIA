import 'package:bia/view/components/card_component.dart';
import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text.dart';
import 'package:bia/model/models/curso.dart';
import 'package:bia/model/models/professor.dart';
import 'package:bia/model/models/vaga.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:bia/view-model/professor_list.dart';
import 'package:bia/view-model/vaga_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfessorCard extends StatelessWidget {
  final Professor professor;
  final Vaga? vaga;
  final Function selectScreen;
  const ProfessorCard({
    required this.professor,
    this.vaga,
    required this.selectScreen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // gets width available of the screen
    final maxWidth = MediaQuery.of(context).size.width;

    // gets the curso that the professor coordena if exists
    final Curso? curso =
        Provider.of<CursoList>(context).getCurso(professor.cursoId);

    // gets the list of vagas id the professor is linked to
    final List<Vaga> vagasProfessor =
        Provider.of<VagaList>(context).getVagas(professor.vagasId);

    // gets the função of vagas the professor is linked to
    final List<String> vagas = [];
    for (var vaga in vagasProfessor) {
      vagas.add(vaga.funcao);
    }

    // gets the provider for professores
    final ProfessorList professorList = Provider.of<ProfessorList>(context);

    // gets the id of the coordenador de curso
    final cExtensaoId = ProfessorList.cExtensaoId;

    // function that checks if the button for the coordenador de
    // extensão is visible
    final bool validForExtensao =
        ['CGTI'].contains(AuthService().currentUser!.tipo) &&
            (cExtensaoId == '' || professor.isCoordenadorExtensao);

    // widget to control the size used by the string of the list of vagas
    final tp = TextPainter(
        text: TextSpan(text: vagas.toString()),
        textDirection: TextDirection.ltr);
    tp.layout(maxWidth: maxWidth - 50);

    void deleta() {
      final professorList = Provider.of<ProfessorList>(context, listen: false);
      professorList.delete(professor.id);
    }

    return CardComponent(
      titulo: professor.nome.toUpperCase(),
      tituloColor: professor.isCoordenadorExtensao
          ? Theme.of(context).colorScheme.primary
          : Colors.grey,
      cardSize:
          vaga != null || validForExtensao ? 122 + tp.height : tp.height + 90,
      onDelete: curso != null ||
              vagasProfessor.isNotEmpty ||
              cExtensaoId == professor.id ||
              vaga != null
          // the delete button doesn't appear if the professor is
          // coordenador de curso or coordenador de extensão or if they
          // are linked to any vagas
          ? null
          : () async {
              bool? confirmado = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Tem certeza?'),
                  content: Text(
                    'Remover o Professor "${professor.nome}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                      child: const Text('Não'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                      },
                      child: const Text('Sim'),
                    ),
                  ],
                ),
              );
              if (confirmado == true) {
                deleta();
              }
            },
      onEdit: vaga != null
          ? null
          : () {
              selectScreen(2, professor: professor);
            },
      children: [
        CustomText(
          title: 'E-mail: ',
          text: professor.email,
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Telefone: ',
          text: professor.telefone,
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Siape: ',
          text: professor.siap,
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Vagas: ',
          text: vagas.toString(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // the button to link to a vaga
            // only appears if the user came from the vaga screen
            if (vaga != null)
              CustomButton(
                onPressed: () {
                  Provider.of<VagaList>(context, listen: false)
                      .vinculaProfessor(vaga!.id, professor.id);
                  professorList.vinculaVaga(professor.id, vaga!.id);
                  Navigator.pop(context);
                },
                child: const Text('Vincular'),
              ),
          ],
        ),
        // doesn't appear if the user came from the vaga screen
        // button appears either to the coordenador de extensão or to
        // every professor depending if the coordenador de extensão
        // already exists
        if (validForExtensao && vaga == null)
          Column(
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                      title: 'Coordenador de Extensão: ',
                      text: cExtensaoId != '' ? 'sim' : 'não'),
                  CustomButton(
                    onPressed: () async {
                      await professorList.setCoordenadorExtensao(
                          cExtensaoId != '' ? '' : professor.id);
                    },
                    child: Text(cExtensaoId != '' ? 'Remover' : 'Adicionar'),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
