import 'package:bilheteriapdm/consts/app_constants.dart';
import 'package:bilheteriapdm/providers/theme_provider.dart';
import 'package:bilheteriapdm/widgets/subtitles_text.dart';
import 'package:bilheteriapdm/widgets/title_text.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/assets_manager.dart';
import '../widgets/app_name_text.dart';
import '../widgets/produtos/ultimos_eventos_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return  Scaffold(
        appBar: AppBar(
          title: AppNameTextWidget(),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(AssetsManager.shoppingCart),
          ),
        ),
      body:Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * 0.24,
              child: Swiper(
                itemBuilder: (context, index){
                  return Image.asset(AppConstants.bannersImages[index],);
                },
                  itemCount: AppConstants.bannersImages.length,
                  autoplay: true,
                  pagination: const SwiperPagination(
                  alignment: Alignment.bottomCenter,
                  builder: DotSwiperPaginationBuilder(
                      color: Colors.white,
                    activeColor: Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(
             height: 18,
            ),
            const TitleText(
              label: "Ultimos Eventos",
              fontSize: 22,
            ),
            const SizedBox(
              height: 18,
            ),
            SizedBox(
              height: size.height * 0.2,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return const UltimosEventosWidget();
                  },
              ),
            ),
          ],
        ),
      )
    );
  }
}
