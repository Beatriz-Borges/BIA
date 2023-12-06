import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text_field.dart';
import 'package:bia/model/models/sobre.dart';
import 'package:bia/view-model/sobre_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// screen to create a new sobre

class SobreCreate extends StatefulWidget {
  final Function selectScreen;
  final Sobre? ideia;
  const SobreCreate(this.selectScreen, this.ideia, {super.key});

  @override
  State<SobreCreate> createState() => _SobreCreateState();
}

class _SobreCreateState extends State<SobreCreate> {
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
      Provider.of<SobreList>(
        context,
        listen: false,
      ).addsobreFromData(_formData);

      widget.selectScreen(0, sobre: widget.ideia);
    } catch (error) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro ao salvar o sobre.'),
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
    // gets provider for sobre
    final sobreList = Provider.of<SobreList>(context, listen: false);

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
                        label: const Text('Título'),
                        hintText: 'Titulo...',
                        onSaved: (titulo) => _formData['titulo'] = titulo ?? '',
                        validator: (value) {
                          final titulo = value ?? '';

                          if (titulo.trim().isEmpty) {
                            return 'Titulo é obrigatório';
                          }

                          if (titulo.trim().length <= 3) {
                            return 'Titulo precisa ter mais de 3 letras';
                          }

                          for (var sobre in sobreList.items) {
                            if (sobre.titulo == titulo) {
                              return 'Título já existe';
                            }
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        label: const Text('Texto'),
                        hintText: 'Texto...',
                        onSaved: (texto) => _formData['texto'] = texto ?? '',
                        validator: (value) {
                          final texto = value ?? '';

                          if (texto.trim().isEmpty) {
                            return 'Texto é obrigatório';
                          }

                          if (texto.trim().length <= 3) {
                            return 'Texto precisa ter mais de 3 letras';
                          }

                          return null;
                        },
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
                                          sobre: widget.ideia,
                                        );
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
