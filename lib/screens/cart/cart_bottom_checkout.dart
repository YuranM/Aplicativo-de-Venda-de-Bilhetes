import 'package:bilheteriapdm/widgets/subtitles_text.dart';
import 'package:bilheteriapdm/widgets/title_text.dart';
import 'package:flutter/material.dart';

class CartBottomCheckout extends StatelessWidget {
  const CartBottomCheckout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(
            width: 1,
            color: Colors.grey,
          ),
        ),
      ),
      child: SizedBox(
        height: kBottomNavigationBarHeight + 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                        child: TitleText(label: "Total (6 products/6 Itens)" )),
                    SubtitlesText(label: "16.99\$",
                      color: Colors.blue,
                    )
                  ],
                ),
              ),
              ElevatedButton(
                  onPressed: (){},
                  child: Text("Ckeckout"))
            ],
          ),
        ),
      ),
    );
  }
}
