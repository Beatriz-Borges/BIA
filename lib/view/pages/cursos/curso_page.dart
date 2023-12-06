import 'package:bia/model/models/curso.dart';
import 'package:bia/view/pages/cursos/curso_update.dart';
import 'package:bia/view/pages/cursos/curso_view.dart';
import 'package:bia/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'curso_create.dart';

// this page decides wich curso screen to show

class CursoPage extends StatefulWidget {
  const CursoPage({super.key});

  @override
  State<CursoPage> createState() => _CursoPageState();
}

class _CursoPageState extends State<CursoPage> {
  int _selectedScreenIndex = 0;
  Curso? _curso;

  // function used to change wich screen to show
  // the curso parameter is necessary for the update page
  void _changeScreen(int index, {Curso? curso}) {
    setState(() {
      _selectedScreenIndex = index;
      _curso = curso;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _selectedScreenIndex == 0
          ? CursoView(_changeScreen)
          : _selectedScreenIndex == 1
              ? CursoCreate(_changeScreen, _curso)
              : CursoUpdate(_changeScreen, _curso!),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          if (['CGTI'].contains(user.tipo) || user.isCoordenadorExtensao) {
            _changeScreen(value, curso: _curso);
          } else {
            _changeScreen(0, curso: _curso);
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
            label: 'cursos',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Cadastrar',
          ),
          if (_curso != null)
            const BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Editar',
            ),
        ],
      ),
    );
  }
}
