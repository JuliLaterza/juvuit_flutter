import 'package:flutter/material.dart';

class AppLogoHeader extends StatelessWidget {
  const AppLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          'assets/images/homescreen/logo_witu.png',
          height: 32,
        ),
      ),
    );
  }
} 