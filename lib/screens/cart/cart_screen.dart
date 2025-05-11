import 'package:bilheteriapdm/screens/cart/cart_widget.dart';
import 'package:bilheteriapdm/widgets/empty_widget_bag.dart';
import 'package:bilheteriapdm/widgets/subtitles_text.dart';
import 'package:bilheteriapdm/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../../services/assets_manager.dart' show AssetsManager;


class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  final bool isEmpty = false;

  @override
  Widget build(BuildContext context) {
    return isEmpty ? Scaffold(
        body: EmptyWidgetBag(
            imagePath: AssetsManager.shoppingBasket,
            title: "O seu carrinho esta vazio",
            subtitle: "Parece me que seu carrinho esta vazio. /n Compre algo",
            buttonText: "Compre agora",
        ),
    ) : Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){},
            icon: const Icon(
            IconlyLight.delete,
              color: Colors.red,

          ),
          ),
        ],
        title: TitleText(label: "Carrinho(5) "),
        leading: Image.asset(AssetsManager.shoppingCart),
      ),
      body:
      ListView.builder(
        itemCount: 30,
          itemBuilder: (context, index){
        return const CartWidget(
          //vai aparecer a imagem colocada no cart_widget
        );
      },
      ),
    );
  }
}