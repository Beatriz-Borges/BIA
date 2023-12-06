import 'package:bia/view/components/custom_button.dart';
import 'package:bia/model/models/ideia.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:bia/view-model/ideia_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// the screen used to update an ideia

class IdeiaUpdate extends StatefulWidget {
  final Function selectScreen;
  final Ideia ideia;
  const IdeiaUpdate(
    this.selectScreen,
    this.ideia, {
    super.key,
  });

  @override
  State<IdeiaUpdate> createState() => _IdeiaUpdateState();
}

class _IdeiaUpdateState extends State<IdeiaUpdate> {
  bool _isLoading = false;

  String? _selectedCurso;

  final _formData = <String, Object>{};

  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // gets the initial values of the instance of ideia being updated
    final Ideia ideia = widget.ideia;

    _formData['id'] = ideia.id;
    _formData['titulo'] = ideia.titulo;
    _formData['cursoId'] = ideia.cursoId;
    _selectedCurso = ideia.cursoId;
    _formData['descricao'] = ideia.descricao;
    _formData['userId'] = ideia.userId;
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
      Provider.of<IdeiaList>(
        context,
        listen: false,
      ).update(_formData);

      widget.selectScreen(0);
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
                      TextFormField(
                        // titulo is ready only in the update screen
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
                        initialValue: _formData['descricao']?.toString(),
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
