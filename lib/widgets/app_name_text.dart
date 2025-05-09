import 'package:bilheteriapdm/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppNameTextWidget extends StatelessWidget {

  final double fontSize;
  const AppNameTextWidget({super.key, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.blueAccent,
        highlightColor: Colors.yellowAccent,
        child: TitleText(label: "Yuran Bilhetes",
          fontSize: fontSize,)
    );
  }
}
