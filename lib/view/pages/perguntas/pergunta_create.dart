import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view-model/pergunta_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// screen to create a new pergunta

class PerguntaCreate extends StatefulWidget {
  final Function selectScreen;
  const PerguntaCreate(this.selectScreen, {super.key});

  @override
  State<PerguntaCreate> createState() => _PerguntaCreateState();
}

class _PerguntaCreateState extends State<PerguntaCreate> {
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
      Provider.of<PerguntaList>(
        context,
        listen: false,
      ).addPerguntaFromData(_formData);

      widget.selectScreen(0);
    } catch (error) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro ao salvar a pergunta.'),
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
    final perguntaList = Provider.of<PerguntaList>(context, listen: false);

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
                      const SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        minLines: 3,
                        maxLines: 3,
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(height: 0.2),
                          label: const Text('Pergunta'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          hintText: 'Escreva a pergunta ...',
                          alignLabelWithHint: true,
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onSaved: (pergunta) {
                          _formData['pergunta'] = pergunta ?? '';
                        },
                        validator: (value) {
                          final perguntaTitle = value ?? '';

                          if (perguntaTitle.trim().isEmpty) {
                            return 'Pergunta é obrigatório';
                          }

                          if (perguntaTitle.trim().length <= 3) {
                            return 'Pergunta precisa ter mais de 3 letras';
                          }

                          for (var pergunta in perguntaList.items) {
                            if (pergunta.pergunta == perguntaTitle) {
                              return 'Pergunta já existe';
                            }
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        minLines: 9,
                        maxLines: 9,
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(height: 0.2),
                          label: const Text('Resposta'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          hintText: 'Escreva a resposta ...',
                          alignLabelWithHint: true,
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onSaved: (resposta) {
                          _formData['resposta'] = resposta ?? '';
                        },
                        validator: (value) {
                          final resposta = value ?? '';

                          if (resposta.trim().isEmpty) {
                            return 'Resposta é obrigatório';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 200),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                        widget.selectScreen(0);
                                      },
                                      child: const Text('Cancelar'),
                                    ),
                                  ],
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
