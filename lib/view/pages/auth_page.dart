import 'package:bia/view/components/auth_form.dart';
import 'package:bia/view/components/custom_text.dart';
import 'package:bia/services/auth_service.dart';
import 'package:bia/view-model/auth_form_data.dart';
import 'package:flutter/material.dart';
import 'package:simple_shadow/simple_shadow.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLoading = false;
  String? response;

  Future<void> handleSubmit(AuthFormData data) async {
    setState(() {
      isLoading = true;
    });

    if (data.isLogin) {
      AuthService().login(data.email, data.password).whenComplete(
        () {
          setState(() {
            isLoading = false;
          });
        },
      ).catchError(
        (e) {
          showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Algo deu errado'),
              content: Text(
                e.toString(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('ok'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      AuthService()
          .signup(
        data.name,
        data.email,
        data.password,
        data.tipo,
      )
          .whenComplete(
        () {
          setState(() {
            isLoading = false;
          });
        },
      ).catchError(
        (e) {
          showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Algo deu errado'),
              content: Text(
                e.toString(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: const Text('ok'),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'logo',
                  child: SimpleShadow(
                    child: Image.asset(
                      scale: .7,
                      'assets/images/biaLogo.png',
                    ),
                  ),
                ),
                const Text(
                  'BASIC INTERNSHIP ADMINISTRATOR',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 50, 48, 1)),
                ),
              ],
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: AuthForm(onSubmit: handleSubmit),
            ),
          ),
          Positioned(
            top: maxHeight - 120,
            left: maxWidth / 2 - 25,
            child: Column(
              children: [
                Image.asset('assets/images/white-ifba-logo.png'),
                const CustomText(
                  title: 'INSTITUTO\n  FEDERAL\n',
                  corTitle: Colors.white,
                  fontSizeTitle: 12,
                  text: '     BAHIA',
                  cor: Colors.white,
                  fontSize: 11,
                )
              ],
            ),
          ),
          if (isLoading)
            Container(
              decoration:
                  const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5)),
              child: const Center(
                child: CircularProgressIndicator(
                    // color: Colors.black,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
