import 'package:bia/view/components/card_component.dart';
import 'package:bia/view/components/custom_text.dart';
import 'package:bia/model/models/aluno.dart';
import 'package:bia/model/models/curso.dart';
import 'package:bia/view-model/aluno_import_list.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// this is the same component as aluno_card but with some changes for
// the aluno import screen

class AlunoImportCard extends StatelessWidget {
  final Aluno aluno;
  const AlunoImportCard({
    required this.aluno,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // get aluno's priority
    String prioridade = aluno.prioridade;

    final Curso? curso =
        Provider.of<CursoList>(context).getCurso(aluno.cursoId);
    final alunoImportList =
        Provider.of<AlunoImportList>(context, listen: false);

    // Define the color used to show the aluno's priority
    Color corPrioridade = Theme.of(context).colorScheme.primary;
    if (prioridade == 'baixa') {
      corPrioridade = Colors.amber;
    } else if (prioridade == 'média') {
      corPrioridade = Colors.orange;
    } else if (prioridade == 'alta') {
      corPrioridade = Theme.of(context).colorScheme.tertiary;
    }

    void deleta() {
      alunoImportList.delete(aluno.matricula);
    }

    return CardComponent(
      titulo: aluno.nome.toUpperCase(),
      cardSize: 240,
      onDelete: () async {
        bool? confirmado = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Tem certeza?'),
            content: Text(
              'Remover o aluno "${aluno.nome}"?',
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
      children: [
        CustomText(
          title: 'E-mail: ',
          text: aluno.email,
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Telefone: ',
          text: aluno.telefone,
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Curso: ',
          text: curso != null ? curso.nome : 'Error',
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Matrícula: ',
          text: aluno.matricula.toUpperCase(),
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Ano de ingresso: ',
          text: aluno.ano.toString(),
        ),
        const SizedBox(height: 8),
        // this fild uses the aluno's priority info priviously setted
        CustomText(
          title: 'Prioridade em estágio-curricular: ',
          text: aluno.prioridade,
          cor: corPrioridade,
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estágio Completo?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Curricular           ',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      aluno.eCurricular
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Extra-Curricular ',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      aluno.eExtraCurricular
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                    ],
                  ),
                ),
              ],
            ),
            const Column(
              children: [
                Text(
                  'Está Estagiando?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Não',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
