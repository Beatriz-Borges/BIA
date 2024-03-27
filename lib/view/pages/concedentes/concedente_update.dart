import 'package:bia/view/components/custom_text_field.dart';
import 'package:bia/model/models/concedente.dart';
import 'package:bia/view-model/concedente_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_button.dart';

// the screen used to update a concedente

class ConcedenteUpdate extends StatefulWidget {
  final Function selectScreen;
  final Concedente concedente;
  const ConcedenteUpdate(this.selectScreen, this.concedente, {super.key});

  @override
  State<ConcedenteUpdate> createState() => _ConcedenteUpdateState();
}

class _ConcedenteUpdateState extends State<ConcedenteUpdate> {
  bool _isLoading = false;

  final _formData = <String, Object>{};

  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // gets the initial values of the instance of concedente being updated
    final Concedente concedente = widget.concedente;

    _formData['id'] = concedente.id;
    _formData['cnpj'] = concedente.cnpj;
    _formData['nome'] = concedente.nome;
    // _formData['nomeFantasia'] = concedente.nomeFantasia;
    // _formData['nomeOficial'] = concedente.nomeOficial;
    // _formData['estado'] = concedente.estado;
    // _formData['pais'] = concedente.pais;
    // _formData['endereco'] = concedente.endereco;
    _formData['email'] = concedente.email;
    _formData['telefoneEmpresa'] = concedente.telefoneEmpresa;
    _formData['responsavel'] = concedente.responsavel;
    _formData['telefoneResponsavel'] = concedente.telefoneResponsavel;
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
      Provider.of<ConcedenteList>(
        context,
        listen: false,
      ).update(_formData);

      widget.selectScreen(0);
    } catch (error) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro ao salvar o concedente'),
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
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        // cnpj field is read only in the update screen
                        initialValue: _formData['cnpj']?.toString(),
                        readOnly: true,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(height: 0.2),
                          label: Text('CNPJ'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        initialValue: _formData['nome']?.toString(),
                        label: const Text('Nome'),
                        hintText: 'DELL',
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
                      // CustomTextField(
                      //   label: const Text('Nome Fantasia'),
                      //   hintText: 'DELL',
                      //   onSaved: (nomeFantasia) =>
                      //       _formData['nomeFantasia'] = nomeFantasia ?? '',
                      //   validator: (value) {
                      //     final nomeFantasia = value ?? '';

                      //     if (nomeFantasia.trim().isEmpty) {
                      //       return 'Nome Fantasia é obrigatório';
                      //     }

                      //     if (nomeFantasia.trim().length <= 3) {
                      //       return 'Nome Fantasia precisa ter mais de 3 letras';
                      //     }

                      //     return null;
                      //   },
                      // ),
                      // const SizedBox(height: 10),
                      // CustomTextField(
                      //   label: const Text('Nome Oficial'),
                      //   hintText: 'DELL',
                      //   onSaved: (nomeOficial) =>
                      //       _formData['nomeOficial'] = nomeOficial ?? '',
                      //   validator: (value) {
                      //     final nomeOficial = value ?? '';

                      //     if (nomeOficial.trim().isEmpty) {
                      //       return 'Nome Oficial é obrigatório';
                      //     }

                      //     if (nomeOficial.trim().length <= 3) {
                      //       return 'Nome Oficial precisa ter mais de 3 letras';
                      //     }

                      //     return null;
                      //   },
                      // ),
                      // const SizedBox(height: 10),
                      // CustomTextField(
                      //   label: const Text('Estado'),
                      //   hintText: 'DELL',
                      //   onSaved: (estado) => _formData['estado'] = estado ?? '',
                      //   validator: (value) {
                      //     final estado = value ?? '';

                      //     if (estado.trim().isEmpty) {
                      //       return 'Estado é obrigatório';
                      //     }

                      //     if (estado.trim().length <= 3) {
                      //       return 'Estado precisa ter mais de 3 letras';
                      //     }

                      //     return null;
                      //   },
                      // ),
                      // const SizedBox(height: 10),
                      // CustomTextField(
                      //   label: const Text('Pais'),
                      //   hintText: 'DELL',
                      //   onSaved: (pais) => _formData['pais'] = pais ?? '',
                      //   validator: (value) {
                      //     final pais = value ?? '';

                      //     if (pais.trim().isEmpty) {
                      //       return 'pais é obrigatório';
                      //     }

                      //     if (pais.trim().length <= 3) {
                      //       return 'pais precisa ter mais de 3 letras';
                      //     }

                      //     return null;
                      //   },
                      // ),
                      // const SizedBox(height: 10),
                      CustomTextField(
                        initialValue: _formData['email']?.toString(),
                        label: const Text('E-mail da Empresa'),
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
                        initialValue: _formData['telefoneEmpresa']?.toString(),
                        label: const Text('Telefone da Empresa'),
                        hintText: '074912345678',
                        onSaved: (telefone) =>
                            _formData['telefoneEmpresa'] = telefone ?? '',
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
                        initialValue: _formData['responsavel']?.toString(),
                        label: const Text('Responsável'),
                        hintText: 'Maria José',
                        onSaved: (responsavel) => _formData['responsavel'] =
                            responsavel?.toUpperCase() ?? '',
                        validator: (value) {
                          final responsavel = value ?? '';

                          if (responsavel.trim().isEmpty) {
                            return 'Responsável é obrigatório';
                          }

                          if (responsavel.trim().length <= 3) {
                            return 'Responsável precisa ter mais de 3 letras';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        initialValue:
                            _formData['telefoneResponsavel']?.toString(),
                        label: const Text('Telefone do Responsável'),
                        hintText: '074912345678',
                        onSaved: (telefoneResponsavel) =>
                            _formData['telefoneResponsavel'] =
                                telefoneResponsavel ?? '',
                        validator: (value) {
                          final telefoneResponsavel = value ?? '';

                          if (telefoneResponsavel.trim().isEmpty) {
                            return 'Telefone do responsável é obrigatório';
                          }

                          if (telefoneResponsavel.trim().length <= 8) {
                            return 'Telefone do responsável precisa ter mais de 8 números';
                          }

                          return null;
                        },
                      ),
                      // const SizedBox(height: 10),
                      // TextFormField(
                      //   keyboardType: TextInputType.multiline,
                      //   minLines: 3,
                      //   maxLines: 3,
                      //   decoration: InputDecoration(
                      //     errorStyle: const TextStyle(height: 0.2),
                      //     label: const Text('Endereço'),
                      //     floatingLabelAlignment: FloatingLabelAlignment.center,
                      //     hintText: 'Digite o endereço ...',
                      //     hintStyle: const TextStyle(
                      //       color: Colors.grey,
                      //     ),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //   ),
                      //   onSaved: (descricao) {
                      //     _formData['endereço'] = descricao ?? '';
                      //   },
                      // ),
                      const SizedBox(height: 100),
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
