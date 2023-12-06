import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text_field.dart';
import 'package:bia/model/models/professor.dart';
import 'package:bia/view-model/professor_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// screen to create a new professor

class ProfessorCreate extends StatefulWidget {
  final Function selectScreen;
  final Professor? professor;
  const ProfessorCreate(this.selectScreen, this.professor, {super.key});

  @override
  State<ProfessorCreate> createState() => _ProfessorCreateState();
}

class _ProfessorCreateState extends State<ProfessorCreate> {
  bool _isLoading = false;

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
      Provider.of<ProfessorList>(
        context,
        listen: false,
      ).addProfessorFromData(_formData);

      widget.selectScreen(0, professor: widget.professor);
    } catch (error) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro ao salvar o professor.'),
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
    // gets provider for professores
    final professorList = Provider.of<ProfessorList>(context, listen: false);

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

                          if (telefone.trim().isEmpty) {
                            return 'Telefone é obrigatório';
                          }

                          if (telefone.trim().length <= 8) {
                            return 'Telefone precisa ter mais de 8 números';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: const Text('Siape'),
                        hintText: '20001ireadsS0001',
                        onSaved: (siap) =>
                            _formData['siap'] = siap?.toLowerCase() ?? '',
                        validator: (value) {
                          final siap = value ?? '';

                          if (siap.trim().isEmpty) {
                            return 'Siap é obrigatório';
                          }

                          if (siap.trim().length <= 6) {
                            return 'Siap precisa ter mais de 6 caracteres';
                          }

                          for (var professor in professorList.items) {
                            if (professor.siap == siap) {
                              return 'Siap já existe';
                            }
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(height: 150),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomButton(
                                  onPressed: submitForm,
                                  child: const Text('Salvar'),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomButton(
                                  onPressed: () {
                                    widget.selectScreen(
                                      0,
                                      professor: widget.professor,
                                    );
                                  },
                                  child: const Text('Cancelar'),
                                ),
                              ],
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
