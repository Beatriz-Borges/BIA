import 'package:bia/view/components/custom_text_field.dart';
import 'package:bia/model/models/vaga.dart';
import 'package:bia/view-model/concedente_list.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:bia/view-model/vaga_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_button.dart';

// the screen used to update a vaga

class VagaUpdate extends StatefulWidget {
  final Function selectScreen;
  final Vaga vaga;
  const VagaUpdate(this.selectScreen, this.vaga, {super.key});

  @override
  State<VagaUpdate> createState() => _VagaUpdateState();
}

class _VagaUpdateState extends State<VagaUpdate> {
  bool _isLoading = false;

  final _formData = <String, Object>{'curricular': false};

  final _formKey = GlobalKey<FormState>();

  String? _selectedCurso;
  String? _selectedConcedente;

  bool _curricular = false;

  // creates a list of cursos to be used in the dropdown widget
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

  // creates a list of concedentes to be used in the dropdown widget
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // gets the initial values of the instance of vaga being updated
    final Vaga vaga = widget.vaga;

    _formData['id'] = vaga.id;
    _formData['funcao'] = vaga.funcao;
    _formData['concedenteId'] = vaga.concedenteId;
    _selectedConcedente = vaga.concedenteId;
    _formData['cursoId'] = vaga.cursoId;
    _selectedCurso = vaga.cursoId;
    _formData['remuneracao'] = vaga.remuneracao;
    _formData['descricao'] = vaga.descricao;
    _formData['curricular'] = vaga.curricular;
    _curricular = vaga.curricular;
    if (vaga.alunoId != null) {
      _formData['aluno'] = vaga.alunoId!;
    }
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
      ).update(_formData);

      // changes the screen back to view
      widget.selectScreen(0);
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
                        initialValue: _formData['funcao']?.toString(),
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
                        onChanged: null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: _formData['remuneracao']?.toString(),
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
                          // if remuneração is empty it is defaulted to 0.0
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
                      TextFormField(
                        initialValue: _formData['descricao']?.toString(),
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
                      const SizedBox(height: 100),
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
