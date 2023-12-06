import 'package:bia/model/models/professor.dart';
import 'package:bia/view/pages/professores/professor_create.dart';
import 'package:bia/view/pages/professores/professor_import.dart';
import 'package:bia/view/pages/professores/professor_update.dart';
import 'package:bia/view/pages/professores/professor_view.dart';
import 'package:bia/services/auth_service.dart';
import 'package:flutter/material.dart';

// this page decides wich professor screen to show

class ProfessorPage extends StatefulWidget {
  const ProfessorPage({super.key});

  @override
  State<ProfessorPage> createState() => _ProfessorPageState();
}

class _ProfessorPageState extends State<ProfessorPage> {
  int _selectedScreenIndex = 0;
  Professor? _professor;

  // function used to change wich screen to show
  // the professor parameter is necessary for the update page
  void _changeScreen(int index, {Professor? professor}) {
    setState(() {
      _selectedScreenIndex = index;
      _professor = professor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ProfessorView(_changeScreen),
      ProfessorCreate(_changeScreen, null),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professores'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _selectedScreenIndex != 2
          ? pages[_selectedScreenIndex]
          : _professor == null
              ? ProfessorImport(_changeScreen, null)
              : ProfessorUpdate(_changeScreen, _professor!),
      bottomNavigationBar: BottomNavigationBar(
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
            label: 'Professors',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Cadastrar',
          ),
          if (_professor == null &&
              ['CGTI'].contains(AuthService().currentUser!.tipo))
            const BottomNavigationBarItem(
              icon: Icon(Icons.import_contacts),
              label: 'Importar',
            ),
          if (_professor != null)
            const BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Editar',
            ),
        ],
      ),
    );
  }
}
