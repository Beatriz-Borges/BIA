import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text_field.dart';
import 'package:bia/model/models/aluno.dart';
import 'package:bia/view-model/aluno_list.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// screen to create a new aluno

class AlunoCreate extends StatefulWidget {
  final Function selectScreen;
  final Aluno? aluno;
  const AlunoCreate(this.selectScreen, this.aluno, {super.key});

  @override
  State<AlunoCreate> createState() => _AlunoCreateState();
}

class _AlunoCreateState extends State<AlunoCreate> {
  bool _isLoading = false;

  bool _eCurricular = false;
  bool _eExtraCurricular = false;

  final _formData = <String, Object>{};

  final _formKey = GlobalKey<FormState>();

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
      Provider.of<AlunoList>(
        context,
        listen: false,
      ).addAlunoFromData(_formData);

      widget.selectScreen(0, aluno: widget.aluno);
    } catch (error) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro ao salvar o aluno.'),
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
    // gets provider for alunos
    final alunoList = Provider.of<AlunoList>(context, listen: false);

    // gets provider for cursos
    final cursoList = Provider.of<CursoList>(context, listen: false);

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
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      CustomTextField(
                        label: const Text('Nome'),
                        hintText: 'Maria José...',
                        onSaved: (nome) => _formData['nome'] = nome ?? '',
                        validator: (value) {
                          final name = value ?? '';

                          if (name.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }

                          if (name.trim().length <= 3) {
                            return 'Nome precisa ter mais de 3 letras';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: const Text('E-mail'),
                        hintText: 'realemail@notfake.com',
                        onSaved: (email) =>
                            _formData['email'] = email?.toLowerCase() ?? '',
                        validator: (value) {
                          final email = value ?? '';
                          if (email.trim().isEmpty || !email.contains('@')) {
                            return 'Informe um e-mail válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: const Text('Telefone'),
                        hintText: '074912345678',
                        onSaved: (telefone) =>
                            _formData['telefone'] = telefone ?? '',
                        validator: (value) {
                          final telefone = value ?? '';

                          if (telefone.trim().length <= 8 &&
                              telefone.trim().isNotEmpty) {
                            return 'Telefone precisa ter mais de 8 números';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: const Text('Matrícula'),
                        hintText: '20001ireadsS0001',
                        onSaved: (matricula) => _formData['matricula'] =
                            matricula?.toLowerCase() ?? '',
                        validator: (value) {
                          final matricula = value ?? '';

                          if (matricula.trim().isEmpty) {
                            return 'Matrícula é obrigatório';
                          }

                          if (matricula.trim().length <= 8) {
                            return 'Matrícula precisa ter mais de 8 caracteres';
                          }

                          final int? beginning =
                              int.tryParse(matricula.substring(0, 5));
                          final int? ending = int.tryParse(matricula.substring(
                              matricula.length - 4, matricula.length));
                          final String sigla = matricula
                              .substring(5, matricula.length - 4)
                              .toLowerCase();

                          if (beginning == null) {
                            return 'Os 5 priemiros dígitos devem ser números';
                          }

                          if (ending == null) {
                            return 'Os últimos 4 dígitos devem ser números';
                          }

                          // checks to see if there is a curso that
                          // matches the matrícula
                          final cursoId = cursoList.getCursoFromSigla(sigla);

                          if (cursoId == null) {
                            return '$sigla não representa um curso válido';
                          } else {
                            _formData['cursoId'] = cursoId.id;
                          }

                          for (var aluno in alunoList.items) {
                            if (aluno.matricula == matricula) {
                              return 'Matrícula já existe';
                            }
                          }

                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Estágios Completos:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Checkbox(
                                value: _eCurricular,
                                onChanged: (value) {
                                  setState(() {
                                    _eCurricular = value!;
                                    _formData['eCurricular'] = _eCurricular;
                                  });
                                },
                              ),
                              Text(
                                'Curricular',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Checkbox(
                                value: _eExtraCurricular,
                                onChanged: (value) {
                                  setState(() {
                                    _eExtraCurricular = value!;
                                    _formData['eExtraCurricular'] =
                                        _eExtraCurricular;
                                  });
                                },
                              ),
                              Text(
                                'Extra-Curricular',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomButton(
                                      onPressed: submitForm,
                                      child: const Text('Salvar'),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    CustomButton(
                                      onPressed: () {
                                        widget.selectScreen(
                                          0,
                                          aluno: widget.aluno,
                                        );
                                      },
                                      child: const Text('Cancelar'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              height: 60,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FittedBox(
                                child: Row(
                                  children: [
                                    const Icon(Icons.info, color: Colors.green),
                                    Text(
                                      'Acesse a opção de importação de arquivo de alunos em "Cursos".',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
