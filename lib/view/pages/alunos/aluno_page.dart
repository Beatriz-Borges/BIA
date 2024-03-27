import 'package:bia/model/models/aluno.dart';
import 'package:bia/view/pages/alunos/aluno_create.dart';
import 'package:bia/view/pages/alunos/aluno_import.dart';
import 'package:bia/view/pages/alunos/aluno_update.dart';
import 'package:bia/view/pages/alunos/aluno_view.dart';
import 'package:bia/services/auth_service.dart';
import 'package:flutter/material.dart';

// this page decides wich aluno screen to show

class AlunoPage extends StatefulWidget {
  const AlunoPage({super.key});

  @override
  State<AlunoPage> createState() => _AlunoPageState();
}

class _AlunoPageState extends State<AlunoPage> {
  int _selectedScreenIndex = 0;
  Aluno? _aluno;

  // function used to change wich screen to show
  // the aluno parameter is necessary for the update page
  void _changeScreen(int index, {Aluno? aluno}) {
    setState(() {
      _selectedScreenIndex = index;
      _aluno = aluno;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser!;
    final List<Widget> pages = [
      AlunoView(_changeScreen),
      AlunoCreate(_changeScreen, null),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(user.tipo == 'Aluno' ? 'Aluno' : 'Alunos'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _selectedScreenIndex != 2
          ? pages[_selectedScreenIndex]
          : _aluno == null
              ? AlunoImport(_changeScreen, null)
              : AlunoUpdate(_changeScreen, _aluno!),
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
                  label: 'Alunos',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'Cadastrar',
                ),
                if (_aluno == null && ['CGTI'].contains(user.tipo))
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.import_contacts),
                    label: 'Importar',
                  ),
                if (_aluno != null)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.edit),
                    label: 'Editar',
                  ),
              ],
            ),
    );
  }
}
