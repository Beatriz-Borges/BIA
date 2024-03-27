import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text_field.dart';
import 'package:bia/model/models/aluno.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/view-model/aluno_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// the screen used to update an aluno

class AlunoUpdate extends StatefulWidget {
  final Function selectScreen;
  final Aluno aluno;
  const AlunoUpdate(
    this.selectScreen,
    this.aluno, {
    super.key,
  });

  @override
  State<AlunoUpdate> createState() => _AlunoUpdateState();
}

class _AlunoUpdateState extends State<AlunoUpdate> {
  bool _isLoading = false;

  bool _eCurricular = false;
  bool _eExtraCurricular = false;

  final _formData = <String, Object>{};

  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // gets the initial values of the instance of aluno being updated
    final Aluno aluno = widget.aluno;

    _formData['id'] = aluno.id;
    _formData['matricula'] = aluno.matricula;
    _formData['nome'] = aluno.nome;
    _formData['email'] = aluno.email;
    _formData['telefone'] = aluno.telefone;
    _formData['eExtraCurricular'] = aluno.eExtraCurricular;
    _eExtraCurricular = aluno.eExtraCurricular;
    _formData['eCurricular'] = aluno.eCurricular;
    _eCurricular = aluno.eCurricular;
    _formData['cursoId'] = aluno.cursoId;
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
      Provider.of<AlunoList>(
        context,
        listen: false,
      ).update(_formData);

      widget.selectScreen(0);
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
    final user = AuthService().currentUser!;
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
                      TextFormField(
                        // the matrícula is not allowd to be updated
                        initialValue: _formData['matricula']?.toString(),
                        readOnly: true,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(height: 0.2),
                          label: Text('Matrícula'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      !['Aluno'].contains(user.tipo)
                          ? CustomTextField(
                              initialValue: _formData['nome']?.toString(),
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
                            )
                          : TextFormField(
                              initialValue: _formData['nome']?.toString(),
                              readOnly: true,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                errorStyle: TextStyle(height: 0.2),
                                label: Text('Nome'),
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.center,
                              ),
                            ),
                      const SizedBox(height: 10),
                      !['Aluno'].contains(user.tipo)
                          ? CustomTextField(
                              initialValue: _formData['email']?.toString(),
                              label: const Text('E-mail'),
                              hintText: 'realemail@notfake.com',
                              onSaved: (email) => _formData['email'] =
                                  email?.toLowerCase() ?? '',
                              validator: (value) {
                                final email = value ?? '';
                                if (email.trim().isEmpty ||
                                    !email.contains('@')) {
                                  return 'Informe um e-mail válido';
                                }
                                return null;
                              },
                            )
                          : TextFormField(
                              initialValue: _formData['email']?.toString(),
                              readOnly: true,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                errorStyle: TextStyle(height: 0.2),
                                label: Text('E-mail'),
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.center,
                              ),
                            ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        // if the user is an aluno, they can only change
                        // their telefone number
                        initialValue: _formData['telefone']?.toString(),
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
                                onChanged: !['Aluno'].contains(user.tipo)
                                    ? (value) {
                                        setState(() {
                                          _eCurricular = value!;
                                          _formData['eCurricular'] =
                                              _eCurricular;
                                        });
                                      }
                                    : null,
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
                                onChanged: !['Aluno'].contains(user.tipo)
                                    ? (value) {
                                        setState(() {
                                          _eExtraCurricular = value!;
                                          _formData['eExtraCurricular'] =
                                              _eExtraCurricular;
                                        });
                                      }
                                    : null,
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
                                          aluno: null,
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
