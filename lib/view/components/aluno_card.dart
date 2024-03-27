import 'package:bia/view/components/card_component.dart';
import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text.dart';
import 'package:bia/model/models/aluno.dart';
import 'package:bia/model/models/curso.dart';
import 'package:bia/model/models/vaga.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/utils/app_routes.dart';
import 'package:bia/view-model/aluno_list.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:bia/view-model/vaga_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlunoCard extends StatelessWidget {
  final Aluno aluno;
  final Vaga? vaga;
  final Function selectScreen;
  const AlunoCard({
    required this.aluno,
    required this.selectScreen,
    this.vaga,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // get the current user
    final user = AuthService().currentUser!;

    // get aluno's priority"
    String prioridade = aluno.prioridade;

    final Curso? curso =
        Provider.of<CursoList>(context).getCurso(aluno.cursoId);
    final alunoList = Provider.of<AlunoList>(context, listen: false);
    final Vaga? vagaAluno =
        Provider.of<VagaList>(context, listen: false).getVaga(aluno.vagaId);

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
      alunoList.delete(aluno.id);
    }

    return CardComponent(
      titulo: aluno.nome.toUpperCase(),
      cardSize: 250,
      onDelete: vagaAluno != null ||
              vaga != null ||
              ['Professor', 'Aluno'].contains(user.tipo) &&
                  !user.isCoordenadorExtensao
          ? null
          : () async {
              // shows a popup screen to confirm de deletion
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
      onEdit: (['CGTI'].contains(user.tipo) ||
                  aluno.id == user.tipoId ||
                  user.isCoordenadorExtensao) &&
              vaga == null
          ? () {
              // goes to the edit screen
              selectScreen(2, aluno: aluno);
            }
          : null,
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

        // this field uses the aluno's priority info priviously setted
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
            Column(
              children: [
                const Text(
                  'Está Estagiando?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),

                // if the aluno currently has a vaga, it will user the
                // vaga's data, otherwise it will just say "Não"
                if (vagaAluno == null)
                  const Text(
                    'Não',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                if (vagaAluno != null)
                  Row(
                    children: [
                      Text(
                        vagaAluno.curricular
                            ? 'Curricular'
                            : 'Extra-Curricular',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    ],
                  ),

                // if the user got to this page through the vaga page the
                // button to link the aluno to the vaga will be visible
                if (vaga != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomButton(
                      onPressed: () {
                        // print(aluno.vagaId);
                        Provider.of<VagaList>(context, listen: false)
                            .vinculaAluno(vaga!.id, aluno.id);
                        alunoList.vinculaVaga(aluno.id, vaga!.id);
                        Navigator.pop(context);
                      },
                      child: const Text('Vincular'),
                    ),
                  ),

                // if the aluno is linked to a vaga curricular the button
                // to the processos page will be visible
                if ((['Professor', 'Aluno', 'CGTI'].contains(user.tipo) ||
                        user.isCoordenadorExtensao) &&
                    vagaAluno != null)
                  // if (vagaAluno.curricular)
                  CustomButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.processo,
                        arguments: aluno,
                      );
                    },
                    child: const Text('Processos'),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
