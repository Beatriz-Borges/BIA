import 'package:bia/view/components/card_component.dart';
import 'package:bia/model/models/pergunta.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/view-model/pergunta_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PerguntaCard extends StatelessWidget {
  final Pergunta pergunta;
  final Function selectScreen;
  const PerguntaCard({
    required this.pergunta,
    required this.selectScreen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // gets the current user
    final user = AuthService().currentUser!;

    // gets the width available of the screen
    final maxWidth = MediaQuery.of(context).size.width;

    // widget to control the size used by the resposta text
    final tp = TextPainter(
      text: TextSpan(text: pergunta.resposta),
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: maxWidth - 50);

    void deleta() {
      final alunoList = Provider.of<PerguntaList>(context, listen: false);
      alunoList.delete(pergunta.id);
    }

    return CardComponent(
      titulo: pergunta.pergunta.toUpperCase(),
      cardSize: tp.height + 10,
      onDelete: ['Coordenador de Curso', 'CGTI'].contains(user.tipo) ||
              user.isCoordenadorExtensao
          ? () async {
              bool? confirmado = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Tem certeza?'),
                  content: Text(
                    'Remover a pergunta "${pergunta.pergunta}"?',
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
          // edit button appears for CGTI and the coordenador de
          // extensão
          ? () {
              selectScreen(2, pergunta: pergunta);
            }
          : null,
      children: [
        Text(
          pergunta.resposta,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
