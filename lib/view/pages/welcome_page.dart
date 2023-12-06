import 'package:bia/view/components/custom_text.dart';
import 'package:bia/services/auth_firebase_service.dart';
import 'package:bia/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:simple_shadow/simple_shadow.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    // gets the sizes of the screen
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;
    AuthFirebaseService().loadUsers();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: InkWell(
        onTap: () {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.home,
          );
        },
        // the stack is used to position the assets in they proper places
        // allowing fot the parts to be positioned on top of each other
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 180,
              left: maxWidth / 2 - 80,
              child: Hero(
                tag: 'logo',
                child: SimpleShadow(
                  child: Image.asset(
                    scale: .7,
                    'assets/images/biaLogo.png',
                  ),
                ),
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
          ],
        ),
      ),
    );
  }
}
