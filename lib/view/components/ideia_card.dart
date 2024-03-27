import 'package:bia/view/components/card_component.dart';
import 'package:bia/view/components/custom_text.dart';
import 'package:bia/model/models/curso.dart';
import 'package:bia/model/models/ideia.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/view-model/aluno_list.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:bia/view-model/ideia_list.dart';
import 'package:bia/view-model/professor_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IdeiaCard extends StatelessWidget {
  final Ideia ideia;
  final Function selectScreen;
  const IdeiaCard({
    required this.ideia,
    required this.selectScreen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // gets the current user
    final user = AuthService().currentUser!;

    // ignore: prefer_typing_uninitialized_variables
    final usuario;
    String? coordenaCurso;

    // gets the data for the user depending on its type
    final Curso? curso =
        Provider.of<CursoList>(context).getCurso(ideia.cursoId);
    if (['Aluno'].contains(user.tipo)) {
      usuario =
          Provider.of<AlunoList>(context, listen: false).getAluno(user.tipoId);
    } else if (['Professor'].contains(user.tipo)) {
      usuario = Provider.of<ProfessorList>(context).getProfessor(user.tipoId);
      coordenaCurso = usuario.cursoId;
    } else {
      usuario = null;
    }

    // gets the width available of the screen
    final maxWidth = MediaQuery.of(context).size.width;

    // widget used to control the size used by the description text
    final tp = TextPainter(
      text: TextSpan(text: ideia.descricao),
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: maxWidth - 50);

    void deleta() {
      final alunoList = Provider.of<IdeiaList>(context, listen: false);
      alunoList.delete(ideia.id);
    }

    return CardComponent(
      titulo: ideia.titulo.toUpperCase(),
      cardSize: tp.height + 90,
      onDelete: ['CGTI'].contains(user.tipo) || user.isCoordenadorExtensao
          ? () async {
              bool? confirmado = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Tem certeza?'),
                  content: Text(
                    'Remover a ideia "${ideia.titulo}"?',
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
            }
          : null,
      onEdit: ['CGTI'].contains(user.tipo) ||
              user.tipoId == ideia.userId ||
              coordenaCurso == ideia.cursoId ||
              user.isCoordenadorExtensao
          // edit button appears to CGTI, the coordenador de
          // extensão, coordenador de curso (if the curso of the
          // ideia is the same) or if the user is the one that made
          // the ideia
          ? () {
              selectScreen(2, ideia: ideia);
            }
          : null,
      children: [
        CustomText(
          title: 'Curso: ',
          text: curso != null ? 'Curso: ${curso.nome}' : 'Error',
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 8),
        CustomText(
          title: 'Descrição: ',
          text: ideia.descricao,
        ),
      ],
    );
  }
}
