import 'package:bia/model/models/concedente.dart';
import 'package:bia/view/pages/concedentes/concedente_update.dart';
import 'package:flutter/material.dart';

import 'concedente_create.dart';
import 'concedente_view.dart';

// this page decides wich concedente screen to show

class ConcedentePage extends StatefulWidget {
  const ConcedentePage({super.key});

  @override
  State<ConcedentePage> createState() => _ConcedentePageState();
}

class _ConcedentePageState extends State<ConcedentePage> {
  int _selectedScreenIndex = 0;
  Concedente? _concedente;

  // function used to change wich screen to show
  // the concedente parameter is necessary for the update page
  void _changeScreen(int index, {Concedente? concedente}) {
    setState(() {
      _selectedScreenIndex = index;
      _concedente = concedente;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Concedentes'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _selectedScreenIndex == 0
          ? ConcedenteView(_changeScreen)
          : _selectedScreenIndex == 1
              ? ConcedenteCreate(_changeScreen, _concedente)
              : ConcedenteUpdate(_changeScreen, _concedente!),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          if (value != 2 || _concedente != null) {
            _changeScreen(value, concedente: _concedente);
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
            label: 'Concedentes',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Cadastrar',
          ),
          if (_concedente != null)
            const BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Editar',
            ),
        ],
      ),
    );
  }
}
