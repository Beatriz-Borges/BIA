import 'package:bia/view-model/sobre_list.dart';
import 'package:bia/view/components/sobre_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// the screen that shows the sobre

class SobreView extends StatefulWidget {
  final Function selectScreen;
  const SobreView(this.selectScreen, {super.key});

  @override
  State<SobreView> createState() => _SobreViewState();
}

class _SobreViewState extends State<SobreView> {
  Function? resetFilter;

  @override
  void initState() {
    Provider.of<SobreList>(context, listen: false).loadSobre();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sobreList = Provider.of<SobreList>(context);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: sobreList.items.length,
            itemBuilder: (context, index) {
              return SobreCard(
                sobre: sobreList.items[index],
                selectScreen: widget.selectScreen,
              );
            },
          ),
        ),
      ],
    );
  }
}
