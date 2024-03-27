import 'dart:convert';
import 'dart:io';

import 'package:bia/view/components/aluno_import_card.dart';
import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text.dart';
import 'package:bia/view/components/custom_text_field.dart';
import 'package:bia/model/models/aluno.dart';
import 'package:bia/view-model/aluno_import_list.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/services.dart' show SystemUiOverlayStyle, rootBundle;

// screen to import alunos from a file

class AlunoImport extends StatefulWidget {
  final Function selectScreen;
  final Aluno? aluno;
  const AlunoImport(this.selectScreen, this.aluno, {super.key});

  @override
  State<AlunoImport> createState() => _AlunoImportState();
}

class _AlunoImportState extends State<AlunoImport> {
  final List<List<dynamic>> _data = [];
  String? filePath;
  String _semestreAtual = '';

  @override
  Widget build(BuildContext context) {
    // gets width available on screen
    final maxWidth = MediaQuery.of(context).size.width;

    final formKey = GlobalKey<FormState>();

    // gets provider for alunosImport
    final alunoImportList = Provider.of<AlunoImportList>(context);

    // gets provider for cursos
    final cursoList = Provider.of<CursoList>(context, listen: false);

    return alunoImportList.items.isEmpty
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
                      title: 'Para realizar a importação de ALUNOS, faça:\n',
                      corTitle: Theme.of(context).colorScheme.primary,
                      text: '1. Acesse o SUAP\n'
                          '2.Baixe o arquivo geral que contém informações sobre todos os'
                          ' alunos. Esse arquivo deve conter nome completo, matrícula,'
                          ' e-mail institucional e ano de ingresso\n'
                          '3. Faça o download deste arquivo e converta-o em formato .CSV\n'
                          '4. Salve o arquivo em .CSV no seu aparelho celular.\n'
                          '5. Selecione o arquivo de aluno',
                      cor: Theme.of(context).colorScheme.primary,
                    ),
                    Form(
                      key: formKey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 80,
                            width: 160,
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: CustomTextField(
                              label: const Text('Semestre'),
                              hintText: '2023.1',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onSaved: (value) {
                                _semestreAtual = value ?? '';
                              },
                              validator: (value) {
                                final String semestreAtual = value ?? '';

                                if (semestreAtual.trim().isEmpty) {
                                  return 'Semestre atual não pode ser nulo';
                                }

                                if (semestreAtual.trim().split('.')[0].length !=
                                        4 ||
                                    semestreAtual.trim().split('.')[1].length !=
                                        1) {
                                  return 'Semestre atual deve seguir o formato XXXX.X';
                                }

                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: CustomButton(
                              // gets the alunos from file to show on screen
                              onPressed: () {
                                final bool isValid =
                                    formKey.currentState!.validate();
                                if (isValid) {
                                  formKey.currentState!.save();
                                  _pickFile(alunoImportList, cursoList);
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
        : alunoImportList.isLoading
            ? Center(
                // the import may take a while depending on how many
                // alunos are being created, so the screen will enter
                // a loading state while it wait for it to finish
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        'Esperando ${alunoImportList.items.length.toString()} importações.'),
                    const CircularProgressIndicator(),
                  ],
                ),
              )
            : Stack(children: [
                ListView.builder(
                  itemCount: alunoImportList.items.length,
                  itemBuilder: (context, index) {
                    return AlunoImportCard(
                      aluno: alunoImportList.items[index],
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
                        // button to cancel import
                        onPressed: () {
                          setState(() {
                            _data.clear();
                            alunoImportList.resetImport();
                          });
                        },
                        child: const Text('Cancelar'),
                      ),
                      CustomButton(
                        // button to add all alunos to the database
                        onPressed: () {
                          alunoImportList.addAlunoFromImportList();
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
  void _pickFile(AlunoImportList alunoImportList, CursoList cursoList) async {
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
      // saves all alunos with the same _semestreAtual to _data
      for (var element in fields) {
        if (element[9].toString() == _semestreAtual.toString()) {
          setState(() {
            _data.add([
              element[1], // nome
              element[2].toString().toLowerCase(), // matricula
              element[8].toString().toLowerCase(), // e-mail
            ]);
          });
        }
      }
    }

    alunoImportList.resetImport();

    // adds the alunos in _data to the provider
    for (var element in _data) {
      final curso = cursoList.getCursoFromSigla(
        element[1].toString().substring(5, element[1].toString().length - 4),
      );
      alunoImportList.addAlunoFromImport(
        nome: element[0],
        matricula: element[1],
        email: element[2],
        cursoId: curso?.id ?? '',
      );
    }
  }

  bool isFileValid(List<dynamic> fields) {
    // checks if the file is in the correct format
    if (fields[0].length != 10) return false;
    if (fields[0][1] != 'Nome' ||
        fields[0][2] != 'Matrícula' ||
        fields[0][6] != 'Situação' ||
        fields[0][7] != 'E-mail Acadêmico') return false;

    return true;
  }
}
