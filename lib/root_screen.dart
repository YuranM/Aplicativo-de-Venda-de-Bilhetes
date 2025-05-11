import 'package:flutter/material.dart';
import 'package:bilheteriapdm/screens/cart/cart_screen.dart';
import 'package:bilheteriapdm/screens/home_page.dart';
import 'package:bilheteriapdm/screens/profile_screen.dart';
import 'package:bilheteriapdm/screens/search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {

  late PageController controller;
  int currentScreen = 0;
  List<Widget> screens = [
    HomePage(),
    SearchScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    controller = PageController(
      initialPage: currentScreen,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentScreen, // a sombra mover com a opcao selecionada
          backgroundColor: Theme.of(context).scaffoldBackgroundColor, //remove o background
          height: kBottomNavigationBarHeight,
          elevation: 2,
          onDestinationSelected: (value) {
        setState(() {
          currentScreen = value;
        });
        controller.jumpToPage(currentScreen);
      },
          destinations: const [
        NavigationDestination(
          selectedIcon: Icon(IconlyBold.home),
            icon: Icon(IconlyLight.home),
            label: "Inicio",
        ),


        NavigationDestination(
          selectedIcon: Icon(IconlyBold.search),
          icon: Icon(IconlyLight.search),
          label: "Pesquisa",
        ),


        NavigationDestination(
          selectedIcon: Icon(IconlyBold.bag2),
          icon: Icon(IconlyLight.bag2),
          label: "Carrinho de compras",
        ),


        NavigationDestination(
          selectedIcon: Icon(IconlyBold.profile),
          icon: Icon(IconlyLight.profile),
          label: "Perfil",
        ),
      ]),
    );
  }
}
