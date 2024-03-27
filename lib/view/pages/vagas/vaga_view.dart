import 'package:bia/view-model/vaga_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/search_card_vaga.dart';
import '../../components/vaga_card.dart';

// the screen that shows the vagas

class VagaView extends StatefulWidget {
  final Function selectScreen;
  final String? concedenteId;
  const VagaView(this.selectScreen, this.concedenteId, {super.key});

  @override
  State<VagaView> createState() => _VagaViewState();
}

class _VagaViewState extends State<VagaView> {
  Function? resetFilter;
  Function? concedenteFilter;
  bool isLoading = false;

  @override
  void initState() {
    final vagaList = Provider.of<VagaList>(context, listen: false);
    // Not sure what this does, but it fixes a error
    // it seems that makes the building of the page to wait for the
    // function to finish
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        setState(() {
          isLoading = true;
        });
        await vagaList.loadVagas(concedenteId: widget.concedenteId);
        setState(() {
          isLoading = false;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final vagaList = Provider.of<VagaList>(context);

    resetFilter = () {
      vagaList.filterItems();
    };

    return RefreshIndicator(
      // adds a pull to refresh feature to the screen
      onRefresh: () async {
        isLoading = true;
        await vagaList.loadVagas();
        isLoading = false;
      },
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      child: Column(
        children: [
          const SearchCardVaga(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: vagaList.filteredItems.length,
                    itemBuilder: (context, index) {
                      return VagaCard(
                        vaga: vagaList.filteredItems[index],
                        selectScreen: widget.selectScreen,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
