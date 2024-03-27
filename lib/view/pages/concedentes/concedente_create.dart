import 'package:bia/view/components/custom_text_field.dart';
import 'package:bia/model/models/concedente.dart';
import 'package:bia/view-model/concedente_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_button.dart';

// the screen used to create a new concedente

class ConcedenteCreate extends StatefulWidget {
  final Function selectScreen;
  final Concedente? concedente;
  const ConcedenteCreate(this.selectScreen, this.concedente, {super.key});

  @override
  State<ConcedenteCreate> createState() => _ConcedenteCreateState();
}

class _ConcedenteCreateState extends State<ConcedenteCreate> {
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
      Provider.of<ConcedenteList>(
        context,
        listen: false,
      ).addConcedenteFromData(_formData);

      widget.selectScreen(0, concedente: widget.concedente);
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
    final concedenteList = Provider.of<ConcedenteList>(context, listen: false);
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
                      CustomTextField(
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
                      //   hintText: 'Bahia',
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
                      //   hintText: 'Brasil',
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
                        label: const Text('CNPJ'),
                        hintText: '12345678000100',
                        onSaved: (cnpj) => _formData['cnpj'] = cnpj ?? '',
                        validator: (value) {
                          final cnpj = value ?? '';

                          if (cnpj.trim().isEmpty) {
                            return 'CNPJ é obrigatório';
                          }

                          if (cnpj.trim().length <= 13) {
                            return 'CNPJ precisa ter mais de 13 números';
                          }

                          for (var concedente in concedenteList.items) {
                            if (concedente.cnpj == cnpj) {
                              return 'CNPJ já existe';
                            }
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
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
                      //   onSaved: (endereco) {
                      //     _formData['endereço'] = endereco ?? '';
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
                                widget.selectScreen(
                                  0,
                                  concedente: widget.concedente,
                                );
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
