import 'package:bilheteriapdm/providers/theme_provider.dart';
import 'package:bilheteriapdm/widgets/subtitles_text.dart';
import 'package:bilheteriapdm/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TitleText(
              label: "Titulo esta aqui"
          ),
          const SubtitlesText(
            label: "Bem vindo de volta",
            color: Colors.blueAccent,

          ),
        ],
      )
    );
  }
}
