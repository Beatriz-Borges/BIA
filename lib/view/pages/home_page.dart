import 'dart:convert';

import 'package:bia/view/components/grid_item.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/utils/app_routes.dart';
import 'package:bia/utils/constants.dart';
import 'package:bia/view-model/aluno_list.dart';
import 'package:bia/view-model/concedente_list.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:bia/view-model/vaga_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // checks the database to see if the user is the coordenador de extensão
  // and updates it accordingly
  void updateIsCoordenador() async {
    final response = await http.get(
      Uri.parse('${Constants.coordenadorExtensao}.json'),
    );

    final cExtensao = jsonDecode(response.body);
    if (cExtensao == null || cExtensao == '') {
      setState(() {
        AuthService().currentUser!.isCoordenadorExtensao = false;
      });
    }
    setState(() {
      AuthService().currentUser!.isCoordenadorExtensao =
          cExtensao == AuthService().currentUser!.tipoId;
    });
  }

  // preemptively copy some of the data from the database to be ready to
  // use during the initialization of the screen
  @override
  void initState() {
    Provider.of<CursoList>(context, listen: false).loadCursos();
    Provider.of<AlunoList>(context, listen: false).loadAlunos();
    Provider.of<VagaList>(context, listen: false).loadVagas();
    Provider.of<ConcedenteList>(context, listen: false).loadConcedentes();
    updateIsCoordenador();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser!;
    // gets the available screen space in the device
    final double availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              AuthService().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        title: const Text('Basic Internship Administrator - BIA'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        margin: EdgeInsets.symmetric(vertical: availableHeight * 0.1),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 70,
          ),
          children: [
            if (['Professor', 'CGTI', 'Aluno'].contains(user.tipo) ||
                user.isCoordenadorExtensao)
              GridItem(
                iconData: Icons.people,
                title: user.tipo == 'Aluno' ? 'Aluno' : 'Alunos',
                route: AppRoutes.aluno,
              ),
            if (['CGTI', 'Aluno'].contains(user.tipo) ||
                user.isCoordenadorExtensao)
              const GridItem(
                iconData: Icons.work,
                title: 'Vagas',
                route: AppRoutes.vaga,
              ),
            if (['CGTI'].contains(user.tipo) || user.isCoordenadorExtensao)
              const GridItem(
                iconData: Icons.school,
                title: 'Professores',
                route: AppRoutes.professor,
              ),
            if (['CGTI'].contains(user.tipo) || user.isCoordenadorExtensao)
              const GridItem(
                iconData: Icons.home,
                title: 'Concedentes',
                route: AppRoutes.concedente,
              ),
            const GridItem(
              iconData: Icons.question_answer,
              title: 'Perguntas',
              route: AppRoutes.pergunta,
            ),
            if (['CGTI'].contains(user.tipo) || user.isCoordenadorExtensao)
              const GridItem(
                iconData: Icons.book,
                title: 'Cursos',
                route: AppRoutes.curso,
              ),
            const GridItem(
              iconData: Icons.lightbulb,
              title: "Ideias",
              route: AppRoutes.ideia,
            ),
            const GridItem(
              iconData: Icons.info,
              title: "Sobre",
              route: AppRoutes.sobre,
            ),
          ],
        ),
      ),
    );
  }
}
