import 'package:bia/model/models/ideia.dart';
import 'package:bia/view/pages/ideias/ideia_create.dart';
import 'package:bia/view/pages/ideias/ideia_update.dart';
import 'package:bia/view/pages/ideias/ideia_view.dart';
import 'package:flutter/material.dart';

// this page decides wich ideia screen to show

class IdeiaPage extends StatefulWidget {
  const IdeiaPage({super.key});

  @override
  State<IdeiaPage> createState() => _IdeiaPageState();
}

class _IdeiaPageState extends State<IdeiaPage> {
  int _selectedScreenIndex = 0;
  Ideia? _ideia;

  // function used to change wich screen to show
  // the ideia parameter is necessary for the update page
  void _changeScreen(int index, {Ideia? ideia}) {
    setState(() {
      _selectedScreenIndex = index;
      _ideia = ideia;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ideias de Estágio'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _selectedScreenIndex == 0
          ? IdeiaView(_changeScreen)
          : _selectedScreenIndex == 1
              ? IdeiaCreate(_changeScreen, _ideia)
              : IdeiaUpdate(_changeScreen, _ideia!),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          if (value != 2 || _ideia != null) {
            _changeScreen(value);
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.white,
        selectedItemColor: Theme.of(context).colorScheme.tertiary,
        currentIndex: _selectedScreenIndex,
        elevation: 10,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Ideias',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Cadastrar',
          ),
          if (_ideia != null)
            const BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Editar',
            ),
        ],
      ),
    );
  }
}
