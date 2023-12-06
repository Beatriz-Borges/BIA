import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text_field.dart';
import 'package:bia/model/models/ideia.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:bia/view-model/ideia_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// screen to create a new ideia

class IdeiaCreate extends StatefulWidget {
  final Function selectScreen;
  final Ideia? ideia;
  const IdeiaCreate(this.selectScreen, this.ideia, {super.key});

  @override
  State<IdeiaCreate> createState() => _IdeiaCreateState();
}

class _IdeiaCreateState extends State<IdeiaCreate> {
  bool _isLoading = false;

  String? _selectedCurso;

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
      // gets the userId for the ideia from the current user
      _formData['userId'] = AuthService().currentUser!.tipoId;
      Provider.of<IdeiaList>(
        context,
        listen: false,
      ).addIdeiaFromData(_formData);

      widget.selectScreen(0, ideia: widget.ideia);
    } catch (error) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro ao salvar a ideia.'),
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
    // gets provider for ideias
    final ideiaList = Provider.of<IdeiaList>(context, listen: false);

    // creates a list of cursos for a dropdown widget
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
                        hintText: 'Título',
                        onSaved: (titulo) => _formData['titulo'] = titulo ?? '',
                        validator: (value) {
                          final titulo = value ?? '';

                          if (titulo.trim().isEmpty) {
                            return 'Título é obrigatório';
                          }

                          if (titulo.trim().length <= 3) {
                            return 'Título precisa ter mais de 3 letras';
                          }

                          for (var ideia in ideiaList.items) {
                            if (ideia.titulo == titulo) {
                              return 'Título já existe';
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
                          label: Text('Curso'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                        ),
                        items: [...cursos()],
                        value: _selectedCurso,
                        focusColor: const Color.fromRGBO(0, 0, 0, 0),
                        onChanged: (value) {
                          setState(() {
                            if (value == '') {
                              _selectedCurso = null;
                            } else {
                              _selectedCurso = value;
                              _formData['cursoId'] = _selectedCurso ?? '';
                            }
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
                        keyboardType: TextInputType.multiline,
                        minLines: 9,
                        maxLines: 9,
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(height: 0.2),
                          label: const Text('Descrição'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          hintText: 'Fale um pouco sobre a ideia ...',
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
                                'Cadastre sua ideia para virar uma oportunidade de estágio',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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
                                      child: const Text('Enviar'),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    CustomButton(
                                      onPressed: () {
                                        widget.selectScreen(
                                          0,
                                          ideia: widget.ideia,
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
