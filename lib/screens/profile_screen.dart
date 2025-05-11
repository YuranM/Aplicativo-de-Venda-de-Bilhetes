import 'package:bilheteriapdm/services/assets_manager.dart';
import 'package:bilheteriapdm/widgets/app_name_text.dart';
import 'package:bilheteriapdm/widgets/subtitles_text.dart';
import 'package:bilheteriapdm/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../widgets/custom_list_tile.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return  Scaffold(
      appBar: AppBar(
        title: AppNameTextWidget(),
        leading: Image.asset(AssetsManager.shoppingCart),
      ),
      body:  Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: false,
            child:
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TitleText(
                label:
                "Faca o login para melhor experiencia"
            ),
          ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.background,
                      width: 3,
                    ),
                    image: const DecorationImage(
                        image: NetworkImage("url"), //Imagem do perfil por questao
                      //de demostracao irei colocar uma imagem aleatoria
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleText(label: "Yuran Mahique"),
                    SubtitlesText(label: "PDM@isutc.ac.mz")
                  ],
                ),

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText(
                    label: "General",
                ),
                CustomListTile(
                    imagePath: AssetsManager.orderSvg,
                    text: "Todos Pedidos",
                    function: (){},
                ),
                CustomListTile(
                  imagePath: AssetsManager.wishlistSvg,
                  text: "Guardados",
                  function: (){},
                ),
                CustomListTile(
                  imagePath: AssetsManager.recent,
                  text: "Recente",
                  function: (){},
                ),
                CustomListTile(
                  imagePath: AssetsManager.address,
                  text: "Endereco",
                  function: (){},
                ),
                Divider(
                  thickness: 2,
                ),
                SizedBox(
                  height: 10,
                ),
                TitleText(label: "Settings"),
                SwitchListTile(
                  title:  Text(themeProvider.getIsDartTheme
                      ? "Modo Escuro"
                      : "Modo Claro"),
                  value: themeProvider.getIsDartTheme,
                  onChanged: (value){
                    themeProvider.setDarkTheme(themevalue: value);
                  },
                ),
                Divider(
                  thickness: 2,
                ),
                SizedBox(
                  height: 10,
                ),
                
                
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      )
                    ),
                    onPressed: (){},
                    icon:
                    const Icon(
                        Icons.login
                    ),
                    label:
                    const Text(
                        "Sair"
                    ),
                  ),
                ),


              ],
            ),
          ),
        ],
      )
    );
  }
}
