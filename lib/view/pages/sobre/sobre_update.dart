import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text_field.dart';
import 'package:bia/model/models/sobre.dart';
import 'package:bia/view-model/sobre_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// the screen used to update an sobre

class SobreUpdate extends StatefulWidget {
  final Function selectScreen;
  final Sobre sobre;
  const SobreUpdate(
    this.selectScreen,
    this.sobre, {
    super.key,
  });

  @override
  State<SobreUpdate> createState() => _SobreUpdateState();
}

class _SobreUpdateState extends State<SobreUpdate> {
  bool _isLoading = false;

  final _formData = <String, Object>{};

  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // gets the initial values of the instance of sobre being updated
    final Sobre sobre = widget.sobre;

    _formData['id'] = sobre.id;
    _formData['titulo'] = sobre.titulo;
    _formData['texto'] = sobre.texto;
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
      Provider.of<SobreList>(
        context,
        listen: false,
      ).update(_formData);

      widget.selectScreen(0);
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
                        // the título is not allowd to be updated
                        initialValue: _formData['titulo']?.toString(),
                        readOnly: true,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(height: 0.2),
                          label: Text('Título'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        initialValue: _formData['texto']?.toString(),
                        label: const Text('Texto'),
                        hintText: 'Maria José...',
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
                                          sobre: null,
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
