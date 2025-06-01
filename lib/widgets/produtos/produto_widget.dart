import 'package:bilheteriapdm/widgets/subtitles_text.dart';
import 'package:bilheteriapdm/widgets/title_text.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../../consts/app_constants.dart';

class ProdutoWidget extends StatefulWidget {
  const ProdutoWidget({super.key});

  @override
  State<ProdutoWidget> createState() => _ProdutoWidgetState();
}

class _ProdutoWidgetState extends State<ProdutoWidget> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: (){
          print("Navigate to product Detail Screen");
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: FancyShimmerImage(
                  imageUrl: AppConstants.productImageUrl,
                  height: size.height * 0.22,
                  width: double.infinity,
              ),
            ),
            Row(
              children: [
                  Flexible(
                    flex: 5,
                      child: TitleText(label: "Title" * 10),
                  ),
                IconButton(
                    onPressed: (){},
                    icon: const Icon(
                      IconlyLight.heart,
                    ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SubtitlesText(
                    label: "166.5\$"
                ),
                Material(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.lightBlue,
                  child: IconButton(
                    splashColor: Colors.red,
                    splashRadius: 27.0,
                    onPressed: (){},
                    icon: Icon(
                      Icons.add_shopping_cart,
                  ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
