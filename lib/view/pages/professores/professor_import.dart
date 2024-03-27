import 'dart:convert';
import 'dart:io';

import 'package:bia/view/components/professor_import_card.dart';
import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text.dart';
import 'package:bia/model/models/professor.dart';
import 'package:bia/view-model/professor_import_list.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/services.dart' show SystemUiOverlayStyle, rootBundle;

// screen to import professores from a file

class ProfessorImport extends StatefulWidget {
  final Function selectScreen;
  final Professor? professor;
  const ProfessorImport(this.selectScreen, this.professor, {super.key});

  @override
  State<ProfessorImport> createState() => _ProfessorImportState();
}

class _ProfessorImportState extends State<ProfessorImport> {
  final List<List<dynamic>> _data = [];
  String? filePath;
  // bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // gets width available of the screen
    final maxWidth = MediaQuery.of(context).size.width;

    final formKey = GlobalKey<FormState>();

    // gets provider for professoresImport
    final professorImportList = Provider.of<ProfessorImportList>(context);

    return professorImportList.items.isEmpty
        ? SizedBox(
            height: 280,
            width: maxWidth,
            child: Card(
              shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      title:
                          'Para realizar a importação de professorS, faça:\n',
                      corTitle: Theme.of(context).colorScheme.primary,
                      text: '1. Acesse o SUAP\n'
                          '2.Baixe o arquivo geral que contém informações sobre todos os'
                          ' professores. Esse arquivo deve conter nome completo, matrícula,'
                          ' e-mail e telefone\n'
                          '3. Faça o download deste arquivo e converta-o em formato .CSV\n'
                          '4. Salve o arquivo em .CSV no seu aparelho celular.\n'
                          '5. Selecione o arquivo de professor',
                      cor: Theme.of(context).colorScheme.primary,
                    ),
                    Form(
                      key: formKey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 80,
                            width: 150,
                            child: Text(''),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: CustomButton(
                              // gets the professores from file to show on
                              // screen
                              onPressed: () {
                                final bool isValid =
                                    formKey.currentState!.validate();
                                if (isValid) {
                                  formKey.currentState!.save();
                                  _pickFile(professorImportList);
                                }
                              },
                              child: const Text('Importar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : professorImportList.isLoading
            ? Center(
                // the import may take a while depending on how many
                // professores are being created, so the screen will
                // enter a loading state while it wait for it to finish
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        'Esperando ${professorImportList.items.length.toString()} importações.'),
                    const CircularProgressIndicator(),
                  ],
                ),
              )
            : Stack(children: [
                ListView.builder(
                  itemCount: professorImportList.items.length,
                  itemBuilder: (context, index) {
                    return ProfessorImportCard(
                      professor: professorImportList.items[index],
                    );
                  },
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        // button to calncel import
                        onPressed: () {
                          setState(() {
                            _data.clear();
                            professorImportList.resetImport();
                          });
                        },
                        child: const Text('Cancelar'),
                      ),
                      CustomButton(
                        // button to add all professores to the database
                        onPressed: () {
                          professorImportList.addProfessorFromImportList();
                          setState(() {
                            _data.clear();
                          });
                        },
                        child: const Text('Confirmar'),
                      ),
                    ],
                  ),
                ),
              ]);
  }

  // function that handles the reading of the file
  void _pickFile(ProfessorImportList professorImportList) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;
    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    // print(result.files.first.name);
    filePath = result.files.first.path!;

    final input = File(filePath!).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();

    _data.clear();

    if (isFileValid(fields)) {
      // saves all professores to _data
      for (var element in fields) {
        setState(() {
          _data.add([
            element[1], // nome
            element[2], // siap
            element[4].toString().toLowerCase(), // e-mail
            element[5], // telefone
          ]);
        });
      }
    } else {
      if (context.mounted) {
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Arquivo Inválido'),
            content: const Text(
              'Arquivo Inválido.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Ok'),
              ),
            ],
          ),
        );
      }
    }

    professorImportList.resetImport();

    // skips the first 2 lines of file
    // it may need to be ajusted
    // adds the professores in _data to the provider
    for (var element in _data.skip(2)) {
      professorImportList.addprofessorFromImport(
        nome: element[0],
        siap: element[1].toString(),
        email: element[2],
        telefone: element[3],
      );
    }
  }

  bool isFileValid(List<dynamic> fields) {
    // checks if the file is in the correct format
    if (fields[1].length != 6) return false;
    if (fields[1][1] != 'Nome' ||
        fields[1][2] != 'Matrícula' ||
        fields[1][3] != 'Setor' ||
        fields[1][4] != 'E-mail' ||
        fields[1][5] != 'Telefone') return false;

    return true;
  }
}
