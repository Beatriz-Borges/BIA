import 'package:bia/view-model/sobre_list.dart';
import 'package:bia/view/pages/alunos/aluno_page.dart';
import 'package:bia/view/pages/alunos/alunos_disponiveis.dart';
import 'package:bia/view/pages/alunos/processo_page.dart';
import 'package:bia/view/pages/auth_or_app_page.dart';
import 'package:bia/view/pages/cursos/curso_page.dart';
import 'package:bia/view/pages/ideias/ideia_page.dart';
import 'package:bia/view/pages/perguntas/pergunta_page.dart';
import 'package:bia/view/pages/professores/professor_page.dart';
import 'package:bia/view/pages/professores/professores_disponiveis.dart';
import 'package:bia/view/pages/sobre/sobre_page.dart';
import 'package:bia/view/pages/welcome_page.dart';
import 'package:bia/utils/app_routes.dart';
import 'package:bia/view-model/aluno_import_list.dart';
import 'package:bia/view-model/aluno_list.dart';
import 'package:bia/view-model/concedente_list.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:bia/view-model/ideia_list.dart';
import 'package:bia/view-model/pergunta_list.dart';
import 'package:bia/view-model/professor_import_list.dart';
import 'package:bia/view-model/professor_list.dart';
import 'package:bia/view-model/vaga_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view/pages/concedentes/concedente_page.dart';
import 'view/pages/vagas/vaga_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeData theme = ThemeData();
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // sets up the providers so that they can be used throughout the application
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AlunoList(),
        ),
        ChangeNotifierProvider(
          create: (context) => AlunoImportList(),
        ),
        ChangeNotifierProvider(
          create: (context) => VagaList(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfessorList(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfessorImportList(),
        ),
        ChangeNotifierProvider(
          create: (context) => ConcedenteList(),
        ),
        ChangeNotifierProvider(
          create: (context) => PerguntaList(),
        ),
        ChangeNotifierProvider(
          create: (context) => CursoList(),
        ),
        ChangeNotifierProvider(
          create: (context) => IdeiaList(),
        ),
        ChangeNotifierProvider(
          create: (context) => SobreList(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: theme.copyWith(
          // sets the main colors used in the application
          colorScheme: theme.colorScheme.copyWith(
            primary: Colors.green,
            secondary: const Color.fromRGBO(76, 176, 79, 1),
            tertiary: Colors.red,
            background: const Color.fromRGBO(218, 242, 209, 1),
          ),
        ),
        // sets up the routes used throughtout the application
        routes: {
          AppRoutes.welcome: (context) => const WelcomePage(),
          AppRoutes.home: (context) => const AuthOrAppPage(),
          AppRoutes.aluno: (context) => const AlunoPage(),
          AppRoutes.alunoDisponivel: (context) => const AlunosDisponiveis(),
          AppRoutes.vaga: (context) => const VagaPage(),
          AppRoutes.professor: (context) => const ProfessorPage(),
          AppRoutes.professorDisponivel: (context) =>
              const ProfessoresDisponiveis(),
          AppRoutes.concedente: (context) => const ConcedentePage(),
          AppRoutes.pergunta: (context) => const PerguntaPage(),
          AppRoutes.curso: (context) => const CursoPage(),
          AppRoutes.ideia: (context) => const IdeiaPage(),
          AppRoutes.sobre: (context) => const SobrePage(),
          AppRoutes.processo: (context) => const ProcessoPage(),
        },
      ),
    );
  }
}
