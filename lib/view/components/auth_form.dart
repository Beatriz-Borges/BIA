import 'package:bia/model/models/bia_user.dart';
import 'package:bia/view-model/auth_form_data.dart';
import 'package:flutter/material.dart';

// form for login an signup used reporposed from a online course

class AuthForm extends StatefulWidget {
  final void Function(AuthFormData) onSubmit;
  const AuthForm({required this.onSubmit, super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _authFormData = AuthFormData();

  void _submit() {
    final bool isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    widget.onSubmit(_authFormData);
  }

  List<DropdownMenuItem> tipoList() {
    List<DropdownMenuItem> list = [];
    for (var tipoUser in BIAUser.tipoList) {
      list.add(DropdownMenuItem(
        value: tipoUser,
        child: Text(tipoUser),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_authFormData.isSignup)
                TextFormField(
                  key: const ValueKey('name'),
                  initialValue: _authFormData.name,
                  onChanged: (name) => _authFormData.name = name,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    final name = value ?? '';

                    if (name.trim().isEmpty) return 'Nome é obrigatório';
                    if (name.trim().length <= 4) {
                      return 'Nome precisa ter mais de 4 caracteres';
                    }

                    return null;
                  },
                ),
              if (_authFormData.isSignup)
                DropdownButtonFormField(
                  key: const ValueKey('Tipo'),
                  borderRadius: BorderRadius.circular(10),
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const InputDecoration(
                    label: Text('Tipo de usuário'),
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                  ),
                  items: [...tipoList()],
                  value: _authFormData.tipo == '' ? null : _authFormData.tipo,
                  focusColor: const Color.fromRGBO(0, 0, 0, 0),
                  onChanged: (value) {
                    setState(() {
                      _authFormData.tipo = value;
                    });
                  },
                  validator: (value) {
                    final tipoUser = value ?? '';

                    if (tipoUser == '') {
                      return 'Tipo de Usuário é obrigatório';
                    }

                    return null;
                  },
                ),
              TextFormField(
                key: const ValueKey('email'),
                initialValue: _authFormData.email,
                onChanged: (email) => _authFormData.email = email,
                decoration:
                    const InputDecoration(labelText: 'E-mail Institucional'),
                validator: (value) {
                  final email = value ?? "";

                  if (email.trim().isEmpty) return 'Email é obrigatório';
                  if (!email.contains('@ifba.edu.br')) return 'Email inválido';

                  return null;
                },
              ),
              TextFormField(
                key: const ValueKey('password'),
                initialValue: _authFormData.password,
                onChanged: (password) => _authFormData.password = password,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  final password = value ?? '';

                  if (password.isEmpty) return 'Senha é obrigatório';
                  if (password.trim().length < 8) {
                    return 'Senha precisa ter pelo menos 8 caracteres';
                  }

                  return null;
                },
              ),
              const SizedBox(
                width: 12,
              ),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_authFormData.isLogin ? 'Entrar' : 'Cadastrar'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _authFormData.toggleAuthMode();
                  });
                },
                child: Text(
                  _authFormData.isLogin
                      ? 'Criar uma nova conta?'
                      : 'Já possui conta?',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
