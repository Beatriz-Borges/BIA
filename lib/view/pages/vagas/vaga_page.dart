import 'package:bia/model/models/vaga.dart';
import 'package:bia/view/pages/vagas/vaga_update.dart';
import 'package:bia/view/pages/vagas/vaga_view.dart';
import 'package:bia/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'vaga_create.dart';

// this page decides wich vaga screen to show

class VagaPage extends StatefulWidget {
  const VagaPage({super.key});

  @override
  State<VagaPage> createState() => _VagaPageState();
}

class _VagaPageState extends State<VagaPage> {
  int _selectedScreenIndex = 0;
  Vaga? _vaga;

  // function used to change wich screen to show
  // the vaga parameter is necessary for the update page
  void _changeScreen(int index, {Vaga? vaga}) {
    setState(() {
      _selectedScreenIndex = index;
      _vaga = vaga;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? concedente =
        ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vagas'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _selectedScreenIndex == 0
          ? VagaView(_changeScreen, concedente)
          : _selectedScreenIndex == 1
              ? VagaCreate(_changeScreen, _vaga)
              : VagaUpdate(_changeScreen, _vaga!),
      bottomNavigationBar: ['Aluno'].contains(AuthService().currentUser!.tipo)
          ? null
          : BottomNavigationBar(
              onTap: (value) {
                if (value != 2 || _vaga != null) {
                  _changeScreen(value, vaga: _vaga);
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
                  label: 'Vagas',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'Cadastrar',
                ),
                if (_vaga != null)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.edit),
                    label: 'Editar',
                  ),
              ],
            ),
    );
  }
}
