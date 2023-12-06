import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text_field.dart';
import 'package:bia/model/models/curso.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// screen to create a new curso

class CursoCreate extends StatefulWidget {
  final Function selectScreen;
  final Curso? curso;
  const CursoCreate(this.selectScreen, this.curso, {super.key});

  @override
  State<CursoCreate> createState() => _CursoCreateState();
}

class _CursoCreateState extends State<CursoCreate> {
  bool _isLoading = false;

  final _formData = <String, Object>{'curricular': false};

  final _formKey = GlobalKey<FormState>();

  String? selectedNivel;

  // creates a list of curso.nivel to be used by a dropdown widget
  List<DropdownMenuItem> niveis() {
    List<DropdownMenuItem> list = [];
    for (var nivel in Curso.niveis) {
      list.add(DropdownMenuItem(
        value: nivel,
        child: Text(nivel),
      ));
    }
    return list;
  }

  void submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    try {
      Provider.of<CursoList>(
        context,
        listen: false,
      ).addCursoFromData(_formData);

      widget.selectScreen(0);
    } catch (error) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro ao salvar o curso'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final CursoList cursoList = Provider.of<CursoList>(context, listen: false);
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      CustomTextField(
                        label: const Text('Nome'),
                        hintText: 'Informática',
                        onSaved: (nome) => _formData['nome'] = nome ?? '',
                        validator: (value) {
                          final nome = value ?? '';

                          if (nome.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }

                          if (nome.trim().length <= 3) {
                            return 'Nome precisa ter mais de 3 letras';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: const Text('Sigla'),
                        hintText: 'ireinfoint',
                        onSaved: (sigla) =>
                            _formData['sigla'] = sigla?.toLowerCase() ?? '',
                        validator: (value) {
                          final sigla = value ?? '';

                          if (sigla.trim().isEmpty) {
                            return 'Sigla é obrigatório';
                          }

                          if (sigla.trim().length <= 3) {
                            return 'Sigla precisa ter mais de 3 letras';
                          }

                          for (var curso in cursoList.items) {
                            if (curso.sigla == sigla) {
                              return 'Sigla já existe';
                            }
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField(
                        borderRadius: BorderRadius.circular(10),
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: const InputDecoration(
                          label: Text('Nível'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                        ),
                        items: [...niveis()],
                        value: selectedNivel,
                        focusColor: const Color.fromRGBO(0, 0, 0, 0),
                        onChanged: (value) {
                          setState(() {
                            if (value == '') {
                              selectedNivel = null;
                            } else {
                              selectedNivel = value;
                              _formData['nivel'] = selectedNivel!;
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Nível é obrigatório';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 300),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomButton(
                              onPressed: submitForm,
                              child: const Text('Salvar'),
                            ),
                            CustomButton(
                              onPressed: () {
                                widget.selectScreen(0);
                              },
                              child: const Text('Cancelar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
