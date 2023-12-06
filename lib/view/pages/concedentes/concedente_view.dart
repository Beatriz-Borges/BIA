import 'package:bia/view/components/search_card_concedente.dart';
import 'package:bia/view-model/concedente_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/concedente_card.dart';

// the screen that shows the concedentes

class ConcedenteView extends StatefulWidget {
  final Function selectScreen;
  const ConcedenteView(this.selectScreen, {super.key});

  @override
  State<ConcedenteView> createState() => _ConcedenteViewState();
}

class _ConcedenteViewState extends State<ConcedenteView> {
  Function? resetFilter;

  @override
  void initState() {
    Provider.of<ConcedenteList>(context, listen: false).loadConcedentes();
    super.initState();
  }

  @override
  void dispose() {
    // Not sure what this does, but it fixes a error
    // it seems that makes the building of the page to wait for the
    // function to finish
    WidgetsBinding.instance.addPostFrameCallback((_) => resetFilter!());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final concedenteList = Provider.of<ConcedenteList>(context);

    resetFilter = () {
      concedenteList.filterItems();
    };

    return Column(
      children: [
        const SearchCardConcedente(),
        Expanded(
          child: ListView.builder(
            itemCount: concedenteList.filteredItems.length,
            itemBuilder: (context, index) {
              return ConcedenteCard(
                concedente: concedenteList.filteredItems[index],
                selectScreen: widget.selectScreen,
              );
            },
          ),
        ),
      ],
    );
  }
}
