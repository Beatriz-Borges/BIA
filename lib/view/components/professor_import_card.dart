import 'package:bia/view/components/card_component.dart';
import 'package:bia/view/components/custom_text.dart';
import 'package:bia/model/models/professor.dart';
import 'package:bia/view-model/professor_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// this is the same component as professor card but with some changes
// to the import screen

class ProfessorImportCard extends StatelessWidget {
  final Professor professor;
  const ProfessorImportCard({
    required this.professor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    void deleta() {
      final professorList = Provider.of<ProfessorList>(context, listen: false);
      professorList.delete(professor.id);
    }

    return CardComponent(
      titulo: professor.nome.toUpperCase(),
      cardSize: 70,
      onDelete: () async {
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
      ],
    );
  }
}
