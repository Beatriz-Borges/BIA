import 'package:bia/model/models/pergunta.dart';
import 'package:bia/view/pages/perguntas/pergunta_create.dart';
import 'package:bia/view/pages/perguntas/pergunta_update.dart';
import 'package:bia/view/pages/perguntas/pergunta_view.dart';
import 'package:bia/services/auth_service.dart';
import 'package:flutter/material.dart';

// this page decides wich pergunta screen to show

class PerguntaPage extends StatefulWidget {
  const PerguntaPage({super.key});

  @override
  State<PerguntaPage> createState() => _PerguntaPageState();
}

class _PerguntaPageState extends State<PerguntaPage> {
  int _selectedScreenIndex = 0;
  Pergunta? _pergunta;

  // function used to change wich screen to show
  // the pergunta parameter is necessary for the update page
  void _changeScreen(int index, {Pergunta? pergunta}) {
    setState(() {
      _selectedScreenIndex = index;
      _pergunta = pergunta;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perguntas'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _selectedScreenIndex == 0
          ? PerguntaView(_changeScreen)
          : _selectedScreenIndex == 1
              ? PerguntaCreate(_changeScreen)
              : PerguntaUpdate(_changeScreen, _pergunta!),
      bottomNavigationBar:
          !['CGTI'].contains(user.tipo) || user.isCoordenadorExtensao
              ? null
              : BottomNavigationBar(
                  onTap: (value) {
                    if (['CGTI'].contains(user.tipo) ||
                        user.isCoordenadorExtensao) {
                      _changeScreen(value);
                    } else {
                      _changeScreen(0);
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
                      label: 'Perguntas',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.add),
                      label: 'Cadastrar',
                    ),
                    if (_pergunta != null)
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.edit),
                        label: 'Editar',
                      ),
                  ],
                ),
    );
  }
}
