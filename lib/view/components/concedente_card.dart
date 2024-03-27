import 'package:bia/view/components/card_component.dart';
import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text.dart';
import 'package:bia/utils/app_routes.dart';
import 'package:bia/view-model/concedente_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/models/concedente.dart';

// the widget

class ConcedenteCard extends StatelessWidget {
  final Concedente concedente;
  final Function selectScreen;
  const ConcedenteCard({
    required this.concedente,
    required this.selectScreen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    void deleta() {
      final concedenteList =
          Provider.of<ConcedenteList>(context, listen: false);
      concedenteList.delete(concedente.id);
    }

    return CardComponent(
      titulo: concedente.nome.toUpperCase(),
      cardSize: 260,
      onDelete: () async {
        bool? confirmado = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Tem certeza?'),
            content: Text(
              'Remover o concedente "${concedente.nome}"?',
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
      onEdit: () {
        selectScreen(2, concedente: concedente);
      },
      children: [
        const Text(
          'Informações do responsável:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Nome: ',
          text: concedente.responsavel,
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Telefone: ',
          text: concedente.telefoneResponsavel,
        ),
        const SizedBox(height: 10),
        const Text(
          'Contato da empresa:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        CustomText(
          title: 'Nome: ',
          text: concedente.nome,
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'CNPJ: ',
          text: concedente.cnpj,
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'E-mail: ',
          text: concedente.email,
        ),
        const SizedBox(height: 8),
        CustomText(
          title: 'Telefone: ',
          text: concedente.telefoneEmpresa,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const Text(
                  'Estágio ofertado:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Curricular           ',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Extra-Curricular ',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                ),
              ],
            ),
            // button that leads to the vagas that are linked to the concedente
            CustomButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.vaga,
                  arguments: concedente.id,
                );
              },
              child: const Text('Vagas'),
            ),
          ],
        ),
      ],
    );
  }
}
