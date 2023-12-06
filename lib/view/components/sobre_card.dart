import 'dart:io';

import 'package:bia/view/components/card_component.dart';
import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text.dart';
import 'package:bia/model/models/sobre.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/view-model/sobre_list.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class SobreCard extends StatefulWidget {
  final Sobre sobre;
  final Function selectScreen;
  const SobreCard({
    required this.sobre,
    required this.selectScreen,
    super.key,
  });

  @override
  State<SobreCard> createState() => _SobreCardState();
}

class _SobreCardState extends State<SobreCard> {
  String anexo = '';
  Function? updateAnexo;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        // when the screen is initialized calls the function to read
        // the database and update processos
        updateAnexo!();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // get the current user
    final user = AuthService().currentUser!;

    final sobreList = Provider.of<SobreList>(context, listen: false);

    void deleta() {
      sobreList.delete(widget.sobre.id);
    }

    // function that access the database to update the processos list
    updateAnexo = () async {
      final storageRef = FirebaseStorage.instance.ref().child('sobre');
      final listResult = await storageRef.child(widget.sobre.id).listAll();
      if (listResult.items.isEmpty) {
        setState(() {
          anexo = '';
        });
      } else {
        for (var item in listResult.items) {
          setState(() {
            anexo = item.name;
          });
        }
      }
    };

    return CardComponent(
      titulo: widget.sobre.titulo.toUpperCase(),
      cardSize: 150,
      onDelete: ['Professor', 'Aluno'].contains(user.tipo) &&
              !user.isCoordenadorExtensao
          ? null
          : () async {
              // shows a popup screen to confirm de deletion
              bool? confirmado = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Tem certeza?'),
                  content: Text(
                    'Remover o sobre "${widget.sobre.titulo}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                      child: const Text('Não'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                      },
                      child: const Text('Sim'),
                    ),
                  ],
                ),
              );
              if (confirmado == true) {
                deleta();
              }
            },
      onEdit: (['CGTI'].contains(user.tipo) || user.isCoordenadorExtensao)
          ? () {
              // goes to the edit screen
              widget.selectScreen(2, sobre: widget.sobre);
            }
          : null,
      children: [
        CustomText(
          title: 'Texto: ',
          text: widget.sobre.texto,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              title: 'Anexo:\n',
              text: anexo,
              fontSize: 12,
            ),
            IconButton(
              onPressed: anexo == '' ||
                      ['Aluno'].contains(user.tipo) ||
                      (!user.isCoordenadorExtensao &&
                          !['CGTI'].contains(user.tipo))
                  ? null
                  // if the anexo has a name, them it
                  // exists on the database and the delete
                  // button becomes active
                  : () {
                      final storageRef = FirebaseStorage.instance.ref();
                      final fileRef = storageRef.child('sobre').child(
                          '${widget.sobre.id}/${widget.sobre.titulo}_${widget.sobre.id}.pdf');
                      fileRef.delete().onError(
                            (error, stackTrace) => alertMessage(
                              'Ocorreu um Erro',
                              error.toString(),
                            ),
                          );
                      setState(() {
                        anexo = '';
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
              onPressed: anexo == ''
                  ? null
                  : () async {
                      final storageRef = FirebaseStorage.instance.ref();
                      final fileRef = storageRef.child("sobre").child(
                          '${widget.sobre.id}/${widget.sobre.titulo}_${widget.sobre.id}.pdf');
                      final filePath = await getDownloadPath();
                      final file = File(
                          '${filePath!}/${widget.sobre.titulo}_${widget.sobre.id}.pdf');

                      // this is used to make the download
                      // of the file
                      final downloadTask = fileRef.writeToFile(file);
                      downloadTask.snapshotEvents.listen((taskSnapshot) {
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
                        alertMessage('Ocorreu um Erro', e.toString());
                      });
                    },
              child: const Text('Baixar'),
            ),
            CustomButton(
              // button used to upload a file to the
              // database
              onPressed: ['CGTI'].contains(user.tipo) ||
                      user.isCoordenadorExtensao
                  ? () async {
                      final storageRef = FirebaseStorage.instance.ref();
                      final fileRef = storageRef.child("sobre").child(
                          '${widget.sobre.id}/${widget.sobre.titulo}_${widget.sobre.id}.pdf');
                      final filePath = await _pickFile();

                      if (filePath == null) return;

                      File file = File(filePath);

                      try {
                        fileRef.putFile(file).snapshotEvents.listen((event) {
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
                              updateAnexo!();
                              break;
                          }
                        });
                      } catch (e) {
                        alertMessage('Ocooreu um Erro', e.toString());
                      }
                    }
                  : null,
              child: const Text('Enviar'),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
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
