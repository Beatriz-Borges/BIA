import 'package:bia/view/components/card_component.dart';
import 'package:bia/view/components/custom_text.dart';
import 'package:bia/model/models/curso.dart';
import 'package:bia/model/models/professor.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:bia/view-model/professor_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CursoCard extends StatelessWidget {
  final Curso curso;
  final Function selectScreen;
  const CursoCard({
    required this.selectScreen,
    required this.curso,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // gets the current user
    final user = AuthService().currentUser!;

    // gets the coordenador do curso if it exists
    final Professor? professor =
        Provider.of<ProfessorList>(context, listen: false)
            .getProfessor(curso.coordenadorId);

    void deleta() {
      final cursoList = Provider.of<CursoList>(context, listen: false);
      cursoList.delete(curso.id);
    }

    return CardComponent(
      titulo: curso.nome.toUpperCase(),
      cardSize: 80,
      onDelete: (['CGTI'].contains(user.tipo) || user.isCoordenadorExtensao) &&
              professor == null
          // the delete button appears if the user is CGTI or the
          // coordenador de extensao and the curso doesn't have a
          // coordenador de curso
          ? () async {
              bool? confirmado = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Tem certeza?'),
                  content: Text(
                    'Remover o curso "${curso.nome}"?',
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
      onEdit: ['CGTI'].contains(user.tipo) || user.isCoordenadorExtensao
          // the edit button appears if the user is CGTI or the
          // coordenador de extensao
          ? () {
              selectScreen(2, curso: curso);
            }
          : null,
      children: [
        CustomText(
          title: 'Coordenador de curso: ',
          text: professor?.nome ?? '',
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Sigla: ',
          text: curso.sigla.toUpperCase(),
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Tipo: ',
          text: curso.nivel,
        ),
      ],
    );
  }
}
