import 'package:bilheteriapdm/consts/app_constants.dart';
import 'package:bilheteriapdm/widgets/subtitles_text.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class UltimosEventosWidget extends StatelessWidget {
  const UltimosEventosWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: (){
          print("Navegar para detalhes do produto");
        },
        child: SizedBox(
          width: size.width * 0.45,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FancyShimmerImage(
                    imageUrl: AppConstants.productImageUrl,
                    width: size.width * 0.28,
                    height: size.width * 0.28,
                  ),
                ),
              ),
              const SizedBox(
                width: 7,
              ),
              Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Title" * 10,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  FittedBox(
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: (){},
                            icon: const Icon(
                              IconlyLight.heart,
                            ),
                        ),
                        IconButton(
                          onPressed: (){},
                          icon: const Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const FittedBox(
                    child: SubtitlesText(
                      label: "166.5\$",
                      color: Colors.blue,),
                  )
                ],
              )

              )
            ],
          ),
        ),
      ),
    );
  }
}
