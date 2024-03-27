import 'package:bia/view/components/custom_button.dart';
import 'package:bia/model/models/pergunta.dart';
import 'package:bia/view-model/pergunta_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// the screen used to update a pergunta

class PerguntaUpdate extends StatefulWidget {
  final Function selectScreen;
  final Pergunta pergunta;
  const PerguntaUpdate(
    this.selectScreen,
    this.pergunta, {
    super.key,
  });

  @override
  State<PerguntaUpdate> createState() => _PerguntaUpdateState();
}

class _PerguntaUpdateState extends State<PerguntaUpdate> {
  bool _isLoading = false;

  final _formData = <String, Object>{};

  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // gets the initial values of the instance of pergunta being updated
    final Pergunta pergunta = widget.pergunta;

    _formData['id'] = pergunta.id;
    _formData['pergunta'] = pergunta.pergunta;
    _formData['resposta'] = pergunta.resposta;
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
      Provider.of<PerguntaList>(
        context,
        listen: false,
      ).update(_formData);

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
                        // pergunta is read only on the update screen
                        minLines: 1,
                        maxLines: 3,
                        initialValue: _formData['pergunta']?.toString(),
                        readOnly: true,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(height: 0.2),
                          label: Text('Pergunta'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: _formData['resposta']?.toString(),
                        keyboardType: TextInputType.multiline,
                        minLines: 9,
                        maxLines: 9,
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(height: 0.2),
                          label: const Text('Resposta'),
                          alignLabelWithHint: true,
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          hintText: 'Escreva a resposta ...',
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
