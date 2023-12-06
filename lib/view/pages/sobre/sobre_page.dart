import 'package:bia/model/models/sobre.dart';
import 'package:bia/view/pages/sobre/sobre_create.dart';
import 'package:bia/view/pages/sobre/sobre_update.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/view/pages/sobre/sobre_view.dart';
import 'package:flutter/material.dart';

// this page decides wich sobre screen to show

class SobrePage extends StatefulWidget {
  const SobrePage({super.key});

  @override
  State<SobrePage> createState() => _SobrePageState();
}

class _SobrePageState extends State<SobrePage> {
  int _selectedScreenIndex = 0;
  Sobre? _sobre;

  // function used to change wich screen to show
  // the sobre parameter is necessary for the update page
  void _changeScreen(int index, {Sobre? sobre}) {
    setState(() {
      _selectedScreenIndex = index;
      _sobre = sobre;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser!;
    final List<Widget> pages = [
      SobreView(_changeScreen),
      SobreCreate(_changeScreen, null),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _selectedScreenIndex != 2
          ? pages[_selectedScreenIndex]
          : SobreUpdate(_changeScreen, _sobre!),
      bottomNavigationBar: ['Professor', 'Aluno'].contains(user.tipo) &&
              !user.isCoordenadorExtensao
          ? null
          : BottomNavigationBar(
              onTap: (value) {
                _changeScreen(value);
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Colors.white,
              selectedItemColor: Theme.of(context).colorScheme.tertiary,
              currentIndex: _selectedScreenIndex,
              elevation: 10,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'sobre',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'Cadastrar',
                ),
                if (_sobre != null)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.edit),
                    label: 'Editar',
                  ),
              ],
            ),
    );
  }
}
