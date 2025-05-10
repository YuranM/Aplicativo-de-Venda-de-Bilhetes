import 'package:bilheteriapdm/widgets/subtitles_text.dart';
import 'package:bilheteriapdm/widgets/title_text.dart';
import 'package:flutter/material.dart';


class EmptyWidgetBag extends StatelessWidget {
  final String imagePath, title, subtitle, buttonText;

  const EmptyWidgetBag(
      {super.key,
        required this.imagePath,
        required this.title,
        required this.subtitle,
        required this.buttonText});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: Column(
            children: [
              Image.asset(
                imagePath,
                height: size.height * 0.35,
                width: double.infinity,
              ),
              TitleText(
                  label:
                  "Opps",
                  fontSize: 40,
                  color:
                  Colors.red
              ),
              SizedBox(
                height: 20 ,
              ),
              SubtitlesText(
                label:
                title,
                fontWeight: FontWeight.w600,
                fontSize: 25,
              ),
              SizedBox(
                height: 20 ,
              ),
              SubtitlesText(
                label:subtitle,
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
              SizedBox(
                height: 30 ,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20),
                ),
                onPressed: (){},
                child:
                Text(buttonText),
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
    );
  }
}
