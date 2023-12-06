import 'package:bia/view/components/card_component.dart';
import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text.dart';
import 'package:bia/model/models/aluno.dart';
import 'package:bia/model/models/concedente.dart';
import 'package:bia/model/models/curso.dart';
import 'package:bia/model/models/professor.dart';
import 'package:bia/model/models/vaga.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/utils/app_routes.dart';
import 'package:bia/view-model/aluno_list.dart';
import 'package:bia/view-model/concedente_list.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:bia/view-model/professor_list.dart';
import 'package:bia/view-model/vaga_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VagaCard extends StatefulWidget {
  final Vaga vaga;
  final Function selectScreen;
  const VagaCard({
    required this.selectScreen,
    required this.vaga,
    super.key,
  });

  @override
  State<VagaCard> createState() => _VagaCardState();
}

class _VagaCardState extends State<VagaCard> {
  @override
  Widget build(BuildContext context) {
    // gets current user
    final user = AuthService().currentUser!;

    // gets provider fot vagas
    final vagaList = Provider.of<VagaList>(context, listen: false);

    // gets provider for alunos
    final alunoList = Provider.of<AlunoList>(context, listen: false);

    // gets provider for professores
    final professorList = Provider.of<ProfessorList>(context, listen: false);

    // gets width available of the screen
    final maxWidth = MediaQuery.of(context).size.width;

    // gets the concedente linked to vaga
    final Concedente? concedente =
        Provider.of<ConcedenteList>(context, listen: false)
            .getConcedente(widget.vaga.concedenteId);

    // gets curso linked to vaga
    final Curso? curso = Provider.of<CursoList>(context, listen: false)
        .getCurso(widget.vaga.cursoId);

    // gets aluno linked to vaga if it exists
    final Aluno? aluno = alunoList.getAluno(widget.vaga.alunoId);

    // gets professor linked to vaga if it exists
    final Professor? professor =
        professorList.getProfessor(widget.vaga.professorId);

    void desvinculaAluno() {
      if (aluno == null) return;

      vagaList.desvinculaAluno(widget.vaga.id);
      alunoList.desvinculaVaga(aluno.id);
    }

    void desvinculaProfessor() {
      if (professor == null) return;

      vagaList.desvinculaProfessor(widget.vaga.id);
      professorList.desvinculaVaga(professor.id, widget.vaga.id);
    }

    void deleta() {
      desvinculaAluno();
      desvinculaProfessor();
      vagaList.delete(widget.vaga.id);
    }

    // widget to control the size used by descrição text
    final tp = TextPainter(
        text: TextSpan(text: widget.vaga.descricao),
        textDirection: TextDirection.ltr);
    tp.layout(maxWidth: maxWidth - 50);

    return CardComponent(
      titulo: widget.vaga.funcao.toUpperCase(),
      cardSize: widget.vaga.curricular ? tp.height + 206 : tp.height + 165,
      onDelete: ['Aluno'].contains(user.tipo)
          // delete button doesn't appear if user is an aluno
          ? null
          : () async {
              bool? confirmado = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Tem certeza?'),
                  content: Text(
                    'Remover a vaga "${widget.vaga.funcao}" ira desvincular qualquer aluno ou professor vinculado a ela.',
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
      onEdit: ['Professor', 'Aluno'].contains(user.tipo) &&
              !user.isCoordenadorExtensao
          // edit button only appears to coordenador de extensão
          ? null
          : () {
              widget.selectScreen(2, vaga: widget.vaga);
            },
      children: [
        const Text(
          'Informações deste estágio:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        CustomText(
          title: 'Tipo: ',
          text: widget.vaga.curricular ? 'Curricular' : 'Extra-Curricular',
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Concedente: ',
          text: concedente?.nome ?? '',
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Curso: ',
          text: curso?.nome ?? '',
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Remuneração: ',
          text: widget.vaga.remuneracao.toStringAsFixed(2),
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Descrição: ',
          text: widget.vaga.descricao,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              title: 'Aluno vinculado: ',
              text: aluno == null
                  ? ''
                  : aluno.nome.length >= 35
                      ? '${aluno.nome.substring(0, 33)}...'
                      : aluno.nome,
            ),
            if (aluno == null)
              ['Aluno'].contains(user.tipo)
                  // if the user is an aluno them it will appear a button
                  // for them to show interest in a vaga
                  ? CustomButton(
                      onPressed: () {
                        widget.vaga.interessados.contains(user.tipoId)
                            ? vagaList.removeInteressado(
                                widget.vaga.id, user.tipoId)
                            : vagaList.addInteressado(
                                widget.vaga.id, user.tipoId);
                      },
                      child: Text(
                        widget.vaga.interessados.contains(user.tipoId)
                            ? 'Remover interesse'
                            : 'Demonstrar interesse',
                        style: const TextStyle(fontSize: 11),
                      ),
                    )
                  : CustomButton(
                      // if the users is CGTI or coordenador de extensão
                      // it will show the button to link aluno to vaga
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.alunoDisponivel,
                          arguments: widget.vaga,
                        );
                      },
                      child: const Text(
                        'Alunos disponíveis',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
            if (aluno != null)
              // if the is a aluno linked to the vaga, it will appear a
              // button to remove the aluno
              IconButton(
                onPressed: () async {
                  desvinculaAluno();
                  await vagaList.loadVagas();
                },
                icon: const Icon(Icons.delete),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.vaga.curricular)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                title: 'Orientador: ',
                text: professor == null
                    ? ''
                    : professor.nome.length >= 35
                        ? '${professor.nome.substring(0, 33)}...'
                        : professor.nome,
              ),
              if (professor == null)
                // if there isn't a professor linked to the vaga
                // it will show a button to link professor to vaga
                CustomButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.professorDisponivel,
                      arguments: widget.vaga,
                    );
                  },
                  child: const Text(
                    'Professores disponíveis',
                    style: TextStyle(
                        fontSize: 11, overflow: TextOverflow.ellipsis),
                  ),
                ),
              if (professor != null)
                // if there is a professor linked to vaga them the
                // button to remove professor will be shown
                IconButton(
                  onPressed: () async {
                    desvinculaProfessor();
                    await vagaList.loadVagas();
                    vagaList.loadVagas();
                  },
                  icon: const Icon(Icons.delete),
                ),
            ],
          ),
      ],
    );
  }
}
