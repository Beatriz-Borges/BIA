import 'package:bia/view/pages/home_page.dart';
import 'package:bia/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'auth_page.dart';
import 'loading_page.dart';

class AuthOrAppPage extends StatelessWidget {
  const AuthOrAppPage({super.key});

  // initializes the firebase app so that it can be used
  Future<void> init(BuildContext context) async {
    await Firebase.initializeApp();
  }

  // builds either the home page or the auth page depending on if the
  // user is logged in
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(context),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingPage();
        } else {
          return StreamBuilder(
            stream: AuthService().userChanges,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingPage();
              } else {
                return snapshot.hasData ? const HomePage() : const AuthPage();
              }
            },
          );
        }
      },
    );
  }
}
