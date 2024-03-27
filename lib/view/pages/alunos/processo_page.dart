import 'dart:io';

import 'package:bia/view/components/card_component.dart';
import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text.dart';
import 'package:bia/model/models/aluno.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// screen for upload/download of files related to aluno's estagio

class ProcessoPage extends StatefulWidget {
  const ProcessoPage({super.key});

  @override
  State<ProcessoPage> createState() => _ProcessoPageState();
}

class _ProcessoPageState extends State<ProcessoPage> {
  List<String> processos = [
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ''
  ];
  Function? updateProcessos;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        // when the screen is initialized calls the function to read
        // the database and update processos
        updateProcessos!();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // gets aluno from the rout transition
    final Aluno aluno = ModalRoute.of(context)!.settings.arguments as Aluno;

    // function that access the database to update the processos list
    updateProcessos = () async {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('processos')
          .child(aluno.matricula)
          .child(aluno.vagaId!);
      for (var i = 0; i < 11; i++) {
        final listResult = await storageRef.child('Processo$i').listAll();
        if (listResult.items.isEmpty) {
          processos[i] = '';
        } else {
          for (var item in listResult.items) {
            setState(() {
              processos[i] = item.name;
            });
          }
        }
      }
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Processos'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: RefreshIndicator(
        onRefresh: () => updateProcessos!(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: CustomText(
                title: 'Aluno: ',
                fontSizeTitle: 20,
                text: aluno.nome,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: 17,
                itemBuilder: (context, index) {
                  return CardComponent(
                    titulo: 'Anexo ${index + 1}',
                    cardSize: 100,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            title: 'Anexo:\n',
                            text: processos[index],
                            fontSize: 12,
                          ),
                          IconButton(
                            onPressed: processos[index] == ''
                                ? null
                                // if the processo has a name, them it
                                // exists on the database and the delete
                                // button becomes active
                                : () {
                                    final storageRef =
                                        FirebaseStorage.instance.ref();
                                    final fileRef = storageRef
                                        .child('processos')
                                        .child(
                                            '${aluno.matricula}/${aluno.vagaId!}/Processo$index')
                                        .child(processos[index]);
                                    fileRef.delete().onError(
                                          (error, stackTrace) => alertMessage(
                                            'Ocorreu um Erro',
                                            error.toString(),
                                          ),
                                        );
                                    setState(() {
                                      processos[index] = '';
                                    });
                                  },
                            icon: const Icon(Icons.delete),
                            color: Theme.of(context).colorScheme.tertiary,
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomButton(
                            onPressed: processos[index] == ''
                                ? null
                                : () async {
                                    final storageRef =
                                        FirebaseStorage.instance.ref();
                                    final fileRef = storageRef
                                        .child("processos")
                                        .child(
                                            '${aluno.matricula}/${aluno.vagaId!}/Processo$index/${aluno.matricula}${aluno.vagaId!}_${index + 1}.pdf');
                                    final filePath = await getDownloadPath();
                                    final file = File(
                                        '${filePath!}/${aluno.matricula}${aluno.vagaId!}_${index + 1}.pdf');

                                    // this is used to make the download
                                    // of the file
                                    final downloadTask =
                                        fileRef.writeToFile(file);
                                    downloadTask.snapshotEvents
                                        .listen((taskSnapshot) {
                                      switch (taskSnapshot.state) {
                                        case TaskState.running:
                                          break;
                                        case TaskState.paused:
                                          break;
                                        case TaskState.success:
                                          alertMessage(
                                            'Download Efetuado com Sucesso',
                                            '',
                                          );
                                          break;
                                        case TaskState.canceled:
                                          alertMessage(
                                            'Download Cancelado',
                                            '',
                                          );
                                          break;
                                        case TaskState.error:
                                          alertMessage(
                                            'Error',
                                            'Ocorreu um erro no download do arquivo',
                                          );
                                          break;
                                      }
                                    }).onError((e) {
                                      alertMessage(
                                          'Ocorreu um Erro', e.toString());
                                    });
                                  },
                            child: const Text('Baixar'),
                          ),
                          CustomButton(
                            // button used to upload a file to the
                            // database
                            onPressed: () async {
                              final storageRef = FirebaseStorage.instance.ref();
                              final fileRef = storageRef
                                  .child("processos")
                                  .child(
                                      '${aluno.matricula}/${aluno.vagaId!}/Processo$index')
                                  .child(
                                      '${aluno.matricula}${aluno.vagaId!}_${index + 1}.pdf');
                              final filePath = await _pickFile();

                              if (filePath == null) return;

                              File file = File(filePath);

                              try {
                                fileRef
                                    .putFile(file)
                                    .snapshotEvents
                                    .listen((event) {
                                  switch (event.state) {
                                    case TaskState.paused:
                                      break;
                                    case TaskState.canceled:
                                      alertMessage(
                                        'Envio Cancelado',
                                        '',
                                      );
                                      break;
                                    case TaskState.error:
                                      alertMessage(
                                        'Error',
                                        'Ocorreu um erro no upload do arquivo',
                                      );
                                      break;
                                    case TaskState.running:
                                      break;
                                    case TaskState.success:
                                      alertMessage(
                                        'Upload Efetuado com Sucesso',
                                        '',
                                      );
                                      updateProcessos!();
                                      break;
                                  }
                                });
                              } catch (e) {
                                alertMessage('Ocooreu um Erro', e.toString());
                              }
                            },
                            child: const Text('Enviar'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // function used to pick the file to upload
  Future<String?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return null;
    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    // print(result.files.first.name);
    return result.files.first.path!;
  }

  // function used to figure out where to save the file on download
  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      alertMessage('Ocorreu um Erro', err.toString());
    }
    return directory?.path;
  }

  // an alert message function because it was used many times
  void alertMessage(String title, String descricao) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(
          descricao,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}
