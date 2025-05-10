import 'package:bilheteriapdm/widgets/empty_widget_bag.dart';
import 'package:bilheteriapdm/widgets/subtitles_text.dart';
import 'package:bilheteriapdm/widgets/title_text.dart';
import 'package:flutter/material.dart';

import '../services/assets_manager.dart';


class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: EmptyWidgetBag(
            imagePath: AssetsManager.shoppingBasket,
            title: "O seu carrinho esta vazio",
            subtitle: "Parece me que seu carrinho esta vazio. /n Compre algo",
            buttonText: "Compre agora",
        ),
    );
  }
}