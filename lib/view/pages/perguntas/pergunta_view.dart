import 'package:bia/view/components/pergunta_card.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/view-model/pergunta_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// the screen that shows the perguntas

class PerguntaView extends StatefulWidget {
  final Function selectScreen;
  const PerguntaView(this.selectScreen, {super.key});

  @override
  State<PerguntaView> createState() => _PerguntaViewState();
}

class _PerguntaViewState extends State<PerguntaView> {
  @override
  void initState() {
    Provider.of<PerguntaList>(context, listen: false).loadPerguntas();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final perguntaList = Provider.of<PerguntaList>(context);
    final user = AuthService().currentUser!;

    return Column(
      children: [
        if (['CGTI'].contains(user.tipo) || user.isCoordenadorExtensao)
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: FittedBox(
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.green),
                  Text(
                    'Segure e arraste um card para reorganizar as perguntas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: ['CGTI'].contains(user.tipo) || user.isCoordenadorExtensao
              ? ReorderableListView.builder(
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      perguntaList.reorderList(oldIndex, newIndex);
                    });
                  },
                  itemCount: perguntaList.items.length,
                  itemBuilder: (context, index) {
                    return PerguntaCard(
                      key: Key(perguntaList.items[index].pergunta),
                      pergunta: perguntaList.items[index],
                      selectScreen: widget.selectScreen,
                    );
                  },
                )
              : ListView.builder(
                  itemCount: perguntaList.itemsCount,
                  itemBuilder: (context, index) {
                    return PerguntaCard(
                      key: Key(perguntaList.items[index].pergunta),
                      pergunta: perguntaList.items[index],
                      selectScreen: widget.selectScreen,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
