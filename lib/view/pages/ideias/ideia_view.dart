import 'package:bia/view/components/ideia_card.dart';
import 'package:bia/view/components/search_card_ideia.dart';
import 'package:bia/view-model/ideia_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// the screen that shows the ideia

class IdeiaView extends StatefulWidget {
  final Function selectScreen;
  const IdeiaView(this.selectScreen, {super.key});

  @override
  State<IdeiaView> createState() => _IdeiaViewState();
}

class _IdeiaViewState extends State<IdeiaView> {
  Function? resetFilter;

  @override
  void initState() {
    Provider.of<IdeiaList>(context, listen: false).loadIdeias();
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
    final ideiaList = Provider.of<IdeiaList>(context);

    resetFilter = () {
      ideiaList.filterItems();
    };

    return Column(
      children: [
        const SearchCardIdeia(),
        Expanded(
          child: ListView.builder(
            itemCount: ideiaList.filteredItems.length,
            itemBuilder: (context, index) {
              return IdeiaCard(
                ideia: ideiaList.filteredItems[index],
                selectScreen: widget.selectScreen,
              );
            },
          ),
        ),
      ],
    );
  }
}
