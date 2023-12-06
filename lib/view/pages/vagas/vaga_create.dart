import 'package:bia/view/components/custom_text_field.dart';
import 'package:bia/model/models/vaga.dart';
import 'package:bia/view-model/concedente_list.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:bia/view-model/vaga_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quantity_input/quantity_input.dart';

import '../../components/custom_button.dart';

// the screen used to create a new vaga

class VagaCreate extends StatefulWidget {
  final Function selectScreen;
  final Vaga? vaga;
  const VagaCreate(this.selectScreen, this.vaga, {super.key});

  @override
  State<VagaCreate> createState() => _VagaCreateState();
}

class _VagaCreateState extends State<VagaCreate> {
  bool _isLoading = false;

  final _formData = <String, Object>{'curricular': false};

  final _formKey = GlobalKey<FormState>();

  String? _selectedCurso;
  String? _selectedConcedente;

  int _quantidade = 1;
  bool _curricular = false;

  // creates a list of cursos for the dropdown widget later
  List<DropdownMenuItem> cursos() {
    List<DropdownMenuItem> list = [];
    for (var curso in Provider.of<CursoList>(context, listen: false).items) {
      list.add(DropdownMenuItem(
        value: curso.id,
        child: Text(curso.nome),
      ));
    }
    return list;
  }

  // creates a list of concedentes for the dropdown widget later
  List<DropdownMenuItem> concedentes() {
    List<DropdownMenuItem> list = [];
    for (var concedente in Provider.of<ConcedenteList>(context).items) {
      list.add(DropdownMenuItem(
        value: concedente.id,
        child: Text(concedente.nome),
      ));
    }
    return list;
  }

  // function tha handles the submission of the form
  void submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      // returns if the form has a problem
      return;
    }

    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    try {
      // calls the provider class to update the vaga
      Provider.of<VagaList>(
        context,
        listen: false,
      ).addVagaFromData(_formData, _quantidade);

      // changes the screen back to view
      widget.selectScreen(0, vaga: widget.vaga);
    } catch (error) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro ao salvar a vaga'),
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
                        label: const Text('Função'),
                        hintText: 'Técnico em Informática',
                        onSaved: (funcao) => _formData['funcao'] = funcao ?? '',
                        validator: (value) {
                          final funcao = value ?? '';

                          if (funcao.trim().isEmpty) {
                            return 'Função é obrigatório';
                          }

                          if (funcao.trim().length <= 3) {
                            return 'Função precisa ter mais de 3 letras';
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
                          label: Text('Concedente'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                        ),
                        items: [...concedentes()],
                        value: _selectedConcedente,
                        onChanged: (value) {
                          setState(() {
                            if (value == '') {
                              _selectedConcedente = null;
                            } else {
                              _selectedConcedente = value;
                              _formData['concedenteId'] =
                                  _selectedConcedente ?? '';
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Concedente é Obrigatório';
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
                          label: Text('Curso'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                        ),
                        items: [...cursos()],
                        value: _selectedCurso,
                        focusColor: const Color.fromRGBO(0, 0, 0, 0),
                        onChanged: (value) {
                          setState(() {
                            _selectedCurso = value;
                            _formData['cursoId'] = _selectedCurso ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Curso é obrigatório';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(height: 0.2),
                          label: const Text('Remuneração'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          hintText: '0.00',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onSaved: (remuneracao) {
                          if (remuneracao == '' || remuneracao == null) {
                            _formData['remuneracao'] = 0.0;
                          } else {
                            _formData['remuneracao'] =
                                double.parse(remuneracao);
                          }
                        },
                        validator: (value) {
                          final String remuneracao;
                          if (value == '' || value == null) {
                            remuneracao = '0';
                          } else {
                            remuneracao = value;
                          }

                          if (double.tryParse(remuneracao) == null) {
                            return 'Valor inválido';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Quantidade de Vagas'),
                            QuantityInput(
                              buttonColor:
                                  Theme.of(context).colorScheme.primary,
                              minValue: 1,
                              value: _quantidade,
                              acceptsZero: false,
                              acceptsNegatives: false,
                              readOnly: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (p0) {
                                setState(() {
                                  if (int.parse(p0) <= 0) {
                                    _quantidade = 1;
                                  }
                                  _quantidade = int.parse(p0);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 3,
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(height: 0.2),
                          label: const Text('Descrição'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          hintText: 'Fale um pouco sobre a vaga ...',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onSaved: (descricao) {
                          _formData['descricao'] = descricao ?? '';
                        },
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Checkbox(
                                  value: _curricular,
                                  onChanged: (_) {
                                    setState(() {
                                      _curricular = true;
                                      _formData['curricular'] = _curricular;
                                    });
                                  },
                                ),
                                Text(
                                  'Curricular',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Checkbox(
                                  value: !_curricular,
                                  onChanged: (_) {
                                    setState(() {
                                      _curricular = false;
                                      _formData['curricular'] = _curricular;
                                    });
                                  },
                                ),
                                Text(
                                  'Extra-Curricular',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
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
                                widget.selectScreen(0, vaga: widget.vaga);
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
