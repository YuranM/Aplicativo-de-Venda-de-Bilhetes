import 'package:bilheteriapdm/widgets/subtitles_text.dart';
import 'package:bilheteriapdm/widgets/title_text.dart';
import 'package:flutter/material.dart';

class QuantityBottomSheetWidget extends StatelessWidget {
  const QuantityBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        const SizedBox(
         height: 20,
        ),
        Container(
          height: 6,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.grey,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      Expanded(
        child: ListView.builder(
        itemCount: 30,
        itemBuilder: (context, index){
          return GestureDetector(
              onTap: (){
                print("index ${index + 1}");
              },
              child: SubtitlesText(
                  label: "${index + 1}"));
        },
            ),
      )
      ],
    );
  }
}
