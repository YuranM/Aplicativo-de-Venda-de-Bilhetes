import 'package:bilheteriapdm/widgets/title_text.dart';
import 'package:flutter/material.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:  Center(
        child:  TitleText(label: "Tela de perfil"),
      ),
    );
  }
}
