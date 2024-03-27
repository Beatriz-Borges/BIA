import 'package:bia/view/components/custom_button.dart';
import 'package:bia/view/components/custom_text_field.dart';
import 'package:bia/model/models/curso.dart';
import 'package:bia/model/models/professor.dart';
import 'package:bia/view-model/curso_list.dart';
import 'package:bia/view-model/professor_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// the screen used to update a curso

class CursoUpdate extends StatefulWidget {
  final Function selectScreen;
  final Curso curso;
  const CursoUpdate(this.selectScreen, this.curso, {super.key});

  @override
  State<CursoUpdate> createState() => _CursoUpdateState();
}

class _CursoUpdateState extends State<CursoUpdate> {
  bool _isLoading = false;

  final _formData = <String, Object>{'curricular': false};

  final _formKey = GlobalKey<FormState>();

  String? _selectedNivel;
  String? _selectedProfessor;

  String? oldCoordenador;

  // creates a list of cursos.nivel to be used in the dropdown widget
  List<DropdownMenuItem> niveis() {
    List<DropdownMenuItem> list = [];
    for (var nivel in Curso.niveis) {
      list.add(DropdownMenuItem(
        value: nivel,
        child: Text(nivel),
      ));
    }
    return list;
  }

  // creates a nullable list of professores to be used in the dropdown
  // widget
  List<DropdownMenuItem> professores() {
    List<DropdownMenuItem> list = [];
    list.add(const DropdownMenuItem(
      value: '',
      child: Text('-'),
    ));
    final List<Professor> listProfessores =
        Provider.of<ProfessorList>(context, listen: false).items;
    listProfessores.sort((a, b) {
      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    });
    // makes sure that it doesn't show professor that is
    // coordenador de curso on another curso
    for (var professor in listProfessores.where(
      (professor) =>
          professor.cursoId == null || professor.cursoId == widget.curso.id,
    )) {
      list.add(
        DropdownMenuItem(
          value: professor.id,
          child: Text(professor.nome),
        ),
      );
    }
    return list;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // gets the initial values of the instance of curso being updated
    final Curso curso = widget.curso;

    _formData['id'] = curso.id;
    _formData['nome'] = curso.nome;
    _formData['sigla'] = curso.sigla;
    _formData['nivel'] = curso.nivel;
    _selectedNivel = curso.nivel;
    if (curso.coordenadorId != null) {
      _formData['coordenadorId'] = curso.coordenadorId!;
      _selectedProfessor = curso.coordenadorId!;
    } else {
      _formData['coordenadorId'] = '';
    }
    oldCoordenador = curso.coordenadorId;
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
      Provider.of<CursoList>(
        context,
        listen: false,
      ).update(_formData);

      widget.selectScreen(0);
    } catch (error) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro ao salvar o curso'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    } finally {
      // updates the coordenador de curso on the side of professor
      ProfessorList professorList =
          Provider.of<ProfessorList>(context, listen: false);
      if (_formData['coordenadorId'] != oldCoordenador) {
        // if coordenadorId changed then it updates the new professor
        professorList.vinculaCurso(
          _formData['coordenadorId'] as String,
          _formData['id'] as String,
        );
        if (oldCoordenador != null) {
          // if it changed professor and there was an professor before
          // it updates the last professor to not be coordenador de curso
          professorList.vinculaCurso(oldCoordenador!, null);
        }
      }
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
                      TextFormField(
                        // sigla is read only on the update screen
                        initialValue: _formData['sigla']?.toString(),
                        readOnly: true,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(height: 0.2),
                          label: Text('Sigla'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        initialValue: _formData['nome']?.toString(),
                        label: const Text('Nome'),
                        hintText: 'Informática',
                        onSaved: (nome) => _formData['nome'] = nome ?? '',
                        validator: (value) {
                          final nome = value ?? '';

                          if (nome.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }

                          if (nome.trim().length <= 3) {
                            return 'Nome precisa ter mais de 3 letras';
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
                          label: Text('Nível'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                        ),
                        items: [...niveis()],
                        value: _selectedNivel,
                        focusColor: const Color.fromRGBO(0, 0, 0, 0),
                        onChanged: (value) {
                          setState(() {
                            if (value == '') {
                              _selectedNivel = null;
                            } else {
                              _selectedNivel = value;
                              _formData['nivel'] = _selectedNivel!;
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Nível é obrigatório';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField(
                        borderRadius: BorderRadius.circular(10),
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: const InputDecoration(
                          label: Text('Coordenador'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                        ),
                        items: [...professores()],
                        value: _selectedProfessor,
                        focusColor: const Color.fromRGBO(0, 0, 0, 0),
                        onChanged: (value) {
                          setState(() {
                            _selectedProfessor = value;
                            _formData['coordenadorId'] =
                                _selectedProfessor ?? '';
                          });
                        },
                        validator: (value) {
                          return null;
                        },
                      ),
                      const SizedBox(height: 300),
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
