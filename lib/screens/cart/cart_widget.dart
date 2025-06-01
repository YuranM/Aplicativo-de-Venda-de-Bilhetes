import 'package:bilheteriapdm/screens/cart/qnt_btm_sheet_widget.dart';
import 'package:bilheteriapdm/widgets/subtitles_text.dart';
import 'package:bilheteriapdm/widgets/title_text.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return FittedBox(
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FancyShimmerImage(
                  imageUrl:
                    "https://www.nike.com/za/w/air-max-shoes-a6d8hzy7ok",
                height: size.height * 0.2,
                width: size.width * 0.2,
                ), //colocar link da imagem
              ),
          const SizedBox(
            width: 10,
        ),
          IntrinsicWidth(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: size.width * 0.6,
                        child: FittedBox(
                          child: TitleText(
                              label: "Titulo" * 10,
                            maxLines: 2,
                          ),
                        ),
                    ),
                    Column(
                      children: [
                        IconButton(onPressed: (){},
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                        ),
                        IconButton(onPressed: (){},
                          icon: const Icon(
                            IconlyLight.heart,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                    ],
                  ),
                Row(
                  children: [
                    const SubtitlesText(
                        label: "16\$",
                        fontSize: 20,
                        color: Colors.blue,
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: const BorderSide(
                          width: 2,
                          color: Colors.blue,
                        )
                      ),
                        onPressed: () async {
                        await showModalBottomSheet(
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            )
                          ),
                          context: context,
                          builder: (context){
                            return const QuantityBottomSheetWidget();
                          },
                        );
                        },
                        icon: const Icon(IconlyLight.arrowDown2),
                        label: const Text("Quantidade : 6"),
                        ),
                  ],
                ),
              ],
            ),

          ),
          ],
          ),
        ),
      ),
    );
  }
}
